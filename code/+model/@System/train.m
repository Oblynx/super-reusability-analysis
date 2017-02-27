function train(this)
% System::train is the main editable script for running experiments

%% Preprocess
% Load single project class metrics (more project data could be concatenated at
% the end)
repo= 'bigbluebutton';
dataset= this.reader.load(repo,'Class');

%% One-class
% Skip at first

%% Scoring model
% Calculate the target set according to target::cl_star
targetset= target.cl_star(dataset, this.reader.repositories(repo,:));

% Train
evalResults= this.scorer.train(dataset, targetset);

% That's it! Now, analyse evalResults
