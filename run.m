clear; close all;
addpath('code');

system= model.System;   % Constructs a "System" object
a=system.trainAll();

dset= a{1}; tset= a{2}; scorer= a{3};

%% Here we can play with the scorer, change its parameters and train again
%
% Data correlation
r_data= corr(dset);
figure, imagesc(r_data); colorbar;
% Metrics PCA
[~,pcProjection,~,~,var_attr]= pca(dset);
var_attr(1:22)
r_pca= corr(dset, pcProjection(:,1:5));
pred_score= sum(abs(r_pca),2);
[~,best_pred]= sort(pred_score,'descend');
%}

% From PCA analysis, these are some of the most diverse predictors
%32,42,4,8,56,59,17,12,51,54,37,47,39,16

%% Correlated pairs
%5,6, 7,8, {-20,--21,25}, {-19,24}, {-37,39}, 27,29, 
%{-31,--32,-42,57,-46,-47},
%{{--33,-43,-48,58}, {-35,-38,-50,53}}, {-40,55},
%{--41,--44,-52,54,-56,59}
