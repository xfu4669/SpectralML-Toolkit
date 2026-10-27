function y = predictXGBoostTree(tree,X)
y=zeros(size(X,1),1); walk(tree,(1:size(X,1))');
    function walk(node,rows)
        if isempty(rows), return; end
        if node.feature==0, y(rows)=node.value; return; end
        left=X(rows,node.feature)<=node.threshold;
        walk(node.left,rows(left)); walk(node.right,rows(~left));
    end
end
