function exportFigures(r,folder,formats,cancel,progress)
if nargin<3 || isempty(formats), formats={'tiff'}; end
if nargin<4, cancel=[]; end
if nargin<5, progress=[]; end
requested=string(formats);
assert(all(strcmpi(requested(:),'tiff') | strcmpi(requested(:),'tif')), ...
    'SpectralML:Export','Figures support TIFF export only.');
names={'01_raw_spectra','02_sample_distribution','03_preprocessed_spectra', ...
    '04_selected_wavelengths','05_optimization','06_predictions'};
pageNames={'Raw spectra','Sample distribution','Processed spectra','Selected wavelengths','Optimization','Prediction results'};
for page=1:6
    checkCancelled(cancel);
    if ~isempty(progress)
        progress((page-1)/6,sprintf('Exporting TIFF %d/6: %s',page,pageNames{page}));
    end
    fig=figure('Visible','off','Color','w','Position',[100 100 1200 650]);
    cleaner=onCleanup(@()close(fig));
    if page==6
        fig.Position=[100 100 2000 740];
        tl=tiledlayout(fig,1,7,'Padding','compact','TileSpacing','compact');
        predictionAxes=gobjects(1,3);
        predictionAxes(1)=nexttile(tl,[1 2]); predictionAxes(2)=nexttile(tl,[1 2]); predictionAxes(3)=nexttile(tl,[1 2]);
        plotPredictionDiagnostics(predictionAxes,r,'All');
        stats=nexttile(tl); plotMetricsSummary(stats,r);
        exportTarget=tl;
    elseif page==2
        tl=tiledlayout(fig,1,2,'Padding','compact'); a=nexttile(tl); b=nexttile(tl);
        plotSampleDistribution(a,b,r);
        exportTarget=tl;
    else
        a=axes(fig); exportTarget=a;
        switch page
            case 1, plotRawSpectra(a,r.data);
            case 3, plotPreprocessedSpectra(a,r,'All');
            case 4, plotSelectedWavelengths(a,r);
            case 5, plotOptimization(a,r.optimization.history,r.config,r.optimization.totalPlanned);
        end
    end
    checkCancelled(cancel);
    exportgraphics(exportTarget,fullfile(folder,[names{page} '.tiff']), ...
        'Resolution',300,'BackgroundColor','white');
    clear cleaner
    if ~isempty(progress)
        progress(page/6,sprintf('Saved TIFF %d/6: %s',page,pageNames{page}));
    end
end
end
