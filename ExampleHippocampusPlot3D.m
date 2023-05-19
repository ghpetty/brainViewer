% ExampleHippocampusPlot3D
% An example workflow for generating a 3D plot of hippocampal regions
% Before running this, be sure to run:
% brainViewer_Setup
% brainViewer_saveWholeBrainVolume

%% 1) Load in atlas data and annotation data
parameterStruct = load('brainViewer_params.mat');
[annotationVolume,annotationTable,acronymTree,annotationTree] = ...
    loadAllData_bv(parameterStruct);
% The acronym tree contains the abbreviated names of each brain region. The
% annotation tree contains the associated numeric annotation in the brain
% volume. 

%% 2) Specify the region or regions to plot
regions = "HIP" ; 
% Will extract ALL subregions that are below the node 'HIP' in the acronym tree
% Can also set multiple sub regions
% regions = ["CA1", "CA2"];
% Look through the annotation table to find acronyms of regions of interest
% Not all sub regions are in the annotation volume.

%% 3) Find the volumes of the region of interest and compute a surface
% This is done iteratively over all subregions of the specified region(s)
% above. This is the longest step
[volume,regionName] = atlasRegionVolume(regions,annotationVolume,acronymTree,annotationTree);

%% 4) Save the volumes to the output path
numRegions = length(volume);
for ii = 1:numRegions
    tempStruct = volume{ii};
    save(fullfile(parameterStruct.DefaultOutputPath,[regionName{ii},'.mat']),...
        '-struct','tempStruct')
end

%% 5) Plot the whole brain
% - Load the pre-rendered 3D brain surface
WB = load(fullfile(parameterStruct.DefaultOutputPath,"WholeBrainSurface.mat"));
myFigure = figure; 
brainPlot3D(WB,'Color','k','Alpha',0.1)

%% 6) Iterate through all of the other regions and plot them
% You can do this by passing the entire cell of volume data, or create your
% own for-loop
hold on
brainPlot3D(volume);
legend([{'Brain Surface'},regionName]);
title('The Mouse Hippocampus');
%% 7) Save the resulting figure
savefig(myFigure,fullfile(parameterStruct.DefaultOutputPath,'Example Hippocampus Plot.fig'));

%% 8) Other stuff
% - You can plot only a sub sample of the regions
targetRegions = {'CA1','CA2','CA3'};
regionColors = {'r','b','g'};

myFigure = figure;
brainPlot3D(WB,'Color',[0.5 0.5 0.5],'Alpha',0.1);
hold on
for ii = 1:length(targetRegions)
    regionInd = find(ismember(regionName,targetRegions(ii)));
    brainPlot3D(volume(regionInd),'Color',regionColors{ii},'Alpha',1);
end
legend([{'Brain Surface'},targetRegions])

% - You can specify a lighting source. This works best when you set Alpha=1
camlight
lighting gouraud
% - See the MATLAB documentation for lighting for other options


