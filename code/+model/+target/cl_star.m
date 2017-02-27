function score= cl_star(repoDataset,repoInfo)
% Calculates a target score for each class of a given repo based on the stars
% repoDataset [table]: class metrics for 1 repo
% repoStars [table]: the repo's stars (1 row of repositories info table)

repoStars= repoInfo{'Stars'};
nclass= size(repoDataset,1);
dep= cell2mat(repoDataset{:,'CBOI'});
score= log( (1+dep) * repoStars/nclass );
end
