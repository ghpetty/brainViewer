function h = brainPlot2D(perimeterData,plane,varargin)
% brainPlot2D(perimeterData,plane)
% Plots the perimeters of each element in perimeterData, scaled and
% labelled according to "plane" (coronal, transverse, or sagittal).
% Perimeter data is either a nx2 matrix of x and y points (each point
% corresponding to a row), or a cell array of multipler of such matrices.
%
% h = brainPlot2D(perimeterData,plane)
% Return the resulting line objects as graphic handles
% 
% brainPlot2D(___,'Color',colorspec)
% Specify colors as a color spec ('r' or [1 0 0], for example), or a cell
% array of color specs, where each element corresponds to a single region.
%
% brainPlot2D(___,'Fill',true|false (default))
% Rather than plot the regions as lines, plot them as patch objects.
%
% brainPlot2D(___,'Alpha',alpha)
% Specify the alpha value of the regions. Only works when "Fill" is set to
% true
%
% brainPlot2D(___,'Parent',parent)
% Specify the parent axes.

p = inputParser;
addRequired(p,'perimeterData',@(x) iscell(x) || (isnumeric(x) && size(x,2) ==2));
addRequired(p,'plane',@(x) ismember(lower(x),["coronal" "sagittal" "transverse"]));
addParameter(p,'Color',{},@(x) iscell(x) || isnumeric(x) || isstring(x) || ischar(x));
addParameter(p,'Fill',false,@(x) islogical(x) && isscalar(x));
addParameter(p,'Alpha',0.2,@(x) isnumeric(x) && isvector(x));
addParameter(p,'Parent',gca)

parse(p,perimeterData,plane,varargin{:});

parent = p.Results.Parent;
wasHeld = ishold(parent);
hold(parent,'on');

if ~iscell(perimeterData)
    perimeterData = {perimeterData};
end

nRegions = length(perimeterData);
h = gobjects(nRegions,1);

if ~p.Results.Fill % Default

for ii = 1:nRegions
    perim = perimeterData{ii};
    h(ii) = plot(p.Results.Parent,perim(:,1),perim(:,2));
end

if ~ismember('Color',p.UsingDefaults)
    for ii = 1:nRegions
        if ~iscell(p.Results.Color)
            h(ii).Color = p.Results.Color;
        else
            h(ii).Color = p.Results.Color{ii};
        end
    end
end


else % Patches
    if ismember('Color',p.UsingDefaults)
        colors = lines(nRegions);
        colors = mat2cell(colors,ones(nRegions,1),3);
    elseif ~iscell(p.Results.Color)
        colors = repmat({p.Results.Color},nRegions,1);
    else
        colors = p.Results.Color;
    end
    for ii = 1:nRegions
        perim = perimeterData{ii};
        % If the region is split across hemispheres, we divide them into two patches
        if any(isnan(perim))
            perim(isnan(perim(:,1)),:) = [];
            X = reshape(perim(:,1),[],2);
            Y = reshape(perim(:,2),[],2);
        else
            X = perim(:,1);
            Y = perim(:,2);
        end
        h(ii) = patch(X,Y,colors{ii},'FaceAlpha',p.Results.Alpha,'EdgeColor','none');
        
    end
end






set(p.Results.Parent,'ydir','reverse');
switch lower(plane)
    case 'coronal'
        ylabel('Dorsal - Ventral');
        xlabel('Medial - Lateral');
    case 'sagittal'
        ylabel('Dorsal - Ventral');
        xlabel('Anterior - Posterior');
    case 'transverse'
        ylabel('Anterior-Posterior');
        xlabel('Medial-Lateral');
end

set(parent,'DataAspectRatio',[1 1 1]);


if wasHeld
    hold(parent,'off');
end
