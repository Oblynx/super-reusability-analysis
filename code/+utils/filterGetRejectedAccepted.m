function [acc,rej]= filterGetRejectedAccepted(dataset,pre)
% Finds the accepted and the rejected data after the application of a data filter,
% in order to evaluate the filter
preC= dataset.selector.scorerC;
post= dataset.selector.R;

diff= (~post)&pre;          % Select those that were filtered out
dataset.selector.R= diff;
dataset.selector.scorerC(61:end)= 1;
[rej.dset,rej.tset]= dataset.getScorer(true);

dataset.selector.R= post;
[acc.dset,acc.tset]= dataset.getScorer(true);
dataset.selector.scorerC= preC;
