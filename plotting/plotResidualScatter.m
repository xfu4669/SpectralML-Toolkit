function plotResidualScatter(ax,r,subset)
if nargin<3, subset='All'; end
series=predictionSeries(r,subset); x=vertcat(series.predicted); residual=vertcat(series.residual);
cla(ax); hold(ax,'on');
[center,lower,upper,middle]=residualTrend(x,residual);
if numel(center)>1 && max(center)>min(center)
    fill(ax,[center;flipud(center)],[lower;flipud(upper)],[0.94 0.67 0.48], ...
        'FaceAlpha',0.22,'EdgeColor','none','HandleVisibility','off');
end
handles=gobjects(0); labels={};
for k=1:numel(series)
    s=series(k);
    handles(end+1)=scatter(ax,s.predicted,s.residual,32,s.color,'filled', ...
        'MarkerFaceAlpha',0.65,'MarkerEdgeColor','none');
    labels{end+1}=s.name;
end
if numel(center)>1 && max(center)>min(center)
    plot(ax,center,middle,'Color',[0.78 0.25 0.27],'LineWidth',2,'HandleVisibility','off');
end
yline(ax,0,'--','Color',[0.38 0.41 0.45],'LineWidth',1.1,'HandleVisibility','off');
hold(ax,'off');
span=max(x)-min(x); pad=max(0.06*span,1e-6*max(1,max(abs(x))));
xlim(ax,[min(x)-pad,max(x)+pad]);
height=max(abs(residual)); if height==0, height=1e-6*max(1,max(abs(x))); end
ylim(ax,[-1.12*height 1.12*height]);
xlabel(ax,'Predicted'); ylabel(ax,'Residual (observed - predicted)'); title(ax,'Residual scatter');
legend(ax,handles,labels,'Location','best'); stylePlotAxes(ax);
end
function [center,lower,upper,middle]=residualTrend(x,residual)
n=numel(x); bins=min(max(4,round(sqrt(n))),max(1,floor(n/3)));
[~,order]=sort(x); boundaries=round(linspace(0,n,bins+1));
center=zeros(bins,1); lower=center; upper=center; middle=center;
for k=1:bins
    rows=order(boundaries(k)+1:boundaries(k+1));
    center(k)=median(x(rows)); q=quantile(residual(rows),[0.25 0.5 0.75]);
    lower(k)=q(1); middle(k)=q(2); upper(k)=q(3);
end
end
