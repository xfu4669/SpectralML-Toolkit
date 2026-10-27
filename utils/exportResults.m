function folder = exportResults(r,parent,formats,writeXlsx,cancel,progress)
% Creates a new timestamped folder; never overwrites a previous run.
if nargin<3 || isempty(formats), formats={'tiff'}; end
if nargin<4, writeXlsx=true; end
if nargin<5, cancel=[]; end
if nargin<6, progress=[]; end
requested=string(formats);
assert(all(strcmpi(requested(:),'tiff') | strcmpi(requested(:),'tif')), ...
    'SpectralML:Export','TIFF is the only figure format. Use {''tiff''}.');
formats={'tiff'};
checkCancelled(cancel);
if ~isempty(progress), progress(0,'Preparing export data'); end
folder=fullfile(parent,['SpectralML_' char(datetime('now','Format','yyyyMMdd_HHmmss_SSS'))]);
assert(~isfolder(folder),'SpectralML:Export','Output folder already exists.'); mkdir(folder);
n=numel(r.data.y); Dataset=repmat("Test",n,1); Dataset(r.trainRows)="Train";
split=table(r.data.id,Dataset,r.data.y,'VariableNames',{'ID','Dataset','Observed'});
pred=nan(n,1); pred(r.trainRows)=r.trainPrediction; pred(r.testRows)=r.testPrediction;
oof=nan(n,1); oof(r.trainRows)=r.optimization.oof;
predictions=addvars(split,pred,oof,'NewVariableNames',{'Predicted','OOF_Predicted'});
names=cellstr(string(r.data.wavelength)); spectra=[split(:,1:2),array2table(r.preprocessed,'VariableNames',names)];
Index=(1:numel(r.data.wavelength))'; Wavelength=r.data.wavelength(:); Selected=ismember(Index,r.selection.indices);
Score=nan(size(Index)); if ~isempty(r.selection.scores), Score=r.selection.scores(:); end
features=table(Index,Wavelength,Selected,Score);
h=r.optimization.history; Iteration=[h.iteration]'; CVScore=[h.score]'; BestScore=[h.bestScore]'; Seconds=[h.seconds]';
Parameters=string(arrayfun(@(s)jsonencode(s.parameters),h,'UniformOutput',false))';
Status=string({h.status})'; Error=string({h.error})';
history=table(Iteration,CVScore,BestScore,Seconds,Parameters,Status,Error);
tables={split,spectra,features,predictions,metricsTable(r),history};
tableNames={'sample_split','preprocessed_spectra','wavelength_selection','predictions','metrics','search_history'};
completed=0;
% CSV files, optional Excel sheets, 3 JSON, 2 TXT, 2 MAT, and 6 TIFF files.
totalSteps=numel(tables)*(1+double(writeXlsx))+3+2+2+6;
for i=1:numel(tables)
    announce(['Exporting CSV: ' tableNames{i}]);
    writetable(tables{i},fullfile(folder,[tableNames{i} '.csv']),'Encoding','UTF-8');
    finish(['Saved CSV: ' tableNames{i}]);
    if writeXlsx
        announce(['Writing Excel sheet: ' tableNames{i}]);
        writetable(tables{i},fullfile(folder,'results.xlsx'),'Sheet',tableNames{i});
        finish(['Saved Excel sheet: ' tableNames{i}]);
    end
end
announce('Saving run configuration');
writeText(fullfile(folder,'configuration.json'),jsonencode(r.config,'PrettyPrint',true));
finish('Saved run configuration');
announce('Saving best parameters');
writeText(fullfile(folder,'best_parameters.json'),jsonencode(r.optimization.bestParameters,'PrettyPrint',true));
finish('Saved best parameters');
announce('Saving effective search ranges');
writeText(fullfile(folder,'effective_search_space.json'),jsonencode(r.optimization.effectiveSearchSpace,'PrettyPrint',true));
finish('Saved effective search ranges');
notes=sprintf('Created: %s\nMATLAB: %s\nValidation: %s\n%s\nRPD = sample SD (n-1) / RMSE; undefined values are NaN.\n', ...
    r.createdAt,r.runtime,r.validationType,r.cvNote);
announce('Saving run notes');
writeText(fullfile(folder,'run_notes.txt'),notes); finish('Saved run notes');
metricNotes=sprintf(['Residual = observed - predicted.\nBias = mean(residual).\n' ...
    'R2 = 1-sum(residual.^2)/sum((observed-mean(observed)).^2).\n' ...
    'RMSE = sqrt(mean(residual.^2)); MAE = mean(abs(residual)).\n' ...
    'RPD = sample SD of observed values (N-1 denominator)/RMSE.\n' ...
    'RPIQ = (Q75(observed)-Q25(observed))/RMSE, MATLAB quantile interpolation.\n' ...
    'Comparison rows: R2, RMSE, RPD, RPIQ, MAE, Bias; columns: Train, CV, Test.\n' ...
    'Undefined R2/RPD/RPIQ values are NaN in data exports.\n' ...
    'Residual shaded region is a bin-wise interquartile range, not a confidence interval.\n']);
announce('Saving metric definitions');
writeText(fullfile(folder,'metric_definitions.txt'),metricNotes); finish('Saved metric definitions');
bundle=struct('model',r.model,'preprocessor',r.preprocessor,'selection',r.selection, ...
    'wavelength',r.data.wavelength,'wavelengthLabel',r.data.wavelengthLabel, ...
    'targetName',r.data.targetName,'config',r.config,'createdAt',r.createdAt,'runtime',r.runtime);
announce('Saving the model MAT file');
save(fullfile(folder,'model.mat'),'bundle','-v7.3'); finish('Saved the model MAT file');
announce('Saving complete analysis results');
save(fullfile(folder,'analysis_result.mat'),'r','-v7.3'); finish('Saved complete analysis results');
figureBase=completed;
exportFigures(r,folder,formats,cancel,@figureProgress);
checkCancelled(cancel);
if ~isempty(progress), progress(1,'Export completed'); end
    function announce(message)
        checkCancelled(cancel);
        if ~isempty(progress), progress(completed/totalSteps,message); end
        checkCancelled(cancel);
    end
    function finish(message)
        completed=completed+1;
        announce(message);
    end
    function figureProgress(value,message)
        checkCancelled(cancel);
        if ~isempty(progress), progress((figureBase+6*value)/totalSteps,message); end
        checkCancelled(cancel);
    end
end
function writeText(path,value)
f=fopen(path,'w','n','UTF-8'); assert(f~=-1,'SpectralML:Export','Cannot write %s',path);
cleanup=onCleanup(@()fclose(f)); fprintf(f,'%s',value); %#ok<NASGU>
end
