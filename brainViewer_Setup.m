% Welcome to brainViewer!
% Use this script to locate the Allen reference atlas files and to specify
% a default output directory. Results from this script will be saved as 
% brainViewer_params.mat, storing results as a struct array. Other 
% brainViewer scripts will look for this specific file in this directory. 
% However, component functions do not depend on specific file names, so you
% are free to write other scripts that use them and create your own
% workflow. 

% For now, only storing path information, but other parameters may be
% stored here too.

%% Find the Allen reference information
% - See README for information on downloading these files.
refAtlasFolderPath = uigetdir(cd,'Select folder containing the Allen reference atlas files');
if isequal(refAtlasFolderPath,0); return; end
%% Set an output folder location
% - By default, brain region volumes and plots will be saved here in a new
% folder. Be sure to select a directory that you have write permission to. 
% (You can use the same path that brainViewer is saved to if you wish).
defaultOutputPath = uigetdir(cd,'Select default output directory');
if isequal(defaultOutputPath,0); return; end
defaultFolder = 'brainViewer_output';
if ~exist(fullfile(defaultOutputPath,defaultFolder),'dir')
    mkdir(fullfile(defaultOutputPath,defaultFolder));
end

%% Store these paths to a struct array and save here

mfilePath = mfilename('fullpath');
% (If running this code section-by-section, mfilename won't work and we 
% need to get the active file name instead)
if contains(mfilePath,'LiveEditorEvaluationHelper')
    mfilePath = matlab.desktop.editor.getActiveFilename;
end
parameterSavePath = fileparts(mfilePath);
S = struct('DefaultOutputPath',fullfile(defaultOutputPath,defaultFolder),...
           'ReferenceAtlasPath',refAtlasFolderPath,...
           'TreeCSVFilename','structure_tree_safe_2017.csv',...
           'AnnotationVolumeFilename','annotation_volume_10um_by_index.npy');
       
save(fullfile(parameterSavePath,'brainViewer_params.mat'),'-struct','S');
