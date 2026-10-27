function randomSearch(space,count,seed,evaluate,cancel)
s=RandStream('mt19937ar','Seed',seed);
for k=1:count
    checkCancelled(cancel); p=struct;
    for j=1:numel(space)
        v=space(j);
        if strcmp(v.Type,'categorical'), x=v.Values{randi(s,numel(v.Values))};
        elseif v.Lower==v.Upper, x=v.Lower;
        elseif strcmp(v.Type,'integer') && strcmp(v.Scale,'linear'), x=randi(s,[v.Lower,v.Upper]);
        else
            u=rand(s);
            if strcmp(v.Scale,'log'), x=exp(log(v.Lower)+u*log(v.Upper/v.Lower));
            else, x=v.Lower+u*(v.Upper-v.Lower); end
            if strcmp(v.Type,'integer'), x=round(x); end
        end
        p.(v.Name)=x;
    end
    evaluate(p);
end
end
