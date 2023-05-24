% ExampleThalamusPlot2D
% An example workflow for generating 2D plots of some regions in the thalamus
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
% Using region acronyms. You can look these up in the annotation table
regions = ["VPM" "PO" "ZI"];

%% 3) Extract region borders from a slice of the brain
% Find the boundaries of the regions over a specified plane (coronal,
% sagittal, or transverse)
% - If the coordinates of the plane are not specified, this will
%   automatically find the centroid of each of the specified regions and
%   slice at the mean of each of those points. This is returned as the
%   output "sliceIndex"
plane ="transverse" ;
[perimeterCoordinates,binaryMask,regionName,sliceIndex] = ...
    atlasRegionSlice(regions,plane,annotationVolume,acronymTree,annotationTree);
% We can use this slice index to extract the border of the brain
wb_perimeterCoordinates = wholeBrainSlice(plane,sliceIndex,annotationVolume);

%% 4) Create a figure of each of the regions and the brain border

% Concatenate the outline of the brain with the rest of the perimeter
% coordinates:
allCoordinates = [{wb_perimeterCoordinates};perimeterCoordinates];
% Plot as colored outlines:
figure;
colors = {'k','b','g','y'};
brainPlot2D(allCoordinates,plane,'Color',colors);

% Alternatively, plot as patches:
figure;
brainPlot2D(allCoordinates,plane,'Color',colors,'Fill',true,'Alpha',0.1);

% Or, plot as a combination to outline some things and fill others
figure; hold on;
brainPlot2D(wb_perimeterCoordinates,plane,'Color','k');
brainPlot2D(perimeterCoordinates,plane,'Color',{'b','g','y'},'Fill',true)
legend([{'Whole Brain'};regionName])

%% 3B) Extract borders as a projection over a range of coordinates
% Finds an outline describing a projection of each region over the entire
% span of that region in the given plane. Returns "projectionRange," the
% range of coordinates projected over
regions = ["PO" "LP" "ZI" "VPM"];
plane = "coronal";
[perimeterCoordinates,binaryMask,regionName,projectionRange] = ...
    atlasRegionProjection(regions,plane,annotationVolume,acronymTree,annotationTree,...
    "Hemisphere",'left');
% To plot the whole brain, we can find the slice in the middle of this
% projection range.
sliceIndex = round(mean(projectionRange));
wb_perimeterCoordinates = wholeBrainSlice(plane,sliceIndex,annotationVolume);

%% 4B) Plot this projection data using the same plotting function
figure; hold on
brainPlot2D(wb_perimeterCoordinates,plane,'Color','k');
brainPlot2D(perimeterCoordinates,plane,'Fill',true,'Alpha',0.4);
legend([{'Brain Boundary'};regionName]);

%% 5) Other notes
% You can specify the slice or projection range in atlasRegionSlice and
% atlasRegionProjection. This is useful for plotting exact positions of
% clusters or probes.
% You can plot only a single hemisphere by specifying the 'Hemisphere'
% property as 'right' or 'left' in either atlasRegionProjection and
% atlasRegionSlice. This works only for coronal and transverse planes.


