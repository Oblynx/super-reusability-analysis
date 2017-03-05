function score= cl_fork(repoDataset,repoInfo)
% Calculates a target score for each class of a given repo based on the forks
% repoDataset [table]: class metrics for 1 repo
% repoInfo [table]: the repo's stars (1 row of repositories info table)

repoForks= repoInfo{1,'Forks'};
nclass= repoInfo{1,'Num_of_Classes'};
pub= repoDataset{:,'NPM'};          % "Public front"
if any(iscell(pub)), pub= cell2mat(repoDataset{:,'NPM'}); end
score= log2((1+pub) * (1+repoForks/nclass));
score(score>10)= 10;
end
