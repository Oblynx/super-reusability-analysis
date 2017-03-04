function a=trainAll(this)
% System::train is the main editable script for running experiments

%% Preprocess
maxrepo= 90;
%[dataset,repoStarts,allDatasets]= this.prepareDataset('Class',maxrepo);
this.prepareDataset('Class',maxrepo);

% Metrics correlation analysis
%{
this.filterDataset(ones(148464,1));
dset= this.dataset.getScorer();
utils.metricCorr(dset,0.85, []);
%toremove= [4,5,6,7,19,20,21,27,29,31,32,33,37,41,42,46,47,48,50,52,56]; utils.metricCorr(dset,0.8, toremove);
%}

%% Acceptance model
% Train scorer only on good samples
%this.acceptanceClassifier.train(this.dataset.getAcc());
acceptanceMask= this.acceptanceClassifier.filter(this.dataset.getScorer());
this.filterDataset(acceptanceMask);

%% Scoring model
this.dataset.setTarget(@(repoD,repoN) model.target.cl_full(repoD, ...
                            this.reader.repositories(repoN,:)), [14 54]);

[scorerData,scorerTarget]= this.dataset.getScorer();
fprintf('Scorer dataset size: %dx%d\n', size(scorerData,1), size(scorerData,2));
this.scorer.train(scorerData,scorerTarget);

% That's it!

% PREPROCESSING
% SVM gamma -> stadiaki meiosi
% 1. hand-crafted rules (throw 5% min/max from critical metric distributions)
% 2. xreiazetai to SVM en telei?
% Play with 1 repo models (+model selector before the models)

%% Debug
a= {this.dataset, this.acceptanceClassifier, this.scorer};
