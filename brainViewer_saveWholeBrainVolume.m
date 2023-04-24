% brainViewer_saveWholeBrainVolume
% Generate a file containing volume information depicting the surface of
% the entire brain. 
% This is the slowest and most computationally intensive part of
% brainViewer, and will take several minutes to complete. Once complete,
% the output can be reused for any and all 3D plots (so ideally you only 
% ever run this once). 
% Output is saved to the brainViewer_output folder as specified in the
% brainViewer_params.mat file.

%%
downsampleFactor = 0.01; 
mfilePath = mfilename('fullpath');
% (If running this code section-by-section, mfilename won't work and we 
% need to get the active file name instead)
if contains(mfilePath,'LiveEditorEvaluationHelper')
    mfilePath = matlab.desktop.editor.getActiveFilename;
end
brainViewerPath = fileparts(mfilePath);
pathData = load(fullfile(brainViewerPath,'brainViewer_params.mat'));
annotationVolumeFileName = 'annotation_volume_10um_by_index.npy';

% annotation_volume_location = fullfile(topAtlasFolder,'annotation_volume_10um_by_index.npy');
% structure_tree_location = fullfile(topAtlasFolder,'structure_tree_safe_2017.csv');

disp('loading reference atlas...');
annotationVolume = readNPY(fullfile(pathData.ReferenceAtlasPath,annotationVolumeFileName));
%
Volume = wholeBrainVolume(annotationVolume,'Hemisphere','both','ReductionFactor',downsampleFactor);
% volume_downsampled = reducepatch(volume,downsampleFactor);

% Save output
save(fullfile(DefaultOutputPath,'WholeBrainSurface.mat'),'Volume');

%% Create a nice plot
figure
brainPlot3D(Volume,'Color',[0.5 0.5 0.5],'Alpha',0.8);
camlight
lighting gouraud
