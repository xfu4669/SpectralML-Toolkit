function series = predictionSeries(r,subset)
if nargin<2, subset='All'; end
series=struct('name',{},'color',{},'observed',{},'predicted',{},'residual',{});
if ~strcmp(subset,'Test')
    add('Train',[0.20 0.46 0.72],r.data.y(r.trainRows),r.trainPrediction);
end
if ~strcmp(subset,'Train')
    add('Test',[0.91 0.49 0.23],r.data.y(r.testRows),r.testPrediction);
end
    function add(name,color,y,p)
        y=y(:); p=p(:);
        series(end+1)=struct('name',name,'color',color,'observed',y,'predicted',p,'residual',y-p);
    end
end
