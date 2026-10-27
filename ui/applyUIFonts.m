function applyUIFonts(parent,fontSize)
% Keep typography local to the application rather than changing MATLAB defaults.
if nargin<2, fontSize=18; end
objects=findall(parent,'-property','FontName');
for k=1:numel(objects), objects(k).FontName='Microsoft YaHei'; end
objects=findall(parent,'-property','FontSize');
for k=1:numel(objects)
    % Plot fonts are sized separately for the three-panel diagnostics layout.
    if isgraphics(objects(k),'axes') || ~isempty(ancestor(objects(k),'axes')) || ...
            isa(objects(k),'matlab.graphics.illustration.Legend') || isa(objects(k),'matlab.graphics.illustration.ColorBar')
        continue;
    end
    if objects(k).FontSize<fontSize, objects(k).FontSize=fontSize; end
end
end
