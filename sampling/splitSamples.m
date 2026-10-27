function [train,test] = splitSamples(d,c,cancel)
if nargin<3, cancel=[]; end
n=round(numel(d.y)*c.trainRatio);
assert(n>=4 && numel(d.y)-n>=2, 'SpectralML:Split','Need at least 4 training and 2 test samples.');
switch c.split
    case 'Random', [train,test]=randomSplit(d.X,d.y,c.trainRatio,c.seed);
    case 'KS', [train,test]=kennardStone(d.X,d.y,c.trainRatio,c.seed,cancel);
    case 'SPXY', [train,test]=spxySplit(d.X,d.y,c.trainRatio,c.seed,cancel);
    otherwise, error('SpectralML:Split','Unsupported split: %s',c.split);
end
end
