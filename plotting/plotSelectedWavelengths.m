function plotSelectedWavelengths(ax,r)
cla(ax); average=mean(r.preprocessed(r.trainRows,:),1);
background=plot(ax,r.data.wavelength,average,'Color',[0.24 0.39 0.55],'LineWidth',1.8);
hold(ax,'on');
if strcmp(r.selection.method,'None')
    title(ax,'Full spectrum (no selection)'); legend(ax,background,'Mean training spectrum','Location','southeast');
else
    selected=r.selection.indices;
    dots=scatter(ax,r.data.wavelength(selected),average(selected),44, ...
        [0.82 0.23 0.27],'filled','MarkerEdgeColor','w','LineWidth',0.6);
    title(ax,sprintf('%s · %d bands selected',r.selection.method,numel(selected)));
    legend(ax,[background,dots],{'Mean training spectrum','Selected bands'},'Location','southeast');
end
hold(ax,'off'); xlabel(ax,r.data.wavelengthLabel); ylabel(ax,'Mean training spectrum');
setWavelengthAxis(ax,r.data.wavelength); stylePlotAxes(ax);
end
