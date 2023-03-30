function volume = wholeBrainVolume(annotationVolume,varargin)
% volume = wholeBrainVolume(annotationVolume)
% Extracts the volume of the brain surface from the Allen Brain Atlas and
% returns a patch struct array for plotting.
% This is a simplified version of atlasRegionVolume that only looks for the
% surface of the brain, rather than specific inner regions
%
% volume = atlasRegionVolume(___,'Hemisphere','left'/'right'/'both'/'all')
% Specify which hemisphere to extract. Defaults to the whole brain.
%
% volume = atlasRegionVolume(___,'ReductionFactor',rf)
% Specify a factor by which to reduce the number of patches in the output
% isosurface. The brain volume is much higher resolution than generally
% needed for visualization, so this defaults to 0.01 (reducing the output
% number of polygons by 99%). Set to 1 to perform no reduction. (Uses the
% 'reducepatch' function).


p = inputParser;
addRequired(p,'annotationVolume');
addParameter(p,'Hemisphere','both',...
    @(x) ismember(lower(x),{'all','both','left','right'}))
addParameter(p,'ReductionFactor',0.01,@(x) isnumeric(x) && isscalar(x) && x<=1 && x>0);

parse(p,annotationVolume,varargin{:});

midlineValue = 570; % Hardcoding this, from inspection of 3D brain volume visualization

% Index through the identified regions and find their location in the brain
% volume:

disp('   Indexing annotation volume...');
volumeBool = annotationVolume ~=1;

volumeBool = permute(volumeBool,[3 1 2]);  % Reshapes matrix to fit with wireframe diagram
% Isolate specified hemisphere by setting all values on the opposite
% hemisphere to 'false'
switch string(lower(p.Results.Hemisphere))
    case "right"
        volumeBool(1:midlineValue,:,:) = false;
    case 'left'
        volumeBool(midlineValue:end,:,:) = false;
end
% Iterate through each slice of the brain
% Fill in gaps to make the volume simpler
% figure;
% sp1 = subplot(1,2,1);
% sp2 = subplot(1,2,2);
volumeY = size(volumeBool,2);
volumeX = size(volumeBool,1);
volumeZ = size(volumeBool,3);
disp('Patching gaps sagittally');
parfor i = 1:volumeX
    currentSlice =imadjust(double(squeeze(volumeBool(i,:,:))))';
%     if ~all(currentSlice == 0,'all')
%     imshow(currentSlice,'Parent',sp1);
    % Imfill to try and patch over gaps within regions
    csFill = imfill(currentSlice,'holes');
%     imshow(csFill,'Parent',sp2);
%     drawnow
    volumeBool(i,:,:) = (csFill == 1)' ;
%     drawnow;
%     
end
disp('Patching gaps coronally');
parfor i = 1:volumeY
    currentSlice =imadjust(double(squeeze(volumeBool(:,i,:))))';
%     if ~all(currentSlice == 0,'all')
%     imshow(currentSlice,'Parent',sp1);
    % Imfill to try and patch over gaps within regions
    csFill = imfill(currentSlice,'holes');
%     imshow(csFill,'Parent',sp2);
%     drawnow
    volumeBool(:,i,:) = (csFill == 1)' ;
%     end
end
disp('Patching gaps transversely');
parfor i = 1:volumeZ
    currentSlice =imadjust(double(squeeze(volumeBool(:,:,i))));
%     if ~all(currentSlice == 0,'all')
%     imshow(currentSlice,'Parent',sp1);
    % Imfill to try and patch over gaps within regions
    csFill = imfill(currentSlice,'holes');
%     imshow(csFill,'Parent',sp2);
%     drawnow
    volumeBool(:,:,i) = (csFill == 1);
%     end
end


disp('Computing volume surface (this will take several minutes)');
ISO = isosurface(volumeBool,0.5);
if p.Results.ReductionFactor ~=1
    disp('   Simplifying surface');
    ISO = reducepatch(ISO,0.01);
end
volume = ISO;
disp('Done!');
% Plotting code for debugging:
%     hold on;
%     patchHandle = patch(isoCell{i});
%     set(patchHandle,'EdgeAlpha',0,'FaceColor','b','FaceAlpha',0.3);
%     drawnow


% Remove empty values (happens if there are regions we skipped)
