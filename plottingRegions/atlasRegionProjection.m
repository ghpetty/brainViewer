function [perimeterCoordinates,binaryMask,regionName,projectionRange] = ...
    atlasRegionProjection(region,plane,annotationVolume,acronymTree,annotationTree,varargin)
%[perimeterCoordinates,binaryMask,regionName,projectionRange] = ...
%    atlasRegionProjection(region,plane,annotationVolume,acronymTree,annotationTree)
% Create a projection of a brain region (or several regions) over a
% specified plane (coronal, transverse, or sagittal). The projection is the
% outline of the region across its entire span in the specified plane. 
% (Similar to atlasRegionSlice)
% 
% - Region: the acronym for the region you want to find, as defined in the
%   structure tree table. Alternatively, supply a string array or cell
%   array of characters to select multiple regions. When doing so, outputs
%   will be cell arrays.
% - acronymTree and annotationTree are outputs from structureTreeFromCSV
% 
% [__] = atlasRegionProjection(___,'Hemisphere','left'/'right'/'all'/'both')
% Specify which hemisphere to look at. Defaults to both hemispheres for
% coronal and transverse planes, and the right hemisphere for the sagittal 
% plane.
%
% [__] = atlasRegionProjection(___,'ProjectionRange',[range1 range2])
% Rather than calculating where to slice the plane based on the span of the
% given region, specify a range of elements over which to project.


p = inputParser;
addRequired(p,'region',@(x) iscell(x) || ischar(x) || isstring(x));
addRequired(p,'plane',@(x) ismember(lower(x),{'coronal','sagittal','transverse'}));
addRequired(p,'annotationVolume');
addRequired(p,'acronymTree');
addRequired(p,'annotationTree');
addParameter(p,'Hemisphere','both',...
                    @(x) ismember(lower(x),{'all','both','left','right'}))
addParameter(p,'ProjectionRange',[]);
addParameter(p,'AsCell',false,@(x) isscalar(x) && islogical(x));
parse(p,region,plane,annotationVolume,acronymTree,annotationTree,varargin{:});



if ismember(p.Results.Hemisphere,{'both','all'}) && lower(string(plane)) == "sagittal"
    hemisphere = 'right';
else
    hemisphere = p.Results.Hemisphere;
end
annotationVolume = permute(annotationVolume,[3 1 2]); % Width x Length x Height
% Index through the annotation tree to see how many regions we will be
% processing:
% (We use dynamic indexing here to get all of the region names as this
% variable will be very small and shouldn't impact performance much).
regionNameCell = {};
region = string(region);
for i = 1:length(region)
    currRegionAcronym = region(i);
%     currRegionInd = acronymTree.find(currRegionAcronym);
    currRegionInd = find(strcmp(acronymTree,currRegionAcronym));
    if isempty(currRegionInd)
        error(string(currRegionAcronym)+" not found in acronym tree");
    end
    currSubtree = acronymTree.subtree(currRegionInd);
    currInds = currSubtree.breadthfirstiterator;
    for j = 1:length(currInds)
        regionNameCell{end+1} = currSubtree.get(currInds(j));
    end
end
nRegionsTotal = length(regionNameCell);
disp("Found "+string(nRegionsTotal)+" regions to extract");

volumePropsCell = cell(nRegionsTotal,1);

% Find the bounding boxes of the regions, if we are not given a specific
% range to project over
if ismember('ProjectionRange',p.UsingDefaults)
    disp('Computing region boundaries to identify projection range');
    for i = 1:nRegionsTotal
        currRegionAcronym = regionNameCell{i};
        disp(string(currRegionAcronym)+" ("+string(i)+"/"+string(nRegionsTotal)+")");
        volumeBool = getOneRegionBinaryVolume(...
            currRegionAcronym,annotationVolume,acronymTree,annotationTree,...
            string(lower(hemisphere)));
        volumeProps = regionprops3(volumeBool,{'BoundingBox'});
        if ~isempty(volumeProps)
            volumePropsCell{i} = volumeProps;
        end
    end
    % Here we can trim away missing regions 
    emptyInds = cellfun('isempty',volumePropsCell);
    volumePropsCell(emptyInds) = [];
    regionNameCell(emptyInds) = [];
    nRegionsTotal = length(regionNameCell);
    % Concatenate all centroids and take the mean based on the slicing plane
    vPropsTable = vertcat(volumePropsCell{:});
    switch lower(plane)
        case 'coronal'
            projR = vPropsTable.BoundingBox(:,[1 4]);
        case 'sagittal'
            projR = vPropsTable.BoundingBox(:,[2 5]);
        case 'transverse'
            projR = vPropsTable.BoundingBox(:,[3 6]);
    end
    projR = cumsum(projR,2);
    projectionRange = round([min(projR(:,1)) max(projR(:,2))]);
else
    projectionRange = round(p.Results.ProjectionRange);
end

% Isolate a volume over the specified range 

disp('Computing region boundaries over designated projection range');

binaryMaskCell = cell(nRegionsTotal,1);
perimeterCoordinatesCell = cell(nRegionsTotal,1);
% Convert to vector for indexing
projRVect = projectionRange(1):projectionRange(2);
for i = 1:nRegionsTotal
    currRegionAcronym = regionNameCell{i};
    disp(string(currRegionAcronym)+" ("+string(i)+"/"+string(nRegionsTotal)+")");
    volumeBool = getOneRegionBinaryVolume(...
        currRegionAcronym,annotationVolume,acronymTree,annotationTree,...
        string(lower(hemisphere)));
    % Project by identifying coordinates that have a 'true' value at any
    % position along the specified dimension
    switch lower(plane)
        case 'coronal'
            binarySegment = volumeBool(:,projRVect,:);
            binaryPlane = any(binarySegment,2);
        case 'sagittal'
            binarySegment = volumeBool(projRVect,:,:);
            binaryPlane = any(binarySegment,1);
        case 'transverse'
            binarySegment = volumeBool(:,:,projRVect);
            binaryPlane = any(binarySegment,3);
    end
%     figure; 
%     for j = 1:size(binarySegment,2)
%         imshow(imadjust(double(squeeze(binarySegment(:,j,:))')));
%         drawnow
%         pause(0.1);
%     end
    binaryPlane = squeeze(binaryPlane);
    binaryMaskCell{i} = binaryPlane;
%     figure; imshow(imadjust(double(binaryMaskCell{i})));
    boundaryXY = bwboundaries(binaryPlane);
    if length(boundaryXY) > 1
        % Add a nan in the middle so, when plotting, you don't join up both
        % hemispheres
        boundaryXY = vertcat(boundaryXY{1},[nan nan],boundaryXY{2});
        
    else
        boundaryXY = boundaryXY{:};
    end
    perimeterCoordinatesCell{i} = boundaryXY;
end


% Rename variables for output
if ~p.Results.AsCell && nRegionsTotal == 1
    perimeterCoordinates = perimeterCoordinatesCell{:} ;
    binaryMask = binaryMaskCell{:};
    regionName = regionNameCell{:};
else
    perimeterCoordinates = perimeterCoordinatesCell;
    binaryMask = binaryMaskCell;
    regionName = regionNameCell';
end
