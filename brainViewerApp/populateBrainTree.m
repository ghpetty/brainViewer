function populateBrainTree(app,fullNameTree)
% Sub function of bvApp to populate the checkbox tree with info from the
% annotation tree.

bfi = fullNameTree.breadthfirstiterator;
% Build another tree structure, which will hold the ui elements.
% This will mirror the region tree, so we can iterate through them both
% and get the correct parents for each node in the UI tree
uiTree = tree(fullNameTree,'clear'); % Tree of same structure but empty values
uiTree = uiTree.set(1,app.BrainTree); % Root is the checklist itself


for ii = bfi(2:end) % Skip first value since it is the root
    parentNode = uiTree.Parent(ii);
    parentUI = uiTree.Node{parentNode};
    uiTree = uiTree.set(ii,(uitreenode("Parent",parentUI,...
        "Text",fullNameTree.get(ii))));
end