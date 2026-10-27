function plotSampleDistribution(ax1,ax2,r)
a=r.data.y(r.trainRows); b=r.data.y(r.testRows); blue=[0.15 0.45 0.8]; orange=[0.92 0.48 0.12];
[~,edges]=histcounts([a;b]); cla(ax1); cla(ax2);
histogram(ax1,a,edges,'FaceColor',blue,'FaceAlpha',0.5); hold(ax1,'on');
histogram(ax1,b,edges,'FaceColor',orange,'FaceAlpha',0.5); hold(ax1,'off');
xlabel(ax1,r.data.targetName,'Interpreter','none'); ylabel(ax1,'Count');
legend(ax1,{sprintf('Train (n=%d)',numel(a)),sprintf('Test (n=%d)',numel(b))});
title(ax1,'Target distribution'); grid(ax1,'on');
boxchart(ax2,ones(size(a)),a,'BoxFaceColor',blue); hold(ax2,'on');
boxchart(ax2,2*ones(size(b)),b,'BoxFaceColor',orange); hold(ax2,'off');
xticks(ax2,[1 2]); xticklabels(ax2,{'Train','Test'}); xlim(ax2,[0.5 2.5]);
ylabel(ax2,r.data.targetName,'Interpreter','none'); grid(ax2,'on');
title(ax2,{'Target boxplot',sprintf('Train: n=%d, mean=%.4g, SD=%.4g',numel(a),mean(a),std(a,0)), ...
    sprintf('Test: n=%d, mean=%.4g, SD=%.4g',numel(b),mean(b),std(b,0))});
stylePlotAxes(ax1); stylePlotAxes(ax2);
end
