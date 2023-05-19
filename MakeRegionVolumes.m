% MakeRegionVolumes
% Generates volume data of specified regions and saves them as structs to
% make plotting 3D brain stuff easier.
% Uses the Allen Brain Atlas and some functions from sharpTrack, as well as
% custom functions.
% Outputs describe patches such that the patch() function will plot them
% immediately, though you will want to adjust several cosmetic options.

%% Loading atlas info
targetRegions = ["DG","CA3","CA2"];
reductFactor = 0.01; % How much we want to simplify the volumes, 0.01 is good for plotting
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

disp('Loading and indexing structure tree')
tablePath = fullfile(pathData.ReferenceAtlasPath,'structure_tree_safe_2017.csv');
structureTable = brainViewer_loadStructureTree(tablePath);
[acronymTree,annotationTree] = structureTreeFromCSV(structureTable);
%% Next iterate over and analyze each region
regionsToAnalyze = targetRegions(lower(targetRegions) ~= "wholebrain");
nRegions = length(regionsToAnalyze);
for i = 1:nRegions
    [volumes,regionNames] = atlasRegionVolume(...
        regionsToAnalyze(i),annotationVolume,acronymTree,annotationTree,...
        'ReductionFactor',reductFactor,'AsCell',true,'Hemisphere','left');
    for j = 1:length(volumes)
        subregionName = regionNames{j};
        fileName = string(subregionName) + "_Volume.mat";
        fileName = fullfile(pathData.DefaultOutputPath,fileName);
        subregionVolume = volumes{j};
        save(fileName,'-struct','subregionVolume')
    end
    disp(regionsToAnalyze(i) + " volume saved");
end

disp("Done!");