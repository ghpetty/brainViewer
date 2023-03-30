function [perimeterCoordinates,binaryMask] = wholeBrainSlice(plane,sliceIndex,annotationVolume)
% [perimeterCoordinates,binaryMask] = wholeBrainSlice(plane,sliceIndex,annotationVolume)
% Find the outline of the brain in one of three slices, according to the
% Allen Brain Atlas
% Plane is "coronal", "sagittal", or "transverse"
% sliceIndex is the position along the specified axis which you are slicing
% at. Must be an integer
% The annotation volume is from the Allen Brain Atlas
% This is a simplified (and faster) version of atlasRegionSlice()
% Use atlasRegionSlice to extract information from specific regions, rather
% than the border of the whole brain

p = inputParser;
addRequired(p,'plane',@(x) ismember(lower(x),{'coronal','sagittal','transverse'}));
addRequired(p,'annotationVolume');
addRequired(p,'sliceIndex');
parse(p,plane,annotationVolume,sliceIndex);

% Slice out the specified plane:
annotationVolume = permute(annotationVolume,[3 1 2]); % Width x Length x Height
switch lower(plane)
    case "coronal"
        brainSlice = annotationVolume(:,sliceIndex,:);
    case "sagittal"
        brainSlice = annotationVolume(sliceIndex,:,:);
    case "transverse"
        brainSlice = annotationVolume(:,:,sliceIndex);
end

% Find all non-one values - these are all regions considered to be part of
% the brain.
brainSlice = squeeze(brainSlice);
binarySlice = brainSlice ~= 1;
% Fill in gaps for smoother image:
binarySlice = imfill(binarySlice,'holes');
boundaryXY = bwboundaries(binarySlice);
if ~iscell(boundaryXY);boundaryXY = {boundaryXY};end
% Merge boundaries, padding with NaNs between each one
boundaryXY = cellfun(@(X) [X ; [nan nan]] , boundaryXY,'UniformOutput',false);
boundaryXY = vertcat(boundaryXY{:});
% Remove last NaN value
boundaryXY(end,:) = [];
% Plotting code for debugging:
% figure; sp1 = subplot(1,2,1);
% imshow(imadjust(double(binarySlice')));
% sp2 = subplot(1,2,2);
% plot(boundaryXY(:,1) , boundaryXY(:,2));

perimeterCoordinates = boundaryXY;
binaryMask = binarySlice;
