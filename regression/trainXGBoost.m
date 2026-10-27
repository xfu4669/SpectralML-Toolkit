function m = trainXGBoost(X,y,p,cancel)
% Native MATLAB XGBoost-style exact greedy trees for squared error:
% g = prediction-y, h=1; leaf=-sum(g)/(sum(h)+lambda).
% Gain=0.5*(GL^2/(HL+lambda)+GR^2/(HR+lambda)-G^2/(H+lambda))-gamma.
% Scope: numeric dense data, no missing values, no GPU/hist/distributed backend.
n=size(X,1); b=size(X,2); m.base=mean(y); pred=repmat(m.base,n,1);
m.learningRate=p.LearnRate; m.trees=cell(p.NumTrees,1); m.parameters=p;
for iter=1:p.NumTrees
    checkCancelled(cancel);
    rows=randperm(n,max(2,min(n,ceil(p.Subsample*n))));
    columns=sort(randperm(b,max(1,ceil(p.Colsample*b))));
    gradient=pred-y;
    m.trees{iter}=build(rows,0,columns,gradient);
    pred=pred+p.LearnRate*predictXGBoostTree(m.trees{iter},X);
end
    function node=build(rows,depth,columns,g)
        checkCancelled(cancel);
        G=sum(g(rows)); H=numel(rows);
        node=struct('value',-G/(H+p.Lambda),'feature',0,'threshold',NaN,'left',[],'right',[]);
        if depth>=p.MaxDepth || H<2*p.MinLeafSize, return; end
        bestGain=0; chosen=0; split=NaN;
        for col=columns
            [values,ord]=sort(X(rows,col)); gs=cumsum(g(rows(ord)));
            k=(p.MinLeafSize:H-p.MinLeafSize)';
            k=k(values(k)<values(k+1));
            if isempty(k), continue; end
            gain=0.5*(gs(k).^2./(k+p.Lambda)+(G-gs(k)).^2./(H-k+p.Lambda)-G^2/(H+p.Lambda))-p.Gamma;
            [value,j]=max(gain);
            if value>bestGain
                bestGain=value; chosen=col; at=k(j);
                split=values(at)+(values(at+1)-values(at))/2;
            end
        end
        if chosen==0, return; end
        left=rows(X(rows,chosen)<=split); right=rows(X(rows,chosen)>split);
        node.feature=chosen; node.threshold=split;
        node.left=build(left,depth+1,columns,g); node.right=build(right,depth+1,columns,g);
    end
end
