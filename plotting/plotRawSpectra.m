function plotRawSpectra(ax,d)
cla(ax); plot(ax,d.wavelength,d.X','Color',[0.79 0.83 0.88],'LineWidth',0.6);
hold(ax,'on'); h=plot(ax,d.wavelength,mean(d.X,1),'Color',[0.78 0.25 0.27],'LineWidth',2.2); hold(ax,'off');
xlabel(ax,d.wavelengthLabel); ylabel(ax,'Reflectance'); title(ax,'Raw spectra');
legend(ax,h,'Mean spectrum','Location','best'); setWavelengthAxis(ax,d.wavelength); stylePlotAxes(ax);
end
