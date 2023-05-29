function Volume = saveWholeBrainVolume_bvApp(parameters)
% A function version of the default script "brainViewer_saveWholeBrainVolume"
% 
% Called by the brainViewer app if the whole brain volume is missing

downsampleFactor = 0.01; 
pathData = parameters ; 
annotationVolumeFileName = 'annotation_volume_10um_by_index.npy';
disp('loading reference atlas...');
annotationVolume = readNPY(fullfile(pathData.ReferenceAtlasPath,annotationVolumeFileName));
Volume = wholeBrainVolume(annotationVolume,'Hemisphere','both','ReductionFactor',downsampleFactor);
save(fullfile(pathData.DefaultOutputPath,'WholeBrainSurface.mat'),'-struct','Volume');
