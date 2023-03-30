% MakeRegionVolumes
% Generates volume data of specified regions and saves them as structs to
% make plotting 3D brain stuff easier.
% Uses the Allen Brain Atlas and some functions from sharpTrack, as well as
% custom functions.
% Outputs describe patches such that the patch() function will plot them
% immediately, though you will want to adjust several cosmetic options.

%% Loading atlas info
% Include "wholebrain" here to create the outline of the entire brian
% - Doing so takes much longer than analyzing individual regions
targetRegions = ["PO"];
[~,topPath] = loadMetadata_twoModalityConditioning;
reductFactor = 0.01; % How much we want to simplify the volumes, 0.01 is good for plotting
outPath = fullfile(topPath,'BrainVolumes');
if ~exist(outPath,'dir'); mkdir(outPath); end
if ~exist('annotationVolume','var')
    [annotationVolume,structureTreeTable,acronymTree,annotationTree]= loadAtlasFromSHARPTrack;
end
% if isequal('GHP2',getenv('COMPUTERNAME'))
%     % Load local files if running on personal laptop
%     topAtlasFolder = 'C:\Users\gordo\Documents\Atlas Registration Files';
% elseif ispc
%     topAtlasFolder = 'X:\gordon\Atlas Registration Files';
% else
%     topAtlasFolder = '/mnt/expanse/homes/gordon/Atlas Registration Files';
% end
% annotation_volume_location = fullfile(topAtlasFolder,'annotation_volume_10um_by_index.npy');
% structure_tree_location = fullfile(topAtlasFolder,'structure_tree_safe_2017.csv');
% template_volume_location = fullfile(topAtlasFolder,'template_volume_10um.npy');
% if ~exist('annotationVolume','var')
%     disp('loading reference atlas...')
%     annotationVolume = readNPY(annotation_volume_location);
%     structureTreeTable = loadStructureTree(structure_tree_location);
% end
% if ~exist('acronymTree','var')
%     [acronymTree,annotationTree] = structureTreeFromCSV(structureTreeTable);
% end
%% 
% [volume,regionName] = atlasRegionVolume({'root'},annotationVolume,acronymTree,annotationTree);
% Check for the whole brain volume first, as this is calculated differently
% from the others
if any(lower(targetRegions) == "wholebrain")
    volume = wholeBrainVolume(annotationVolume);
    fileName = fullfile(outPath,'WholeBrainVolume.mat');
    save(fileName,'-struct','volume');
end
%% Next iterate over and analyze the other regions 
regionsToAnalyze = targetRegions(lower(targetRegions) ~= "wholebrain");
nRegions = length(regionsToAnalyze);
for i = 1:nRegions
    [volumes,regionNames] = atlasRegionVolume(...
        regionsToAnalyze(i),annotationVolume,acronymTree,annotationTree,...
        'ReductionFactor',reductFactor,'AsCell',true,'Hemisphere','left');
    for j = 1:length(volumes)
        subregionName = regionNames{j};
        fileName = string(subregionName) + "_Volume.mat";
        fileName = fullfile(outPath,fileName);
        subregionVolume = volumes{j};
        save(fileName,'-struct','subregionVolume')
    end
    disp(regionsToAnalyze(i) + " volume saved");
end

disp("Done!");