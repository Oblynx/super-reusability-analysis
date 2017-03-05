function levels= discretizeLevels(targetset, trainTargetset)
% Discretize the targetset into levels. The level boundaries are defined based on the trainTargetset.
  nlevels= 3;
  boundaries= [prctile(trainTargetset,40), prctile(trainTargetset,80)];
  h= targetset >= boundaries(2);
  m= (targetset >= boundaries(1)) & (targetset < boundaries(2));
  l= targetset < boundaries(1);
  levels= zeros(nlevels,size(targetset,2));
  levels(:,l)= [1;0;0]*ones(1,sum(l));
  levels(:,m)= [0;1;0]*ones(1,sum(m));
  levels(:,h)= [0;0;1]*ones(1,sum(h));
end
