% This script is the entrypoint for training the system with the class data

clear; close all;
addpath('code');
% Train the system
system= model.System;   % Constructs a "System" object
a=system.trainAll();
% Get debugging data
dataset= a{1}; accClass= a{2}; scorer= a{3}; svmAcc= a{4}; svmRej= a{5};
[dsetT,tset]= dataset.getScorer();
dset= dsetT{:,:};

%% Here we can play with the scorer, change its parameters and train again
%{
% Metrics PCA
[~,pcProjection,~,~,var_attr]= pca(dset);
var_attr(1:20)
r_pca= corr(dset, pcProjection(:,1:5));     % Correlate metrics with 5 dominant PCs (92% variance)
pred_score= mean(abs(r_pca),2);              % Metric PC score
[pred_score_sorted,best_pred]= sort(pred_score,'descend');
best_names= dsetT(1,best_pred).Properties.VariableNames; best_names= best_names(1:15);

% Show best metrics in order
figure; subplot(211);
bar(abs(r_pca(best_pred(1:15),:))); title('Highest metric - PC correlations'); grid on;
xticklabels(best_names(1:15));
subplot(212);
plot(pred_score_sorted(1:18),'-d'); xlabel('metric rank'); ylabel('mean correlation with PC');
grid minor; title('Highest metric - PC mean correlation');
xticks(1:15); xticklabels(best_names);
%}
%{
ts= cellfun(@(repod,repon) model.target.cl_star(repod,system.reader.repositories(repon,:)),...
  dataset.fulldata(:,2), dataset.fulldata(:,1), 'Uniformoutput',false);
tf= cellfun(@(repod,repon) model.target.cl_fork(repod,system.reader.repositories(repon,:)),...
  dataset.fulldata(:,2), dataset.fulldata(:,1), 'Uniformoutput',false);
ts= vertcat(ts{dataset.selectedRepos});
tf= vertcat(tf{dataset.selectedRepos});

dataset.setTarget(@(repoD,repoN) model.target.cl_full(repoD, ...
  system.reader.repositories(repoN,:)), [59]);
[~,tfull]= dataset.getScorer();
%}
