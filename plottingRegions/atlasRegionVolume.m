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
%
% [volume,region] = atlasRegionVolume(region,___,'Merge',(false)|true)
% Specify as true to combine all sub-regions of the input regions as a
% single volume. For example inputting regions = ["LG","DG"] will return two volumes, the first 
% comprised of all subregions of the lateral geniculate nucleus, the second
% of all subregions of the dentate gyrus. 

p = inputParser;
addRequired(p,'region',@(x) iscell(x) || ischar(x) || isstring(x));
addRequired(p,'annotationVolume');
addRequired(p,'acronymTree');
addRequired(p,'annotationTree');
addParameter(p,'Hemisphere','both',...
                    @(x) ismember(lower(x),{'all','both','left','right'}))
addParameter(p,'ReductionFactor',0.01,@(x) isnumeric(x) && isscalar(x) && x<=1 && x>0);
addParameter(p,'AsCell',false,@(x) isscalar(x) && islogical(x));
addParameter(p,'Merge',false,@(x) isscalar(x) && islogical(x));

parse(p,region,annotationVolume,acronymTree,annotationTree,varargin{:});

% Index through the annotation tree to see how many regions we will be
% processing:
% (We use dynamic indexing here to get all of the region names as this
% variable will be very small and shouldn't impact performance much).

midlineValue = 570; % Hardcoding this, from inspection of 3D brain volume visualization
region = string(region);
if p.Results.Merge
    isoCell = cell(length(region),1)
    regionName = region;
else
    isoCell = {};
    regionName = {};
end



% Check that input acronyms are valid
for ii = 1:length(region)
    currRegionAcronym = region(ii);
%     currRegionInd = acronymTree.find(currRegionAcronym);
    currRegionInd = find(strcmp(acronymTree,currRegionAcronym));
    if isempty(currRegionInd)
        error(string(currRegionAcronym)+" not found in acronym tree");
    end
end

for ii = 1:length(region)
    currRegionAcronym = region(ii);
    currRegionInd = find(strcmp(acronymTree,currRegionAcronym));
    currSubtree = acronymTree.subtree(currRegionInd);
    currInds = currSubtree.breadthfirstiterator;
    subregionNameCell = cell(length(currInds),1);
    for jj = 1:length(currInds)
        subregionNameCell{jj} = currSubtree.get(currInds(jj));
    end
    nSubregionsTotal = length(subregionNameCell);
    disp("Found "+string(nSubregionsTotal)+" subregions to extract from "+string(currRegionAcronym));
    
    if p.Results.Merge
        regionName = region;
        disp('Merging all subregions into single volume')
        volumeBool = false(size(annotationVolume));
        for jj = 1:nSubregionsTotal
            currRegionAcronym = subregionNameCell{jj};
            disp(string(currRegionAcronym)+" ("+string(jj)+"/"+string(nSubregionsTotal)+")");
            currRegionInd = find(strcmp(acronymTree,currRegionAcronym));
            currRegionAnnotationVal = annotationTree.get(currRegionInd);
            volumeBool = volumeBool | (annotationVolume == currRegionAnnotationVal);
        end
        patchOut = computeOneSurface(volumeBool,p.Results.Hemisphere,midlineValue,p.Results.ReductionFactor);
        isoCell(ii) = {patchOut};
    else
        for jj = 1:nSubregionsTotal
            currRegionAcronym = subregionNameCell{jj};
            disp(string(currRegionAcronym)+" ("+string(jj)+"/"+string(nSubregionsTotal)+")");
            currRegionAnnotationVal = annotationTree.get(...
                find(strcmp(acronymTree,currRegionAcronym)));
            volumeBool = annotationVolume == currRegionAnnotationVal;
            if ~any(volumeBool,'all')
                warning(currRegionAcronym+" annotation value not found in brain volume, skipping");
            else
                patchOut = computeOneSurface(volumeBool,p.Results.Hemisphere,midlineValue,p.Results.ReductionFactor);
                isoCell(end+1) = {patchOut};
                regionName(end+1) = {string(currRegionAcronym)};
            end
        end
    end
end

regionName = [regionName{:}]' ; % Cell array to string array
volume = isoCell;
if length(volume) == 1 && ~p.Results.AsCell
    volume = volume{:};
end
% 
% 
% % Index through the identified regions and find their location in the brain
% % volume:
% isoCell = cell(size(subregionNameCell));
% for ii = 1:nSubregionsTotal
%     currRegionAcronym = subregionNameCell{ii};
%     disp(string(currRegionAcronym)+" ("+string(ii)+"/"+string(nSubregionsTotal)+")");
%     currRegionInd = find(strcmp(acronymTree,currRegionAcronym));
%     currRegionAnnotationVal = annotationTree.get(currRegionInd);
%     disp('   Indexing annotation volume...');
%     volumeBool = annotationVolume == currRegionAnnotationVal;
%     if ~any(volumeBool,'all')
%         warning(currRegionAcronym+" annotation value not found in brain volume, skipping");
%         continue
%     end
%     volumeBool = permute(volumeBool,[3 1 2]);  % Reshapes matrix to fit with wireframe diagram
%     % Isolate specified hemisphere by setting all values on the opposite
%     % hemisphere to 'false'
%     switch string(lower(p.Results.Hemisphere))
%         case "right"
%             volumeBool(1:midlineValue,:,:) = false;
%         case 'left'
%             volumeBool(midlineValue:end,:,:) = false;
%     end
%     disp('   Computing isosurface...');
%     % ISO = isosurface(volumeBool,0.5);
%     ISO = marchingCubes_bv(volumeBool,'-v');
%     if p.Results.ReductionFactor ~=1
%         disp('   Simplifying isosurface...'); 
%         isoCell{ii} = reducepatch(ISO,0.01);
%     else
%         isoCell{ii} = ISO;
%     end
%     % Plotting code for debugging:
% %     hold on;
% %     patchHandle = patch(isoCell{i});
% %     set(patchHandle,'EdgeAlpha',0,'FaceColor','b','FaceAlpha',0.3);
% %     drawnow
% end
% 
% % Remove empty values (happens if there are regions we skipped)
% emptyInds = cellfun('isempty',isoCell);
% isoCell(emptyInds) = [];
% subregionNameCell(emptyInds) = [];
% 
% if ~p.Results.AsCell && nSubregionsTotal == 1
%     volume = isoCell{:};
%     regionNameCell = subregionNameCell{:};
% else
%     volume = isoCell;
%     regionNameCell = subregionNameCell;
% end

% --- Subfunctions ---
function patchOut = computeOneSurface(volumeBool,hemisphere,midlineValue,reductionFactor)
    volumeBool = permute(volumeBool,[3 1 2]);  % Reshapes matrix to fit with wireframe diagram
        % Isolate specified hemisphere by setting all values on the opposite
        % hemisphere to 'false'
        switch string(lower(hemisphere))
            case "right"
                volumeBool(1:midlineValue,:,:) = false;
            case 'left'
                volumeBool(midlineValue:end,:,:) = false;
        end
        disp('   Computing isosurface...');
        % ISO = isosurface(volumeBool,0.5);
        ISO = marchingCubes_bv(volumeBool,'-v');
        if reductionFactor ~=1
            disp('   Simplifying isosurface...'); 
            patchOut = reducepatch(ISO,reductionFactor);
        else
            patchOut = ISO;
        end