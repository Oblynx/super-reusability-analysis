classdef Scorer < model.Model
% Estimates a reusability score for each input

properties (SetAccess= immutable)
  correlatedMetricsToRemove= ...
    [4,5,6,7,19,20,21,27,29,31,32,33,37,41,42,46,47,48,50,52,56];
    %[5,6,7,8,20,21,19,37,27,29,31,32,42,46,47,33,43,48,35,38,50,40,41,44,52,56];
end
properties
  params= struct( ...
    'hiddenLayerSize',[25 38],...   % Size of each hidden layer
    'trainFcn','trainlm',...        % Training function (trainlm,trainscg,trainbr)
    'performFcn','mse',...          % Error function
    'max_fail',30,...               % Terminate if validation increases for this many epochs
    'ratios', [0.7 0.15 0.15] ...
    );
end

methods
  function this= Scorer()
    this@model.Model('code/+model/Scorer_storedmodel.mat');
  end

  function evalResults= train(this, dataset, targetset, repoStarts)
  % After training, the model is stored in the 'storedmodelpath' file and can be
  % used after MATLAB restarts, until train is called again.
    assert(~isempty(dataset));
    % NN requires observations in columns, not rows
    dataset= dataset{:,:};
    x= dataset'; t= targetset';
    trainFcn= this.params.trainFcn;
    this.model= fitnet(this.params.hiddenLayerSize,trainFcn);
    if nargin < 4, this.configureModel();
    else this.configureModel(repoStarts); end
    
    this.model.layers{1}.transferFcn= 'tansig';
    %this.model.layers{2}.transferFcn= 'radbasn';
    %% Train model
    [this.model,tr]= train(this.model,x,t, 'useParallel','yes', 'showresources','yes');
    %% Evaluate model
    y= this.model(x);
    rerr= gdivide(gsubtract(y,t), t+min(t));
    %trainTargets= t .* tr.trainMask{1};
    %validTargets= t .* tr.valMask{1};
    %testTargets= t .* tr.testMask{1};
    %trainRelPerformance= perform(this.model,trainTargets,y) ./ median(t)
    %validRelPerformance= perform(this.model,validTargets,y) ./ median(t)
    %testRelPerformance= perform(this.model,testTargets,y) ./ median(t)
    %testAbsPerformance= perform(this.model,testTargets,y)
    trainRerr= median(abs(rerr(tr.trainInd)))
    valRerr= median(abs(rerr(tr.valInd)))
    testRerr= median(abs(rerr(tr.testInd)))
    
    % Save to file and return evaluation
    this.saveModel();
    this.initialized= true;
    %evalResults= struct('trainPerform',trainRelPerformance, ...
    %  'validPerform',validRelPerformance, 'testPerform',testRelPerformance);
    evalResults= struct('trainRerr',trainRerr,'valRerr',valRerr,'testRerr',testRerr);
  end
  
  function y= infer(this, x)
    if this.initialized
      y= this.model(x);
    else
      fprintf('[Scorer::infer]: Attempted to use untrained model. Train first\n');
    end
  end
  
  function this= configureModel(this, repoStarts)
    this.model.input.processFcns= {'removeconstantrows','mapminmax','processpca'};
    this.model.output.processFcns= {'removeconstantrows','mapminmax'};
    this.model.performFcn= this.params.performFcn;
    this.model.plotFcns= {'plotperform','ploterrhist','plotregression'};
    this.model.plotParams{2}.bins= 30;
    
    % Training parameters
    this.model.trainParam.showCommandLine= true;
    this.model.trainParam.showWindow= true;
    if strcmp(this.params.trainFcn,'trainlm'), this.model.trainParam.show= 10; end;
    this.model.trainParam.max_fail= this.params.max_fail;
    
    %% Divide dataset to train,validation,test parts
    % For the time being, the naive approach of treating each sample independently is followed
    this.params.ratios= this.params.ratios/sum(this.params.ratios);
    %if nargin < 2
      % If this is a single repo, split among the data
      this.model.divideFcn= 'dividerand';  % Divide data randomly
      this.model.divideParam.trainRatio= this.params.ratios(1);
      this.model.divideParam.valRatio= this.params.ratios(2);
      this.model.divideParam.testRatio= this.params.ratios(3);
    %{
    else
      % If there are multiple repos, then split along the repos (some repos for
      % training, others for testing)
      nrepos= length(repoStarts)-1;   % -1 because the last repoStart is the start of the next repo
      trainRepos= randsample(nrepos, nrepos -floor(this.params.ratios(2)*nrepos) -floor(this.params.ratios(3)*nrepos));
      valRepos= randsample(nrepos, floor(this.params.ratios(2)*nrepos));
      testRepos= randsample(nrepos, floor(this.params.ratios(3)*nrepos));
      
      trainInd= arrayfun(@(x) (repoStarts(x):repoStarts(x+1)-1), ...
        trainRepos, 'UniformOutput',false);
      valInd= arrayfun(@(x) (repoStarts(x):repoStarts(x+1)-1), ...
        valRepos, 'UniformOutput',false);
      testInd= arrayfun(@(x) (repoStarts(x):repoStarts(x+1)-1), ...
        testRepos, 'UniformOutput',false);
      
      this.model.divideFcn= 'divideind';
      this.model.divideParam.trainInd= [trainInd{:}];
      this.model.divideParam.valInd= [valInd{:}];
      this.model.divideParam.testInd= [testInd{:}];
    end
    %}
  end
end

end
