function volumeBool = getOneRegionBinaryVolume(regAcro,annVol,acroTree,annTree,hemisphere)
% volumeBool = getOneRegionBinaryVolume(regionAcronym,annotationVolume,acronymTree,annotationTree,hemisphere)
% Helper function for atlasRegionProjection and atlasRegionSlice.
% Used to find the indices in the annotation volume corresponding to the
% specified region.
currRegionInd = find(strcmp(acroTree,regAcro));
currRegionAnnotationVal = annTree.get(currRegionInd);
volumeBool = annVol == currRegionAnnotationVal;
if ~any(volumeBool,'all')
    warning(regAcro+" annotation value not found in brain volume, skipping");
end

% Isolate specified hemisphere by setting all values on the opposite
% hemisphere to 'false'
midlineValue = 570; % Hardcoded, from inspection of the atlas
switch hemisphere
    case "right"
        volumeBool(1:midlineValue,:,:) = false;
    case 'left'
        volumeBool(midlineValue:end,:,:) = false;
end
