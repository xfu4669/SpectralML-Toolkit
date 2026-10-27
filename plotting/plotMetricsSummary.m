function plotMetricsSummary(ax,r)
% Draw the same six-row comparison table as the application using graphics primitives.
cla(ax); axis(ax,'off'); xlim(ax,[0 1]); ylim(ax,[0 1]); hold(ax,'on');
cells=[{'Dataset','Train','CV','Test'};metricsComparisonData(r)];
edges=[0,0.22,0.48,0.74,1]; top=0.94; rowHeight=0.09;
for row=1:size(cells,1)
    bottom=top-row*rowHeight;
    if row==1, background=[0.90 0.94 0.98];
    elseif mod(row,2)==0, background=[1 1 1];
    else, background=[0.96 0.975 0.99]; end
    rectangle(ax,'Position',[0,bottom,1,rowHeight],'FaceColor',background,'EdgeColor','none');
    for column=1:size(cells,2)
        weight='normal'; if row==1 || column==1, weight='bold'; end
        text(ax,mean(edges(column:column+1)),bottom+rowHeight/2,cells{row,column}, ...
            'FontName','Microsoft YaHei','FontSize',11,'FontWeight',weight, ...
            'Color',[0.20 0.29 0.39],'HorizontalAlignment','center', ...
            'VerticalAlignment','middle','Interpreter','none');
    end
    plot(ax,[0 1],[bottom bottom],'Color',[0.85 0.89 0.93],'LineWidth',0.6);
end
hold(ax,'off');
end
