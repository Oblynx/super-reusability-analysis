function a=trainAll(this)
% System::train is the main editable script for running experiments

%% Preprocess
maxrepo= 80;

% Load all project class metrics
allDatasets= this.reader.loadAll('Class',true);
dataset= vertcat(allDatasets{1:maxrepo,2});   % Implode all tables into one
dataset= dataset(:,11:70);               % Select static analysis metrics
dataset= dataset(:, model.System.onlyNocorrCols());

% Keep track of how many classes were in each repo. Useful in dividing train/test sets
repoLengths= cellfun(@(x) size(x,1), allDatasets(:,2));
repoStarts= cumsum([1;repoLengths]);

%% One-class
% Skip at first
% slow for all data
%this.acceptanceClassifier.train(scoreDset);

%% Scoring model
% Calculate the target set according to target::cl_star
targetset= cellfun(@(repoD,repoN) model.target.cl_star(repoD, this.reader.repositories(repoN,:)), ...
                   allDatasets(:,2), allDatasets(:,1), 'UniformOutput',false);
targetset= vertcat(targetset{1:maxrepo});

% Train
scoreDset= dataset{:,:};                 % Turn into matrix (from table)
this.scorer.train(scoreDset, targetset, repoStarts(1:maxrepo+1));

% That's it!

% Debug
a= {scoreDset, targetset, this.scorer};
