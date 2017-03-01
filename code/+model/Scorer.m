classdef Scorer < model.Model
% Estimates a reusability score for each input

properties
  param= struct( ...
    'hiddenLayerSize',[80, 30, 5],...   % Size of each hidden layer
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
    
    % NN requires observations in columns, not rows
    x= dataset'; t= targetset';
    trainFcn= this.param.trainFcn;
    this.model= fitnet(this.param.hiddenLayerSize,trainFcn);
    if nargin < 4, this.configureModel();
    else this.configureModel(repoStarts); end
    
    %% Train model
    [this.model,tr]= train(this.model,x,t, 'useParallel','yes', 'showresources','yes');
    %figure, plotperform(tr);
    
    %% Evaluate model
    y= this.model(x);
    trainTargets= t .* tr.trainMask{1};
    validTargets= t .* tr.valMask{1};
    testTargets= t .* tr.testMask{1};
    trainRelPerformance= perform(this.model,trainTargets,y) ./ median(t)
    validRelPerformance= perform(this.model,validTargets,y) ./ median(t)
    testRelPerformance= perform(this.model,testTargets,y) ./ median(t)
    testAbsPerformance= perform(this.model,testTargets,y)
    
    % Save to file and return evaluation
    this.saveModel();
    this.initialized= true;
    evalResults= struct('trainPerform',trainRelPerformance, ...
      'validPerform',validRelPerformance, 'testPerform',testRelPerformance);
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
    this.model.output.processFcns= {'removeconstantrows','mapminmax','processpca'};
    this.model.performFcn= this.param.performFcn;
    this.model.plotFcns= {'plotperform','ploterrhist','plotregression'};
    %this.model.plotParams{2}.bins= 30;
    
    this.model.trainParam.showCommandLine= true;
    this.model.trainParam.showWindow= false;
    this.model.trainParam.max_fail= this.param.max_fail;
    
    %% Divide dataset to train,validation,test parts
    % For the time being, the naive approach of treating each sample independently is followed
    this.param.ratios= this.param.ratios/sum(this.param.ratios);
    %if nargin < 2
      % If this is a single repo, split among the data
      this.model.divideFcn= 'dividerand';  % Divide data randomly
      this.model.divideParam.trainRatio= this.param.ratios(1);
      this.model.divideParam.valRatio= this.param.ratios(2);
      this.model.divideParam.testRatio= this.param.ratios(3);
    %{
    else
      % If there are multiple repos, then split along the repos (some repos for
      % training, others for testing)
      nrepos= length(repoStarts)-1;   % -1 because the last repoStart is the start of the next repo
      trainRepos= randsample(nrepos, nrepos -floor(this.param.ratios(2)*nrepos) -floor(this.param.ratios(3)*nrepos));
      valRepos= randsample(nrepos, floor(this.param.ratios(2)*nrepos));
      testRepos= randsample(nrepos, floor(this.param.ratios(3)*nrepos));
      
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
