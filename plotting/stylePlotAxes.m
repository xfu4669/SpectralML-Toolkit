function stylePlotAxes(ax)
% Shared appearance for application plots and exported figures.
ax.FontName='Microsoft YaHei'; ax.FontSize=14; ax.LineWidth=0.9;
ax.Color=[1 1 1]; ax.XColor=[0.25 0.28 0.33]; ax.YColor=[0.25 0.28 0.33];
ax.Box='off'; ax.TickDir='out'; ax.Layer='top';
ax.XGrid='on'; ax.YGrid='on'; ax.GridColor=[0.45 0.50 0.57]; ax.GridAlpha=0.12;
ax.Title.FontName='Microsoft YaHei'; ax.Title.FontSize=18;
ax.Title.FontWeight='bold'; ax.Title.Color=[0 0 0];
ax.XLabel.FontSize=14; ax.YLabel.FontSize=14;
if ~isempty(ax.Legend)
    ax.Legend.FontName='Microsoft YaHei'; ax.Legend.FontSize=12; ax.Legend.Box='off';
end
end
