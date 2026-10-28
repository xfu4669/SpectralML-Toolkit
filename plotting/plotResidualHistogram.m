function plotResidualHistogram(ax,r,subset)
if nargin<3, subset='All'; end
series=predictionSeries(r,subset); residual=vertcat(series.residual);
binCount=max(6,min(24,ceil(sqrt(numel(residual)))));
[~,edges]=histcounts(residual,binCount); cla(ax,'reset');
% Reused UI axes can retain manual limits/ticks from an earlier drawing.
ax.XLimMode='auto'; ax.YLimMode='auto'; ax.XTickMode='auto'; ax.YTickMode='auto';
ax.XScale='linear'; ax.YScale='linear'; hold(ax,'on');
peak=0;
handles=gobjects(0); labels={};
for k=1:numel(series)
    s=series(k);
    bars=histogram(ax,s.residual,edges,'Normalization','count','FaceColor',s.color,'FaceAlpha',0.56, ...
        'EdgeColor',[1 1 1],'LineWidth',0.5);
    handles(end+1)=bars; peak=max([peak,bars.Values]);
    labels{end+1}=s.name;
end
% Empirical Gaussian-kernel smoothing, scaled to histogram counts (not a fitted normal curve).
q=quantile(residual,[0.25 0.75]); widths=[std(residual,0),(q(2)-q(1))/1.349]; widths=widths(widths>0);
if numel(residual)>1 && ~isempty(widths)
    bandwidth=0.9*min(widths)*numel(residual)^(-0.2);
    x=linspace(edges(1),edges(end),180);
    z=(x(:)-residual(:)')/bandwidth;
    density=mean(exp(-0.5*z.^2),2)/(bandwidth*sqrt(2*pi));
    y=density*numel(residual)*mean(diff(edges));
    peak=max(peak,max(y));
    handles(end+1)=plot(ax,x,y,'Color',[0.78 0.25 0.27],'LineWidth',2);
    labels{end+1}='Smooth trend';
end
xline(ax,0,'--','Color',[0.38 0.41 0.45],'LineWidth',1,'HandleVisibility','off');
hold(ax,'off'); xlim(ax,[edges(1) edges(end)]);
% Fit both histogram bars and the count-scaled trend, with 15% headroom.
target=max(1,1.15*peak); rough=target/5;
magnitude=10^floor(log10(max(rough,1))); steps=[1 2 5 10]*magnitude;
step=steps(find(steps>=rough,1)); upper=step*ceil(target/step);
ylim(ax,[0 upper]); yticks(ax,0:step:upper); ytickformat(ax,'%g');
xlabel(ax,'Residual (observed - predicted)'); ylabel(ax,'Count'); title(ax,'Residual distribution');
legend(ax,handles,labels,'Location','northeast'); stylePlotAxes(ax);
end
