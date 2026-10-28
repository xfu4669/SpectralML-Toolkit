function plotPrediction(ax,r,subset,showMetrics)
if nargin<3, subset='All'; end
if nargin<4, showMetrics=true; end
cla(ax,'reset'); hold(ax,'on'); values=[]; handles=gobjects(0); labels={}; series=predictionSeries(r,subset);
for k=1:numel(series)
    s=series(k);
    handles(end+1)=scatter(ax,s.observed,s.predicted,38,s.color,'filled', ...
        'MarkerFaceAlpha',0.78,'MarkerEdgeColor','w','LineWidth',0.45);
    labels{end+1}=s.name; values=[values;s.observed;s.predicted]; %#ok<AGROW>
end
lo=min(values); hi=max(values); pad=max(0.05*(hi-lo),eps); limits=[lo-pad,hi+pad];
plot(ax,limits,limits,'--','Color',[0.35 0.38 0.42],'LineWidth',1.2,'HandleVisibility','off'); hold(ax,'off');
axis(ax,'equal'); xlim(ax,limits); ylim(ax,limits);
xlabel(ax,'Observed'); ylabel(ax,'Predicted');
title(ax,'Observed vs predicted'); legend(ax,handles,labels,'Location','southeast');
if showMetrics
    lines=cell(3,1); names={'Train','CV','Test'};
    for i=1:3
        m=r.metrics.(names{i}); lines{i}=sprintf('%s: R²=%.4g, RMSE=%.4g, RPD=%.4g',names{i},m.R2,m.RMSE,m.RPD);
    end
    text(ax,0.02,0.98,strjoin(lines,newline),'Units','normalized','VerticalAlignment','top', ...
        'FontSize',13,'BackgroundColor','w','Interpreter','none');
end
stylePlotAxes(ax);
end
