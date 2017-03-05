classdef Scorer < model.Model
% Estimates a reusability score for each input

properties (SetAccess= immutable)
  correlatedMetricsToRemove= ...
    [4,5,6,7,11,16,19,20,21,29,30,31,32,33,37,38,39,41,42,46,47,48,49,50,51,52,55,56,58];
end
properties
  params= struct( ...
    'hiddenLayerSize',[22],...   % Size of each hidden layer
    'trainFcn','trainlm',...        % Training function (trainlm,trainscg,trainbr)
    'performFcn','mse',...          % Error function
    'max_fail',12,...               % Terminate if validation increases for this many epochs
    'ratios', [0.7 0.15 0.15] ...
    );
end

methods
  function this= Scorer()
    this@model.Model('code/+model/Scorer_storedmodel.mat');
  end
%
  function evalResults= train(this, dataset, targetset, repoStarts)
  % After training, the model is stored in the 'storedmodelpath' file and can be
  % used after MATLAB restarts, until train is called again.
    assert(~isempty(dataset));
    % NN requires observations in columns, not rows
    dataset= dataset{:,:};
    x= dataset'; t= targetset';
    
    this.model= fitnet(this.params.hiddenLayerSize,this.params.trainFcn);
    %this.model= patternnet(this.params.hiddenLayerSize, this.params.trainFcn);
    if nargin < 4, this.configureModel();
    else this.configureModel(repoStarts); end
    
    this.model.layers{1}.transferFcn= 'tansig';
    %this.model.layers{2}.transferFcn= 'radbasn';
       
    %% Train model
    [this.model,tr]= train(this.model,x,t, 'useParallel','yes', 'showresources','yes');
    %c= utils.discretizeLevels(t,t);
    %[this.model,tr]= train(this.model,x,c, 'useParallel','yes', 'showresources','yes');
    %% Evaluate model
    %
    y= this.model(x);
    rerr= gdivide(gsubtract(y,t), t+min(t));
    trainRerr= median(abs(rerr(tr.trainInd)))
    valRerr= median(abs(rerr(tr.valInd)))
    testRerr= median(abs(rerr(tr.testInd)))
    %}
    % Save to file and return evaluation
    this.saveModel();
    this.initialized= true;
    evalResults= struct('trainRerr',trainRerr,'valRerr',valRerr,'testRerr',testRerr);
  end
%}
%{
  function evalResults= train(this, dataset, targetset)
    % Arrange dataset
    dataset= dataset{:,:};
    x= dataset'; t= targetset';
    nobs= size(dataset,1);
    trainIdx= randsample(1:nobs, floor(this.params.ratios(1)*nobs));  % numeric
    testIdx= utils.allbut(nobs, trainIdx);  % logical
    xtrain= x(:,trainIdx); ttrain= t(trainIdx); xtest= x(:,testIdx); ttest= t(testIdx);
    % Make classes
    ctrain= utils.discretizeLevels(ttrain, ttrain);
    ctest= utils.discretizeLevels(ttest, ttrain);
    
    %{
    % Build autoencoder feature extractor
    autoenc= trainAutoencoder(xtrain,this.params.hiddenLayerSize(1), ...
      'MaxEpochs',1000, ...
      'L2WeightRegularization',0.001, ...
      'SparsityRegularization',4, ...
      'SparsityProportion',0.05, ...
      'DecoderTransferFunction','purelin');
    plotWeights(autoenc);
    features= autoenc.encode(xtrain);
    %}
    
    %softnet = trainSoftmaxLayer(features,ctrain,'MaxEpochs',700);
    %classifier = stack(autoenc,softnet);
    % Evaluate
    xrec= autoenc.predict(xtrain);
    autoencMse= mse(xtrain-xrec)
    y= classifier(xtest);
    figure, plotconfusion(ctest,y, 'Before tuning');
    % Tune
    classifier= classifier.train(xtrain,ctrain);
    % Evaluate tuned
    y= classifier(xtest);
    plotconfusion(ctest,y, 'After tuning');
  end
%}
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
    this.model.plotParams{3}.bins= 50;
    
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
