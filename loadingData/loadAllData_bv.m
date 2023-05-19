function [annotationVolume,annotationTable,acronymTree,annotationTree] = ...
    loadAllData_bv(parameterStruct)
% Load the annotation information and the 3D brain volume into memory using
% the information stored in the parameter struct. The parameter struct is
% created by brainViewer_setup.

ps = parameterStruct;
disp('Loading annotation volume...')
annotationVolume = readNPY(fullfile(ps.ReferenceAtlasPath,ps.AnnotationVolumeFilename));
disp('Loading annotation table...')
annotationTable = brainViewer_loadStructureTree(fullfile(ps.ReferenceAtlasPath,ps.TreeCSVFilename));
disp('Parsing table into tree object...')
[acronymTree,annotationTree] = structureTreeFromCSV(annotationTable);
disp('Done!')