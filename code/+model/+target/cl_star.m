function score= cl_star(repoDataset,repoInfo)
% Calculates a target score for each class of a given repo based on the stars
% repoDataset [table]: class metrics for 1 repo
% repoInfo [table]: the repo's stars (1 row of repositories info table)

repoStars= repoInfo{1,'Stars'};
nclass= repoInfo{1,'Num_of_Classes'};
dep= repoDataset{:,'CBOI'};
if any(iscell(dep)), dep= cell2mat(repoDataset{:,'CBOI'}); end
score= log2((1+dep) * repoStars/nclass);
end
