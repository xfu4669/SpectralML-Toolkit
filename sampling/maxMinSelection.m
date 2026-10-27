function selected = maxMinSelection(D,count,cancel)
if nargin<3, cancel=[]; end
n=size(D,1); D(1:n+1:end)=-Inf;
[~,k]=max(D(:)); [a,b]=ind2sub([n n],k);
selected = a;
if count>1, selected=[a b]; end
remaining=setdiff(1:n,selected,'stable');
while numel(selected)<count
    checkCancelled(cancel);
    nearest=min(D(remaining,selected),[],2);
    [~,j]=max(nearest); selected(end+1)=remaining(j); remaining(j)=[];
end
selected=sort(selected);
end
