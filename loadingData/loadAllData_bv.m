function [annotationVolume,annotationTable,acronymTree,annotationTree,fullNameTree] = ...
    loadAllData_bv(parameterStruct,dataToGet)
%[annotationVolume,annotationTable,acronymTree,annotationTree] = ...
%    loadAllData_bv(parameterStruct)
% Load the annotation information and the 3D brain volume into memory using
% the information stored in the parameter struct. The parameter struct is
% created by brainViewer_setup.
%
% [annotationVolume,annotationTable,acronymTree,annotationTree] = ...
%    loadAllData_bv(parameterStruct,dataToGet)
% Specify 'dataToGet' as a char array, cell array of chars, or string
% array.
% Valid values are 'all' , 'volume', or 'annotation'
% Returns only the specified variables, other vars are returned as NaNs

if nargin == 1
    dataToGet = "all";
else
    dataToGet = lower(string(dataToGet));
end

ps = parameterStruct;
if dataToGet == "all" || any(dataToGet == "volume")
    disp('Loading annotation volume...')
    annotationVolume = readNPY(fullfile(ps.ReferenceAtlasPath,ps.AnnotationVolumeFilename));
else
    annotationVolume = nan;
end

if dataToGet == "all" || any(dataToGet == "annotation")
    disp('Loading annotation table...')
    annotationTable = brainViewer_loadStructureTree(fullfile(ps.ReferenceAtlasPath,ps.TreeCSVFilename));
    disp('Parsing table into tree object...')
    [acronymTree,annotationTree,fullNameTree] = structureTreeFromCSV(annotationTable);
    disp('Done!')
else
    acronymTree = nan; annotationTree = nan; fullNameTree = nan;
end