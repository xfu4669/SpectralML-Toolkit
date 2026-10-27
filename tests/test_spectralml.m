function tests = test_spectralml
%TEST_SPECTRALML Data boundaries, fold isolation, and model reuse.
tests=functiontests(localfunctions);
end
function setupOnce(t)
root=fileparts(fileparts(mfilename('fullpath'))); addpath(genpath(root));
t.TestData.root=root; t.TestData.data=importData(fullfile(root,'examples','example_spectra.csv'));
end
function testSplitCoverage(t)
d=t.TestData.data; c=defaultConfig;
for method={'Random','KS','SPXY'}
    c.split=method{1}; [a,b]=splitSamples(d,c); [a2,b2]=splitSamples(d,c);
    verifyEqual(t,a,a2); verifyEqual(t,b,b2); verifyEmpty(t,intersect(a,b));
    verifyEqual(t,sort([a b]),1:numel(d.y)); verifyEqual(t,numel(a),round(0.8*numel(d.y)));
end
end
function testMSCUsesTrainingReference(t)
d=t.TestData.data; c=defaultConfig; [a,b]=splitSamples(d,c);
p=algorithmDefaults('preprocessing','MSC'); [~,s]=preprocessSpectrum(d.X(a,:),d.wavelength,'MSC',p);
[z,s2]=preprocessSpectrum(d.X(b,:)+2,d.wavelength,'MSC',p,s);
verifyEqual(t,s.reference,mean(d.X(a,:),1),'AbsTol',1e-12);
verifyEqual(t,s2.reference,s.reference); verifyTrue(t,all(isfinite(z(:))));
end
function testFoldPartitionAndNoTargetLeak(t)
d=t.TestData.data; c=defaultConfig; c.feature='VIP'; c.featureParams=algorithmDefaults('feature','VIP');
c.featureParams.threshold=0; c.preprocessing='MSC'; c.preprocessParams=algorithmDefaults('preprocessing','MSC');
[a,~]=splitSamples(d,c); X=d.X(a,:); y=d.y(a); fold=makeFolds(numel(y),c.folds,c.seed);
A=prepareFolds(X,y,d.wavelength,c,[],[]); changed=y; changed(fold==1)=changed(fold==1)+1000;
B=prepareFolds(X,changed,d.wavelength,c,[],[]);
verifyEqual(t,A{1}.selection.scores,B{1}.selection.scores,'AbsTol',1e-12);
verifyEqual(t,A{1}.preprocessor.reference,B{1}.preprocessor.reference,'AbsTol',1e-12);
verifyEmpty(t,intersect(A{1}.trainRows,A{1}.validRows));
end
function testMetricsDegenerateCases(t)
m=calculateMetrics(ones(5,1),ones(5,1)); verifyTrue(t,isnan(m.R2)); verifyTrue(t,isnan(m.RPD));
m=calculateMetrics([1;2;3],[1;2;3]); verifyEqual(t,m.RMSE,0); verifyEqual(t,m.R2,1); verifyTrue(t,isnan(m.RPD));
end
function testRidgePipelineReload(t)
d=t.TestData.data; c=defaultConfig; c.model='Ridge'; [c.modelParams,c.searchSpace]=modelDefaults('Ridge');
c.optimizer='Grid'; c.searchSpace.Grid=[0.01 0.1 1];
r=runAnalysis(d,c); verifyEqual(t,numel(r.optimization.history),3);
verifyTrue(t,all(diff([r.optimization.history.bestScore])<=eps));
verifyTrue(t,all(isfinite(r.optimization.oof)));
bundle=struct('model',r.model,'preprocessor',r.preprocessor,'selection',r.selection,'wavelength',d.wavelength);
pred=predictNewSpectra(bundle,d.X(r.testRows,:),d.wavelength);
verifyEqual(t,pred,r.testPrediction,'AbsTol',1e-10);
end
function testExplicitWaveRequired(t)
d=t.TestData.data; tmp=[tempname '.csv']; cleanup=onCleanup(@()delete(tmp)); %#ok<NASGU>
T=table(d.id,d.y,d.X(:,1),d.X(:,2),'VariableNames',{'ID','Y','B001','B002'}); writetable(T,tmp);
verifyError(t,@()importData(tmp),'SpectralML:WavelengthRequired');
v=importData(tmp,struct('indexMode',true)); verifyEqual(t,v.wavelength,[1 2]);
end
