function plotPreprocessedSpectra(ax,r,subset)
if nargin<3, subset='All'; end
switch subset
    case 'Train', rows=r.trainRows;
    case 'Test', rows=r.testRows;
    otherwise, rows=1:size(r.preprocessed,1);
end
X=r.preprocessed(rows,:); cla(ax);
plot(ax,r.data.wavelength,X','Color',[0.79 0.83 0.88],'LineWidth',0.6); hold(ax,'on');
h=plot(ax,r.data.wavelength,mean(X,1),'Color',[0.78 0.25 0.27],'LineWidth',2.2); hold(ax,'off');
xlabel(ax,r.data.wavelengthLabel); ylabel(ax,'Processed spectral value');
switch r.config.preprocessing
    case {'Raw','SG','MSC'}, ylabel(ax,'Reflectance');
    case 'FD', ylabel(ax,'First derivative');
    case 'SD', ylabel(ax,'Second derivative');
    case 'FOD', ylabel(ax,sprintf('Fractional derivative (%.2g)',r.config.preprocessParams.alpha));
    case 'Detrend', ylabel(ax,'Detrended reflectance');
    case 'MinMax', ylabel(ax,'Normalized value');
    case {'ZScore','SNV'}, ylabel(ax,'Standardized value');
end
title(ax,[r.config.preprocessing ' · ' subset],'Interpreter','none');
legend(ax,h,'Mean spectrum','Location','best'); setWavelengthAxis(ax,r.data.wavelength); stylePlotAxes(ax);
end
