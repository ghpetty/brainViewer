% POm_Rotating_Brain_Movie

%% 1) Load in atlas data and annotation data
parameterStruct = load('brainViewer_params.mat');
[annotationVolume,annotationTable,acronymTree,annotationTree] = ...
    loadAllData_bv(parameterStruct);
% The acronym tree contains the abbreviated names of each brain region. The
% annotation tree contains the associated numeric annotation in the brain
% volume. 

%% Load in POm and Whole Brain Volumes
if exist(fullfile("brainViewer_output/PO_volume_left.mat"),'file')
    PO_volume = load(fullfile("brainViewer_output/PO_volume_left.mat"));
else
    PO_volume = atlasRegionVolume("PO",annotationVolume,acronymTree,annotationTree,...
        'Hemisphere','left');
    save("brainViewer_output\PO_volume_left.mat",'-struct',"PO_volume")
end
if exist(fullfile("brainViewer_output/WholeBrainSurface.mat"),'file')
    brain_volume = load(fullfile("brainViewer_output/WholeBrainSurface.mat"));
end

%% Plotting
figure;
brainPlot3D({brain_volume,PO_volume},'Color',[0.8 0.8 0.8 ; 0 0 1],'Alpha',[1 0.3]);
camlight
lighting gouraud

%% Rotating 3D grayscale brian
fig = figure; ax = axes; brainPlot3D(brain_volume,'Color',[0.8 0.8 0.8],'Alpha',1);
camlight
lighting gouraud

degree_rate = 0.5; % Degrees per frame

set(ax, 'ZDir', 'reverse')
axis(ax, 'equal');
axis(ax, 'vis3d');
axis(ax, 'off');
f = get(ax, 'Parent');

n_rotations = 2;
total_degrees = 0;
i = 1;
% Rotate over Z axis
while total_degrees < (n_rotations * 360)
    ax.View = ax.View + [degree_rate , 0];
    total_degrees = total_degrees + degree_rate;
    F(i) = getframe(fig);
    disp(size(F(i).cdata))
    drawnow
    i = i+1;
end
%%
writerObj = VideoWriter('RotatingBrain.avi');
writerObj.FrameRate = 30;
open(writerObj);
for i=1:length(F)
    frame = F(i) ;    
    writeVideo(writerObj, frame);
    inlinePercent(i,length(F),1);
end
% close the writer object
close(writerObj);
