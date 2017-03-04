function a=trainAll(this)
% System::train is the main editable script for running experiments

%% Preprocess
maxrepo= 100;
%[dataset,repoStarts,allDatasets]= this.prepareDataset('Class',maxrepo);
this.prepareDataset('Class',maxrepo);

%% Scoring model
% Calculate the target set according to target::cl_star
%{
targetset= cell(dataset.repoNum,1);
for i= 1:length(targetset)
  targetset{i}= model.target.cl_full(allDatasets{i,2}, this.reader.repositories(allDatasets{i,1},:));
end
%}
%targetset= cellfun(@(repoD,repoN) model.target.cl_full(repoD, this.reader.repositories(repoN,:)), ...
%                   allDatasets(:,2), allDatasets(:,1), 'UniformOutput',false);
%targetset= vertcat(targetset{1:maxrepo});

% Train scorer only on good samples
this.acceptanceClassifier.train(this.dataset.getAcc());
acceptanceMask= this.acceptanceClassifier.filter(dataset);
this.filterDataset(acceptanceMask);

this.dataset.setTarget(@(repoD,repoN) model.target.cl_full(repoD, ...
                            this.reader.repositories(repoN,:)), [14 54]);


[scorerData,scorerTarget]= this.dataset.getScorer();
this.scorer.train(scorerData,scorerTarget);

% That's it!

% PREPROCESSING
% SVM gamma -> stadiaki meiosi
% 1. hand-crafted rules (throw 5% min/max from critical metric distributions)
% 2. xreiazetai to SVM en telei?
% Play with 1 repo models (+model selector before the models)

%% Debug
a= {this.dataset, this.acceptanceClassifier, this.scorer};
