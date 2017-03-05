function score= cl_full(repoDataset,repoInfo)
% Full target metric for class
% repoDataset [table]: class metrics for 1 repo
% repoInfo [table]: the repo's stars (1 row of repositories info table)
score= 0.4*model.target.cl_star(repoDataset,repoInfo) + ...
       0.6*model.target.cl_fork(repoDataset,repoInfo);
end

