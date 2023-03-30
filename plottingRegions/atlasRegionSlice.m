function [perimeterCoordinates,binaryMask,regionName,sliceIndex] = ...
    atlasRegionSlice(region,plane,annotationVolume,acronymTree,annotationTree,varargin)
% [boundaryXY,boundaryMask,regionName,sliceIndex] = atlasRegionSlice(region,plane,annotation_volume,structure_tree)
% Creates a slice through the reference atlas and highlights the borders of
% a target region. Output is a binary matrix spanning the entire brain in
% the specified plane. The section is centered on the center of mass of the
% specified region.
% - Region: the acronym for the region you want to find, as defined in the
%   structure tree table. Alternatively, supply a string array or cell
%   array of characters to select multiple regions. When doing so, outputs
%   will be cell arrays.
% - acronymTree and annotationTree are outputs from structureTreeFromCSV
% 
% [__] = atlasRegionSlice(___,'Hemisphere','left'/'right'/'all'/'both')
% Specify which hemisphere to look at. Defaults to both hemispheres for
% coronal and transverse planes, and the right hemisphere for the sagittal 
% plane.
%
% [__] = atlasRegionSlice(___,'SlicePlane',planeCoordinate
% Rather than calculating where to slice the plane based on the center of
% mass of the specified region, set that coordinate manually. 
%
% [__] = atlasRegionSlice(___,'Concatenate',true|false)
% Rather than output each region as a separate set of coordinates and a
% separate binary mask, create a single set of coordinates and a single
% mask merging all of the regions. Coordinates will be padded with NaNs
% between each region to make plotting neater. 

p = inputParser;
addRequired(p,'region',@(x) iscell(x) || ischar(x) || isstring(x));
addRequired(p,'plane',@(x) ismember(lower(x),{'coronal','sagittal','transverse'}));
addRequired(p,'annotationVolume');
addRequired(p,'acronymTree');
addRequired(p,'annotationTree');
addParameter(p,'Hemisphere','both',...
                    @(x) ismember(lower(x),{'all','both','left','right'}))
addParameter(p,'SlicePlane',[]);
addParameter(p,'AsCell',false,@(x) isscalar(x) && islogical(x));
addParameter(p,'Concatenate',false);
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

% Index through the identified regions and find their location in the brain
% volume:
volumePropsCell = cell(nRegionsTotal,1);

% Find the centroids of all of the regions, if we are not given a specific
% plane to slice through:
if ismember('SlicePlane',p.UsingDefaults)
    disp('Computing region centroids to identify slice plane');
    for i = 1:nRegionsTotal
        currRegionAcronym = regionNameCell{i};
        disp(string(currRegionAcronym)+" ("+string(i)+"/"+string(nRegionsTotal)+")");
        volumeBool = getOneRegionBinaryVolume(...
            currRegionAcronym,annotationVolume,acronymTree,annotationTree,...
            string(lower(hemisphere)));
        volumeProps = regionprops3(volumeBool,{'Centroid'});
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
            centroids = vPropsTable.Centroid(:,1);
        case 'sagittal'
            centroids = vPropsTable.Centroid(:,2);
        case 'transverse'
            centroids = vPropsTable.Centroid(:,3);
    end
    sliceIndex = round(mean(unique(centroids)));
else
    sliceIndex = round(p.Results.SlicePlane);
end

disp('Computing region boundaries at designated plane');

binaryMaskCell = cell(nRegionsTotal,1);
perimeterCoordinatesCell = cell(nRegionsTotal,1);
for i = 1:nRegionsTotal
    currRegionAcronym = regionNameCell{i};
    disp(string(currRegionAcronym)+" ("+string(i)+"/"+string(nRegionsTotal)+")");
    volumeBool = getOneRegionBinaryVolume(...
        currRegionAcronym,annotationVolume,acronymTree,annotationTree,...
        string(lower(hemisphere)));
    switch lower(plane)
        case 'coronal'
            binaryPlane = volumeBool(:,sliceIndex,:);
        case 'sagittal'
            binaryPlane = volumeBool(sliceIndex,:,:);
        case 'transverse'
            binaryPlane = volumeBool(:,:,sliceIndex);
    end
    binaryPlane = squeeze(binaryPlane);
    binaryMaskCell{i} = binaryPlane;
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

if p.Results.Concatenate == true
    % Merge all coordinates into a single matrix
    perimeterCoordinatesCell = cellfun(@(X) [X ; [nan nan]] , ...
        perimeterCoordinatesCell,'UniformOutput',false);
    % Remove last set of NaNs
    perimeterCoordinates = vertcat(perimeterCoordinatesCell{:});
    perimeterCoordinates(end,:) = [];
    
    % Combine all binary masks
    binaryMask = false(size(binaryMaskCell{1}));
    for i = 1:length(binaryMaskCell)
        binaryMask = binaryMask | binaryMaskCell{i} ;
    end
    
    
else
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
end
