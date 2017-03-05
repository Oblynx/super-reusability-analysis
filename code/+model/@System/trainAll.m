function a=trainAll(this)
% System::trainAll is the main editable script for running experiments

%% Preprocess
maxrepo= 137;
this.prepareDataset('Class',maxrepo);

% Metrics correlation analysis
%{
dset= this.dataset.getScorer();
utils.metricCorr(dset,0.8, this.scorer.correlatedMetricsToRemove);
%}

%% Acceptance model
% Train scorer only on good samples
%this.acceptanceClassifier.train(this.dataset.getAcc());
  pre= this.dataset.selector.R; %DEBUG
%acceptanceMask= this.acceptanceClassifier.filter(this.dataset.getScorer());
%this.filterDataset(acceptanceMask);

  [svmAcc,svmRej]= utils.filterGetRejectedAccepted(this.dataset, pre); %DEBUG

%% Scoring model
this.dataset.setTarget(@(repoD,repoN) model.target.cl_full(repoD, ...
                            this.reader.repositories(repoN,:)), [14 54]);

[scorerData,scorerTarget]= this.dataset.getScorer();
fprintf('Scorer dataset size: %dx%d\n', size(scorerData,1), size(scorerData,2));
%this.scorer.train(scorerData,scorerTarget);

% That's it!

%% Debug
a= {this.dataset, this.acceptanceClassifier, this.scorer, svmAcc,svmRej}; %DEBUG

% PREPROCESSING
% SVM gamma -> stadiaki meiosi
% 1. hand-crafted rules (throw 5% min/max from critical metric distributions)
% 2. xreiazetai to SVM en telei?
% Play with 1 repo models (+model selector before the models)
