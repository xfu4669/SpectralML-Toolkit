classdef SpectralML < handle
    %SPECTRALML Interactive spectral regression workflow.
    properties
        Figure
        Config
        Data = []
        Result = []
    end
    properties (Access=private)
        UI = struct
        Axes
        Preview = []
        Busy = false
        CancelRequested = false
        Messages = {}
        Inputs = {}
    end
    methods
        function app=SpectralML
            addpath(genpath(fileparts(mfilename('fullpath'))));
            app.Config=defaultConfig;
            app.buildUI;
        end
        function delete(app)
            if ~isempty(app.Figure) && isvalid(app.Figure), delete(app.Figure); end
        end
    end
    methods (Access=private)
        function buildUI(app)
            options=toolkitOptions;
            app.Figure=uifigure('Name','SpectralML-Toolkit V1.0','Position',[60 35 1580 1000], ...
                'Color',[0.97 0.98 0.99],'AutoResizeChildren','off', ...
                'CloseRequestFcn',@(~,~)app.closeApp);
            app.Figure.UserData=app;
            root=uigridlayout(app.Figure,[7 1]);
            root.RowHeight={58,52,48,48,48,'1x',200}; root.Padding=[22 16 22 16]; root.RowSpacing=10;
            titleRow=uigridlayout(root,[1 2]); titleRow.ColumnWidth={'1x',54}; titleRow.Padding=[0 0 0 0];
            uilabel(titleRow,'Text','SpectralML-Toolkit V1.0','FontSize',28,'FontWeight','bold');
            app.UI.Settings=uibutton(titleRow,'Text','⚙','FontSize',26,'Tooltip','Parameters', ...
                'BackgroundColor',[1 1 1],'ButtonPushedFcn',@(~,~)app.settings);
            row=uigridlayout(root,[1 4]); row.ColumnWidth={148,148,164,'1x'}; row.Padding=[0 0 0 0]; row.ColumnSpacing=12;
            app.UI.Import=uibutton(row,'Text','Import data','BackgroundColor',[1 1 1],'ButtonPushedFcn',@(~,~)app.import);
            app.UI.Export=uibutton(row,'Text','Export results','BackgroundColor',[1 1 1],'Enable','off','ButtonPushedFcn',@(~,~)app.export);
            app.UI.Run=uibutton(row,'Text','Run analysis','FontWeight','bold','BackgroundColor',[0.14 0.39 0.67],'FontColor','w', ...
                'ButtonPushedFcn',@(~,~)app.run);
            app.UI.File=uilabel(row,'Text','No data imported','WordWrap','on','Interpreter','none');
            row=uigridlayout(root,[1 7]); row.ColumnWidth={156,176,120,100,120,100,'1x'}; row.Padding=[0 0 0 0];
            uilabel(row,'Text','Sample split','FontWeight','bold');
            app.UI.Split=uidropdown(row,'Items',{'Random','KS','SPXY'},'Value',app.Config.split, ...
                'ValueChangedFcn',@(~,~)app.changeMethod('split'));
            uilabel(row,'Text','Train (%)');
            app.UI.Train=uieditfield(row,'numeric','Value',80,'ValueChangedFcn',@(~,~)app.ratioChanged(true));
            uilabel(row,'Text','Test (%)');
            app.UI.Test=uieditfield(row,'numeric','Value',20,'ValueChangedFcn',@(~,~)app.ratioChanged(false));
            app.UI.Count=uilabel(row,'Text','','WordWrap','on');
            row=uigridlayout(root,[1 4]); row.ColumnWidth={156,'1x',156,'1x'}; row.Padding=[0 0 0 0];
            uilabel(row,'Text','Preprocessing','FontWeight','bold');
            app.UI.Pre=uidropdown(row,'Items',options.preprocessingLabels,'ItemsData',options.preprocessing,'Value',app.Config.preprocessing, ...
                'ValueChangedFcn',@(~,~)app.changeMethod('preprocessing'));
            uilabel(row,'Text','Feature selection','FontWeight','bold');
            app.UI.Feature=uidropdown(row,'Items',options.features,'Value',app.Config.feature, ...
                'ValueChangedFcn',@(~,~)app.changeMethod('feature'));
            row=uigridlayout(root,[1 4]); row.ColumnWidth={156,'1x',156,'1x'}; row.Padding=[0 0 0 0];
            uilabel(row,'Text','Model','FontWeight','bold');
            app.UI.Model=uidropdown(row,'Items',options.models,'Value',app.Config.model, ...
                'ValueChangedFcn',@(~,~)app.changeMethod('model'));
            uilabel(row,'Text','Optimization','FontWeight','bold');
            app.UI.Optimization=uidropdown(row,'Items',{'Grid search','Random search','Bayesian optimization'}, ...
                'ItemsData',{'Grid','Random','Bayesian'},'Value',app.Config.optimizer, ...
                'ValueChangedFcn',@(~,~)app.optimizerChanged);
            app.UI.Tabs=uigridlayout(root,[2 1]); app.UI.Tabs.RowHeight={46,'1x'};
            app.UI.Tabs.Padding=[0 0 0 0]; app.UI.Tabs.RowSpacing=8;
            strip=uigridlayout(app.UI.Tabs,[1 6]); strip.ColumnWidth=repmat({'1x'},1,6);
            strip.Padding=[0 0 0 0]; strip.ColumnSpacing=6;
            pages=uigridlayout(app.UI.Tabs,[1 1]); pages.Padding=[0 0 0 0];
            names={'Raw spectra','Sample distribution','Processed spectra','Selected wavelengths','Optimization','Prediction results'};
            app.Axes=cell(1,6);
            app.UI.Pages=cell(1,6);
            app.UI.TabButtons=cell(1,6);
            for k=1:6
                app.UI.TabButtons{k}=uibutton(strip,'Text',names{k},'BackgroundColor',[1 1 1], ...
                    'ButtonPushedFcn',@(~,~)app.selectPage(k));
                tab=uipanel(pages,'BorderType','none','BackgroundColor',[1 1 1],'Visible','off');
                tab.Layout.Row=1; tab.Layout.Column=1;
                app.UI.Pages{k}=tab;
                if k==2
                    g=uigridlayout(tab,[1 2]); app.Axes{k}=[uiaxes(g),uiaxes(g)];
                elseif k==3
                    g=uigridlayout(tab,[2 1]); g.RowHeight={42,'1x'};
                    app.UI.PreSubset=uidropdown(g,'Items',{'All','Train','Test'},'ValueChangedFcn',@(~,~)app.redrawPre);
                    app.Axes{k}=uiaxes(g);
                elseif k==6
                    g=uigridlayout(tab,[1 4]); g.ColumnWidth={'1x','1x','1x',380};
                    g.Padding=[8 8 8 8]; g.ColumnSpacing=12;
                    app.Axes{k}=[uiaxes(g),uiaxes(g),uiaxes(g)];
                    stats=uigridlayout(g,[2 1]); stats.RowHeight={280,'1x'}; stats.Padding=[0 0 0 0];
                    app.UI.Metrics=uitable(stats,'Data',metricsComparisonData([]), ...
                        'ColumnName',{'Dataset','Train','CV','Test'},'RowName',[], ...
                        'ColumnEditable',false(1,4),'ColumnWidth',{82,100,100,'auto'}, ...
                        'BackgroundColor',[1 1 1;0.96 0.975 0.99]);
                    addStyle(app.UI.Metrics,uistyle('FontWeight','bold','FontColor',[0.20 0.34 0.49]),'column',1);
                elseif k==5
                    g=uigridlayout(tab,[2 1]); g.RowHeight={'1x',60}; app.Axes{k}=uiaxes(g);
                    app.UI.Best=uilabel(g,'Text','Best parameters: —','WordWrap','on','Interpreter','none');
                else
                    g=uigridlayout(tab,[1 1]); app.Axes{k}=uiaxes(g);
                end
            end
            footer=uigridlayout(root,[2 1]); footer.RowHeight={34,'1x'}; footer.Padding=[0 0 0 0]; footer.RowSpacing=8;
            app.UI.Status=uilabel(footer,'Text','Ready','WordWrap','on');
            app.UI.Log=uitextarea(footer,'Editable','off','Value',{''});
            app.Inputs={app.UI.Import,app.UI.Settings,app.UI.Split,app.UI.Pre,app.UI.Feature, ...
                app.UI.Model,app.UI.Train,app.UI.Test,app.UI.Optimization};
            applyUIFonts(app.Figure,18);
            app.selectPage(1);
            app.Figure.SizeChangedFcn=@(~,~)app.resize;
        end
        function selectPage(app,index)
            for k=1:numel(app.UI.Pages)
                selected=k==index;
                if selected
                    app.UI.Pages{k}.Visible='on';
                    app.UI.TabButtons{k}.BackgroundColor=[0.14 0.39 0.67];
                    app.UI.TabButtons{k}.FontColor=[1 1 1];
                    app.UI.TabButtons{k}.FontWeight='bold';
                else
                    app.UI.Pages{k}.Visible='off';
                    app.UI.TabButtons{k}.BackgroundColor=[1 1 1];
                    app.UI.TabButtons{k}.FontColor=[0.15 0.18 0.22];
                    app.UI.TabButtons{k}.FontWeight='normal';
                end
            end
        end
        function resize(app)
            % Retain a practical minimum canvas; grid layouts handle normal resizing.
            p=app.Figure.Position;
            if p(3)<1320 || p(4)<860
                p(3)=max(1320,p(3)); p(4)=max(860,p(4)); app.Figure.Position=p;
            end
        end
        function import(app)
            [file,path]=uigetfile({'*.csv;*.xlsx;*.xls','Spectral data (*.csv,*.xlsx,*.xls)'});
            if isequal(file,0), return; end
            try
                d=importData(fullfile(path,file));
            catch e
                if ismember(e.identifier,{'SpectralML:WavelengthRequired','SpectralML:ImportLayout'})
                    [d,ok]=importDialog(app.Figure,fullfile(path,file));
                    if ~ok, return; end
                else
                    app.showError(e); return;
                end
            end
            app.Data=d; app.invalidate;
            app.UI.File.Text=sprintf('%s | %d samples · %d bands · %.5g–%.5g | Y: %s', ...
                file,size(d.X,1),size(d.X,2),d.wavelength(1),d.wavelength(end),d.targetName);
            plotRawSpectra(app.Axes{1},d); applyUIFonts(app.Axes{1},18); app.updateCounts;
            if strcmp(d.wavelengthSource,'header')
                app.log(sprintf('Imported %s · Extracted %d wavelengths from the header',file,numel(d.wavelength)));
            else
                app.log(['Imported: ' file]);
            end
            app.UI.Status.Text='Data loaded. Select methods and run the analysis.';
        end
        function changeMethod(app,kind)
            if app.Busy, return; end
            app.Config.parameters=parameterCatalog(app.Config);
            switch kind
                case 'split', app.Config.split=app.UI.Split.Value;
                case 'preprocessing'
                    app.Config.preprocessing=app.UI.Pre.Value;
                    app.Config.preprocessParams=app.Config.parameters.preprocessing.(app.Config.preprocessing);
                case 'feature'
                    app.Config.feature=app.UI.Feature.Value;
                    app.Config.featureParams=app.Config.parameters.features.(app.Config.feature);
                case 'model'
                    app.Config.model=app.UI.Model.Value;
                    parameters=app.Config.parameters.models.(app.Config.model);
                    app.Config.modelParams=parameters.fixed; app.Config.searchSpace=parameters.space;
            end
            app.invalidate;
        end
        function optimizerChanged(app)
            if app.Busy, return; end
            app.Config.optimizer=app.UI.Optimization.Value; app.invalidate;
        end
        function ratioChanged(app,trainingChanged)
            previous=app.Config.trainRatio;
            if trainingChanged, ratio=app.UI.Train.Value/100; else, ratio=1-app.UI.Test.Value/100; end
            valid=isfinite(ratio) && ratio>0 && ratio<1;
            if valid && ~isempty(app.Data)
                n=numel(app.Data.y); count=round(n*ratio); valid=count>=6 && n-count>=2;
            end
            if valid, app.Config.trainRatio=ratio; app.invalidate;
            else, ratio=previous; uialert(app.Figure,'Use a ratio between 0 and 100%, with at least 6 training and 2 test samples. The previous valid ratio was restored.','Invalid split ratio'); end
            app.UI.Train.Value=ratio*100; app.UI.Test.Value=100-app.UI.Train.Value; app.updateCounts;
        end
        function updateCounts(app)
            if isempty(app.Data), return; end
            n=numel(app.Data.y); tr=round(n*app.Config.trainRatio);
            app.UI.Count.Text=sprintf('Train %d / Test %d',tr,n-tr);
        end
        function settings(app)
            [c,ok]=parameterDialog(app.Figure,app.Config,app.Data);
            if ok
                app.Config=c;
                app.UI.Train.Value=100*c.trainRatio; app.UI.Test.Value=100-app.UI.Train.Value;
                app.updateCounts; app.invalidate; app.log('Parameters saved');
            end
        end
        function invalidate(app)
            app.Result=[]; app.Preview=[];
            app.UI.Export.Enable='off'; app.updateMetrics([]); app.UI.Best.Text='Best parameters: —';
            for k=2:6, for ax=app.Axes{k}, cla(ax); title(ax,''); end, end
            app.UI.Status.Text='Settings updated. Ready to run.';
        end
        function run(app)
            if app.Busy
                app.CancelRequested=true; app.UI.Run.Text='Cancelling...'; app.log('Cancellation requested; waiting for the current computation.'); return;
            end
            if isempty(app.Data), uialert(app.Figure,'Import a data file first.','No data'); return; end
            try
                validateConfig(app.Config,app.Data); checkDependencies(app.Config);
                if strcmp(app.Config.optimizer,'Grid')
                    [~,total]=parameterGrid(app.Config.searchSpace,app.Config.gridPoints);
                    if total>1000
                        choice=uiconfirm(app.Figure,sprintf('The grid contains up to %g combinations with %d CV folds each. Continue?',total,app.Config.folds), ...
                            'Grid search size','Options',{'Continue','Cancel'},'DefaultOption',2,'CancelOption',2);
                        if strcmp(choice,'Cancel'), return; end
                    end
                end
            catch e, app.showError(e); return; end
            app.invalidate; app.setBusy(true); app.CancelRequested=false;
            cleanup=onCleanup(@()app.setBusy(false)); %#ok<NASGU>
            try
                app.Result=runAnalysis(app.Data,app.Config,@(stage,payload)app.onProgress(stage,payload),@()app.CancelRequested);
            catch e
                app.Result=[];
                if strcmp(e.identifier,'SpectralML:Cancelled')
                    app.log('Analysis cancelled; no final result was created.'); app.UI.Status.Text='Cancelled';
                else, app.showError(e); end
            end
        end
        function setBusy(app,value)
            app.Busy=value;
            if ~isvalid(app.Figure), return; end
            state='on'; if value, state='off'; end
            for k=1:numel(app.Inputs), app.Inputs{k}.Enable=state; end
            app.UI.Run.Enable='on';
            if value, app.UI.Run.Text='Cancel run'; else, app.UI.Run.Text='Run analysis'; end
            app.UI.Export.Enable='off'; if ~value && ~isempty(app.Result), app.UI.Export.Enable='on'; end
        end
        function onProgress(app,stage,payload)
            switch stage
                case 'message', app.log(payload); app.UI.Status.Text=payload;
                case 'split'
                    app.Preview=payload; plotSampleDistribution(app.Axes{2}(1),app.Axes{2}(2),payload);
                    app.selectPage(2);
                case 'preprocessed'
                    app.Preview=payload; app.redrawPre;
                case 'features'
                    app.Preview=payload; plotSelectedWavelengths(app.Axes{4},payload);
                case 'optimization'
                    plotOptimization(app.Axes{5},payload.history,app.Config,payload.total);
                    app.UI.Best.Text=['Best parameters: ' jsonencode(payload.bestParameters)];
                    app.UI.Status.Text=sprintf('Parameter evaluation %d/%d',numel(payload.history),payload.total);
                    app.log(app.UI.Status.Text);
                case 'complete'
                    app.Result=payload; app.Preview=payload; app.redrawPrediction;
                    app.updateMetrics(payload);
                    app.selectPage(6);
                    app.UI.Status.Text=sprintf('Completed · %.1f s · %d bands selected',payload.seconds,numel(payload.selection.indices));
            end
            applyUIFonts(app.Figure,18);
            drawnow limitrate;
        end
        function redrawPre(app)
            if ~isempty(app.Preview) && isfield(app.Preview,'preprocessed')
                plotPreprocessedSpectra(app.Axes{3},app.Preview,app.UI.PreSubset.Value);
                applyUIFonts(app.Axes{3},18);
            end
        end
        function redrawPrediction(app)
            if ~isempty(app.Result)
                plotPredictionDiagnostics(app.Axes{6},app.Result,'All');
            end
        end
        function updateMetrics(app,result)
            app.UI.Metrics.Data=metricsComparisonData(result);
        end
        function export(app)
            if isempty(app.Result), return; end
            parent=uigetdir(pwd,'Select an export folder'); if isequal(parent,0), return; end
            app.setBusy(true); app.CancelRequested=false;
            cleanup=onCleanup(@()app.setBusy(false)); %#ok<NASGU>
            progressDialog=[];
            try
                progressDialog=uiprogressdlg(app.Figure,'Title','Export results', ...
                    'Message','0% · Preparing export','Value',0,'Cancelable','on');
                dialogCleanup=onCleanup(@()app.closeExportProgress(progressDialog)); %#ok<NASGU>
                app.log('Exporting analysis results and TIFF figures');
                folder=exportResults(app.Result,parent,{'tiff'},true, ...
                    @()app.exportCancelled(progressDialog), ...
                    @(value,message)app.updateExportProgress(progressDialog,value,message));
                clear dialogCleanup
                app.log(['Export completed: ' folder]); app.UI.Status.Text=['Exported to ' folder];
                uialert(app.Figure,['Results saved to: ' folder],'Export completed','Icon','success','Interpreter','none');
            catch e
                app.closeExportProgress(progressDialog);
                app.log('Export incomplete; the output folder may contain partial files.');
                if strcmp(e.identifier,'SpectralML:Cancelled')
                    app.log('Export cancelled'); app.UI.Status.Text='Export cancelled';
                else, app.showError(e); end
            end
        end
        function cancelled=exportCancelled(app,dialog)
            cancelled=app.CancelRequested || isempty(dialog) || ~isvalid(dialog) || dialog.CancelRequested;
        end
        function updateExportProgress(app,dialog,value,message)
            if isempty(dialog) || ~isvalid(dialog), return; end
            dialog.Value=min(1,max(0,value));
            text=sprintf('%d%% · %s',round(100*dialog.Value),message);
            dialog.Message=text; app.UI.Status.Text=['Export ' text];
            drawnow;
        end
        function closeExportProgress(~,dialog)
            if ~isempty(dialog) && isvalid(dialog), close(dialog); end
        end
        function log(app,message)
            app.Messages{end+1}=sprintf('[%s] %s',char(datetime('now','Format','HH:mm:ss')),message);
            if numel(app.Messages)>300, app.Messages=app.Messages(end-299:end); end
            app.UI.Log.Value=app.Messages;
            scroll(app.UI.Log,'bottom');
        end
        function showError(app,e)
            app.log(sprintf('Error [%s] %s',e.identifier,e.message)); app.UI.Status.Text='Operation failed. Check the log and parameters.';
            uialert(app.Figure,e.message,'Operation failed','Interpreter','none');
        end
        function closeApp(app)
            if app.Busy
                app.CancelRequested=true; app.log('Cancellation requested. Close the window after the computation stops.');
            else, delete(app); end
        end
    end
end
