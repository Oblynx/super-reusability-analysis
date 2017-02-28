function a=train(this)
% System::train is the main editable script for running experiments

%% Preprocess
% Load single project class metrics (more project data could be concatenated at
% the end)
repo= 'bigbluebutton';
dataset= this.reader.load(repo,'Class');
dataset= dataset(:,11:end);
scoreDset= dataset{:,:};  % Turn into matrix (from table)

%% One-class
% Skip at first
this.acceptanceClassifier.train(scoreDset);

%% Scoring model
% Calculate the target set according to target::cl_star
targetset= model.target.cl_star(dataset, this.reader.repositories(repo,:));

% Train
evalResults= this.scorer.train(scoreDset, targetset);

% That's it! Now, analyse evalResults
a= {scoreDset, targetset};
