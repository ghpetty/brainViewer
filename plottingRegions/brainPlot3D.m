function h = brainPlot3D(varargin)
% brainPlot3D(patchData)
% Plot the volume data stored in the struct array 'patchData' onto 3D axes.
% Axes are scaled and labelled according to the Allen Brain Atlas.
% Input 'patchData' is a cell array of structs where each struct has the
% fields 'vertices' and 'faces' to describe patches
% -- or---
% a 1xn struct array with the same field names.

p = inputParser;
addRequired(p,'patchData',@(x) isstruct(x) || iscell(x));
addParameter(p,'Color',{},@(x) iscell(x) || isnumeric(x) || isstring(x) || ischar(x));
addParameter(p,'Alpha',0.2,@(x) isnumeric(x) && isvector(x))
addParameter(p,'Parent',gca)
parse(p,varargin{:});

parent = p.Results.Parent;
patchData = p.Results.patchData;
% If given a cell array, concatenate into a struct array:
if iscell(patchData)
    patchData = vertcat(patchData{:});
end
nRegions = length(patchData);
color = checkColor(p.Results.Color,nRegions);
alpha = checkAlpha(p.Results.Alpha,nRegions);
wasHeld = ishold(parent);

hold(parent,'on');
h = gobjects(nRegions,1);
for i = 1:nRegions
    h(i) = patch(parent,patchData(i),'FaceColor',color(i,:),'EdgeColor','none','FaceAlpha',alpha(i));
end

set(parent,'ZDir','reverse','DataAspectRatio',[1 1 1],...
    'View',[-50  25]);

if ~wasHeld
    hold(parent,'off')
end

% -- Sub functions --
function col = checkColor(c_in,nRegions)
if isempty(c_in)
    col = zeros(nRegions,3);
    defCol = colororder;
    for i = 1:nRegions 
        col(i,:) = defCol(1,:);
        defCol = circshift(defCol,1,1);
    end
elseif nRegions == 1
    col = validatecolor(c_in);
else
    errMsg = 'Expected a color value for each region to plot';
    if iscell(c_in)
        if length(c_in)~=nRegions
            error(errMsg)
        end
        col = validatecolor(c_in,'multiple');
    else 
        if size(c_in,1) ~=nRegions
            error(errMsg)
        end
        col = c_in;
    end
end
    
function alph = checkAlpha(alph_in,nRegions)
if isscalar(alph_in)
    alph = repmat(alph_in,nRegions,1);
elseif length(alph_in) ~= nRegions
    error('Expected an alpha value for each region')
else
    alph = alph_in;
end
