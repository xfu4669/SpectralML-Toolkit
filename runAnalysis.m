function r = runAnalysis(d,c,progress,cancel)
%RUNANALYSIS Complete leakage-aware pipeline. GUI-independent public API.
if nargin<3, progress=[]; end
if nargin<4, cancel=[]; end
validateConfig(c,d); checkDependencies(c);
emit('message','Data and configuration checks completed'); timer=tic;
[tr,te]=splitSamples(d,c,cancel);
r=struct('data',d,'config',c,'trainRows',tr,'testRows',te);
emit('split',r); emit('message',[c.split ' split completed']);
[A,state]=preprocessSpectrum(d.X(tr,:),d.wavelength,c.preprocessing,c.preprocessParams);
B=preprocessSpectrum(d.X(te,:),d.wavelength,c.preprocessing,c.preprocessParams,state);
r.preprocessed=zeros(size(d.X)); r.preprocessed(tr,:)=A; r.preprocessed(te,:)=B;
r.preprocessor=state; emit('preprocessed',r); emit('message',[c.preprocessing ' preprocessing completed']);
r.selection=selectFeatures(A,d.y(tr),d.wavelength,c.feature,c.featureParams,c.seed,cancel);
emit('features',r); emit('message',[c.feature ' feature selection completed']);
emit('message','Preparing training-only cross-validation folds');
cache=prepareFolds(d.X(tr,:),d.y(tr),d.wavelength,c,cancel,progress);
emit('message',['Starting ' c.optimizer ' optimization']);
r.optimization=optimizeModel(cache,c,cancel,progress);
emit('message','Best parameters selected; refitting the full training pipeline');
[A,r.preprocessor]=preprocessSpectrum(d.X(tr,:),d.wavelength,c.preprocessing,c.preprocessParams);
B=preprocessSpectrum(d.X(te,:),d.wavelength,c.preprocessing,c.preprocessParams,r.preprocessor);
r.selection=selectFeatures(A,d.y(tr),d.wavelength,c.feature,c.featureParams,c.seed,cancel);
r.model=trainRegression(A(:,r.selection.indices),d.y(tr),c.model,r.optimization.bestParameters,c.seed+3000,cancel);
r.trainPrediction=predictRegression(r.model,A(:,r.selection.indices));
r.testPrediction=predictRegression(r.model,B(:,r.selection.indices));
r.metrics=struct('Train',calculateMetrics(d.y(tr),r.trainPrediction), ...
    'CV',calculateMetrics(d.y(tr),r.optimization.oof),'Test',calculateMetrics(d.y(te),r.testPrediction));
r.foldAudit=cellfun(@(f)rmfield(f,{'XTrain','XValid','yTrain','yValid'}),cache,'UniformOutput',false);
r.seconds=toc(timer); r.createdAt=char(datetime('now','Format','yyyy-MM-dd HH:mm:ss'));
r.runtime=version; r.validationType=[c.split ' holdout'];
if strcmp(c.split,'SPXY'), r.validationType='SPXY target-informed holdout (not external random validation)'; end
r.cvNote='OOF predictions from fold-local preprocessing and selection; parameters selected on these same CV folds. Not nested unbiased CV.';
checkCancelled(cancel); emit('complete',r); emit('message','Analysis completed');
    function emit(stage,payload)
        checkCancelled(cancel); if ~isempty(progress), progress(stage,payload); end
    end
end
