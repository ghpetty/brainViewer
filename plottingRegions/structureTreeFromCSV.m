function [acronymTree,annotationTree] = structureTreeFromCSV(tree_table)
% structureTree = structureTreeFromCSV(tree_table)
% Converts the Allen Brain Atlas structure tree CSV table to a 'tree' class
% (from file exchange: 
% https://www.mathworks.com/matlabcentral/fileexchange/35623-tree-data-structure-as-a-matlab-class
% 

idTree = tree(997); % 'root' structure has id 997 
maxDepth = max(tree_table.depth);
disp('Constructing tree...');
tic
for d = 1:maxDepth
    currNodes = tree_table(tree_table.depth == d ,:);
    n_nodes = height(currNodes);
    for n = 1:n_nodes
        % Get index of parent node:
        % - Tree of logical values where node value == the parent we are
        %   looking for:
        matchTree = idTree == currNodes.parent_structure_id(n);
        % - The index of the matching logical value:
        matchInd = find([matchTree.Node{:}]);
        % - Add next node to this parent node
        idTree = idTree.addnode(matchInd,currNodes.id(n));
    end
end

% Copy this tree, then use the id values in the nodes to create trees of
% acronyms and indices within the brain annotation volume
acronymTree = tree(idTree);
annotationTree = tree(idTree);
% Doesn't matter how we iterate, but breadth-first is sensible for this 
% tree structure and should make debugging a bit easier.
iter = idTree.breadthfirstiterator; 
% disp('Identifying acronyms and annotation values...');
for i = iter
    currID = idTree.get(i);
    acronym = (tree_table.acronym(tree_table.id == currID));
    acronymTree = acronymTree.set(i,acronym{:});
    annotationVal = tree_table.index(tree_table.id == currID) + 1;
    annotationTree = annotationTree.set(i,annotationVal);
end

