clear; close all;
addpath('code');

system= model.System;   % Constructs a "System" object
a=system.trainAll();

dataset= a{1}; accClass= a{2}; scorer= a{3};
[dsetT,tset]= dataset.getScorer();
dset= dsetT{:,:};

%% Here we can play with the scorer, change its parameters and train again
%{
% Data correlation
r_data= corr(dset);
figure, imagesc(r_data); colorbar; title('Metrics correlations after elimination');
% Metrics PCA
[~,pcProjection,~,~,var_attr]= pca(dset);
var_attr(1:20)
r_pca= corr(dset, pcProjection(:,1:5));     % Correlate metrics with 5 dominant PCs (92% variance)
pred_score= sum(abs(r_pca),2);              % Metric PC score
[~,best_pred]= sort(pred_score,'descend');
% Show best metrics in order
best_names= dsetT(1,best_pred).Properties.VariableNames; best_names= best_names(1:10);
bar(abs(r_pca(best_pred(1:10),:))); title('Best Metric-PC correlations'); grid on;
set(gca, 'XTickLabel',best_names, 'XTick',1:numel(best_names));
%}


%% Notes
% Correlated pairs
%5,6, 7,8, {-20,--21,25}, {-19,24}, {-37,39}, 27,29, 
%{-31,--32,-42,57,-46,-47},
%{{--33,-43,-48,58}, {-35,-38,-50,53}}, {-40,55},
%{--41,--44,-52,54,-56,59}
