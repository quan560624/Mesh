function aux = auxstructure(node,elem)

NT = size(elem,1);
if size(elem,2) == 4
    elem = mat2cell(elem,ones(size(elem,1),1), 4); % rectangle element
end
if iscell(elem)
    % totalEdge
    shiftfun = @(verts) [verts(2:end),verts(1)];  % or shiftfun = @(verts) circshift(verts,-1);
    T1 = cellfun(shiftfun, elem, 'UniformOutput', false);
    v0 = horzcat(elem{:})'; % the starting points of edges
    v1 = horzcat(T1{:})'; % the ending points of edges
    totalEdge = sort([v0,v1],2);
    
    % -------- elem2edge: elementwise edges -------
    [~, i1, totalJ] = unique(totalEdge,'rows');
    elemLen = cellfun('length',elem); % length of each elem
    elem2edge = mat2cell(totalJ',1,elemLen)';
    
else % Triangulation
    totalEdge = sort([elem(:,[2,3]); elem(:,[3,1]); elem(:,[1,2])],2);
    [~, i1, totalJ] = unique(totalEdge,'rows');    
    elem2edge = reshape(totalJ,NT,3);
end

% -------- edge, bdEdge --------
[i,j,s] = find(sparse(totalEdge(:,2),totalEdge(:,1),1));
edge = [j,i];
bdEdge = edge(s==1,:); % not counterclockwise

% ------- edge2elem --------
if iscell(elem)
    Num = num2cell((1:NT)');    Len = num2cell(elemLen);
    totalJelem = cellfun(@(n1,n2) n1*ones(n2,1), Num, Len, 'UniformOutput', false);
    totalJelem = vertcat(totalJelem{:});
else
    totalJelem = repmat((1:NT)',3,1);
end
[~, i2] = unique(totalJ(end:-1:1),'rows');
i2 = length(totalEdge)+1-i2;
edge2elem = totalJelem([i1,i2]);

% --------- neighbor ---------
NE = size(edge,1); 
ii1 = edge2elem(:,1); jj1 = (1:NE)'; ss1 = edge2elem(:,2);
ii2 = edge2elem(:,2); jj2 = (1:NE)'; ss2 = edge2elem(:,1);
label = (ii2~=ss2);
ii2 = ii2(label); jj2 = jj2(label); ss2 = ss2(label);
ii = [ii1;ii2]; jj = [jj1;jj2]; ss = [ss1;ss2];
neighbor = sparse(ii,jj,ss,NT,NE);


% if ~iscell(elem) % transform to cell
%     elem = mat2cell(elem,ones(NT,1),3);
%     elem2edge = mat2cell(elem2edge,ones(NT,1),3);
% end

aux.node = node; aux.elem = elem;
aux.elem2edge = elem2edge;
aux.edge = edge; aux.bdEdge = bdEdge;
aux.edge2elem = edge2elem;
aux.neighbor = neighbor;