function [loss,score,oof,foldScores] = crossValidationObjective(cache,c,parameters,cancel)
n=sum(cellfun(@(f)numel(f.validRows),cache)); oof=nan(n,1); foldScores=zeros(numel(cache),1);
for k=1:numel(cache)
    checkCancelled(cancel); f=cache{k};
    m=trainRegression(f.XTrain,f.yTrain,c.model,parameters,c.seed+1000+k,cancel);
    pred=predictRegression(m,f.XValid); oof(f.validRows)=pred;
    metrics=calculateMetrics(f.yValid,pred); foldScores(k)=metrics.(c.metric);
end
assert(all(isfinite(foldScores)),'SpectralML:CV','CV metric is undefined (e.g. constant validation target for R2).');
score=mean(foldScores); loss=score;
if strcmp(c.metric,'R2'), loss=-score; end
end
