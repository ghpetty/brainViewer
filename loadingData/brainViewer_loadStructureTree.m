function structureTreeTable = brainViewer_loadStructureTree(fn)
% structureTreeTable = brainViewer_loadStructureTree(fn)
% Wrapper function for loading in the structure_tree.csv file for
% brainViewer. Adapted (mostly directly copied) from the Cortex Lab's
% version of loadStructureTree.


[~, fnBase] = fileparts(fn);
if contains(fnBase, '2017')
    mode = '2017'; 
else
    mode = 'old'; 
end

fid = fopen(fn, 'r');

% if strcmp(mode, 'old')
%     titles = textscan(fid, '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s', 1, 'delimiter', ',');
%     titles = cellfun(@(x)x{1}, titles, 'uni', false);
%     titles{1} = 'index'; % this is blank in the file
%     
%     data = textscan(fid, '%d%s%d%s%d%s%d%d%d%d%d%s%s%d%d%s%d%s%s%d%d', 'delimiter', ',');
%     
% elseif strcmp(mode, '2017')
    titles = textscan(fid, repmat('%s', 1, 21), 1, 'delimiter', ',');
    titles = cellfun(@(x)x{1}, titles, 'uni', false);
    
    data = textscan(fid, ['%d%d%s%s'... % 'id'    'atlas_id'    'name'    'acronym'
                          '%s%d%d%d'... % 'st_level'    'ontology_id'    'hemisphere_id'    'weight'
                          '%d%d%d%d'... % 'parent_structure_id'    'depth'    'graph_id'     'graph_order'
                          '%s%s%d%s'... % 'structure_id_path'    'color_hex_triplet' neuro_name_structure_id neuro_name_structure_id_path
                          '%s%d%d%d'... % 'failed'    'sphinx_id' structure_name_facet failed_facet
                          '%s'], 'delimiter', ','); % safe_name
    
    titles = ['index' titles];
    data = [(0:numel(data{1})-1)' data];    

% end


structureTreeTable = table(data{:}, 'VariableNames', titles);

fclose(fid);