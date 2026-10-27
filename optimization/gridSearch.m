function gridSearch(space,points,evaluate,cancel)
% Stream every Cartesian product candidate; never truncate to MaxEvaluations.
[values,total]=parameterGrid(space,points);
for k=0:total-1
    checkCancelled(cancel); rest=k; p=struct;
    for j=1:numel(space)
        at=mod(rest,numel(values{j}))+1; rest=floor(rest/numel(values{j}));
        p.(space(j).Name)=values{j}{at};
    end
    evaluate(p);
end
end
