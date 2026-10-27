function result = demoSpectralML
%DEMOSPECTRALML Compact Ridge workflow on synthetic spectra.
root=fileparts(fileparts(mfilename('fullpath'))); addpath(genpath(root));
d=importData(fullfile(root,'examples','example_spectra.csv'));
c=defaultConfig;
c.split='Random'; c.preprocessing='SG';
c.preprocessParams=algorithmDefaults('preprocessing','SG');
c.feature='None'; c.featureParams=algorithmDefaults('feature','None');
c.model='Ridge'; [c.modelParams,c.searchSpace]=modelDefaults('Ridge');
c.optimizer='Grid'; c.searchSpace(1).Grid=[0.001,0.01,0.1,1,10];
result=runAnalysis(d,c,@printProgress,[]);
disp(metricsTable(result));
% Optional export after you inspect the result:
% folder=exportResults(result,root,{'tiff'},true);
end
function printProgress(stage,payload)
if strcmp(stage,'message'), fprintf('%s\n',payload); end
end
