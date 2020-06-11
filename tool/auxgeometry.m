function aux = auxgeometry(node,elem)

% ------ centroid, area, diameter -------
NT = size(elem,1);
centroid = zeros(NT,2); area = zeros(NT,1); diameter = zeros(NT,1);
for iel = 1:NT
    if iscell(elem)
        index = elem{iel};
    else
        index = elem(iel,:);
    end
    verts = node(index, :); verts1 = verts([2:end,1],:);
    area_components = verts(:,1).*verts1(:,2)-verts1(:,1).*verts(:,2);
    ar = 0.5*abs(sum(area_components));
    area(iel) = ar;
    centroid(iel,:) = sum((verts+verts1).*repmat(area_components,1,2))/(6*ar);
    diameter(iel) = max(pdist(verts));
end

% if ~iscell(elem) % transform to cell
%     elem = mat2cell(elem,ones(NT,1),3);
% end

aux.node = node; aux.elem = elem;
aux.centroid = centroid;
aux.area = area;
aux.diameter = diameter;