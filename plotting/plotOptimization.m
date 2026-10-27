function plotOptimization(ax,history,c,total)
cla(ax);
if isempty(history), title(ax,'No parameter evaluations yet'); stylePlotAxes(ax); return; end
plot(ax,[history.iteration],[history.score],'.-','Color',[0.15 0.45 0.8]); hold(ax,'on');
plot(ax,[history.iteration],[history.bestScore],'r-','LineWidth',1.6); hold(ax,'off');
xlabel(ax,'Parameter evaluation'); ylabel(ax,['CV mean fold ' c.metric]);
title(ax,sprintf('%s · %d/%d · best %s = %.5g',c.optimizer,numel(history),total,c.metric,history(end).bestScore));
legend(ax,{'Actual score','Best so far'},'Location','best'); grid(ax,'on');
stylePlotAxes(ax);
end
