%clear; close all;
addpath('code');

system= model.System;   % Constructs a "System" object
a=system.trainAll();

dset= a{1}; tset= a{2}; scorer= a{3};

%% Here we can play with the scorer, change its parameters and train again
%{
% Data correlation
r_data= corr(dset);
figure, imagesc(r_data);
% Metrics PCA
[~,pcProjection,~,~,var_attr]= pca(dset);
var_attr(1:22)
r_pca= corr(dset, pcProjection(:,1:3));
pred_score= sum(abs(r_pca),2);
[~,best_pred]= sort(pred_score,'descend');
%}

% From PCA analysis, these are some of the most diverse predictors
%32,42,4,8,56,59,17,12,51,54,37,47,39,16
