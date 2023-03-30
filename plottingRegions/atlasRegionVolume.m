function [volume,regionName] = atlasRegionVolume(region,annotationVolume,acronymTree,annotationTree,varargin)
% volume = atlasRegionVolume(region,annotation_volume,acronymTree,annotationTree)
% Extracts the volume of a brain region from the Allen Brain Atlas and
% returns an isosurface struct array for plotting.
% - region: An acronym for a region in the ABA annotation tree
% - annotationVolume: The brain volume matrix
% - acronymTree, annotationTree : Outputs from structureTreeFromCSV()
% If the given region has multiple subregions, the output will be a cell
% array of isosurfaces. The second output 'regionName' is a cell array of
% region acronyms (chars) indicating which isosurface corresponds to which
% region. (Subregions are leaves on the structure tree).
% 
% [volume,region] = atlasRegionVolume(Regions,___)
% Specify multiple regions as a cell array or as a string array. Returns an
% isosurface for each specified region (or each child region of the
% specified regions)
%
% volume = atlasRegionVolume(___,'Hemisphere','left'/'right'/'both'/'all')
% Specify which hemisphere to look at. Defaults to both hemispheres.
%
% volume = atlasRegionVolume(___,'ReductionFactor',rf)
% Specify a factor by which to reduce the number of patches in the output
% isosurface. The brain volume is much higher resolution than generally
% needed for visualization, so this defaults to 0.01 (reducing the output
% number of polygons by 99%). Set to 1 to perform no reduction. (Uses the 
% 'reducepatch' function).
%
% [volume,region] = atlasRegionVolume(region,___,'AsCell',true)
% Returns output volume as a cell even if only given a single input region
% and there are no subregions.

p = inputParser;
addRequired(p,'region',@(x) iscell(x) || ischar(x) || isstring(x));
addRequired(p,'annotationVolume');
addRequired(p,'acronymTree');
addRequired(p,'annotationTree');
addParameter(p,'Hemisphere','both',...
                    @(x) ismember(lower(x),{'all','both','left','right'}))
addParameter(p,'ReductionFactor',0.01,@(x) isnumeric(x) && isscalar(x) && x<=1 && x>0);
addParameter(p,'AsCell',false,@(x) isscalar(x) && islogical(x));

parse(p,region,annotationVolume,acronymTree,annotationTree,varargin{:});

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

midlineValue = 570; % Hardcoding this, from inspection of 3D brain volume visualization

% Index through the identified regions and find their location in the brain
% volume:
isoCell = cell(size(regionNameCell));
for i = 1:nRegionsTotal
    currRegionAcronym = regionNameCell{i};
    disp(string(currRegionAcronym)+" ("+string(i)+"/"+string(nRegionsTotal)+")");
    currRegionInd = find(strcmp(acronymTree,currRegionAcronym));
    currRegionAnnotationVal = annotationTree.get(currRegionInd);
    disp('   Indexing annotation volume...');
    volumeBool = annotationVolume == currRegionAnnotationVal;
    if ~any(volumeBool,'all')
        warning(currRegionAcronym+" annotation value not found in brain volume, skipping");
        continue
    end
    volumeBool = permute(volumeBool,[3 1 2]);  % Reshapes matrix to fit with wireframe diagram
    % Isolate specified hemisphere by setting all values on the opposite
    % hemisphere to 'false'
    switch string(lower(p.Results.Hemisphere))
        case "right"
            volumeBool(1:midlineValue,:,:) = false;
        case 'left'
            volumeBool(midlineValue:end,:,:) = false;
    end
    disp('   Computing isosurface...');
    ISO = isosurface(volumeBool,0.5);
    if p.Results.ReductionFactor ~=1
        disp('   Simplifying isosurface...'); 
        isoCell{i} = reducepatch(ISO,0.01);
    else
        isoCell{i} = ISO;
    end
    % Plotting code for debugging:
%     hold on;
%     patchHandle = patch(isoCell{i});
%     set(patchHandle,'EdgeAlpha',0,'FaceColor','b','FaceAlpha',0.3);
%     drawnow
end

% Remove empty values (happens if there are regions we skipped)
emptyInds = cellfun('isempty',isoCell);
isoCell(emptyInds) = [];
regionNameCell(emptyInds) = [];

if ~p.Results.AsCell && nRegionsTotal == 1
    volume = isoCell{:};
    regionName = regionNameCell{:};
else
    volume = isoCell;
    regionName = regionNameCell;
end