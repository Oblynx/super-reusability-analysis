classdef Scorer < model.Model
% Estimates a reusability score for each input

properties (SetAccess= immutable)
  correlatedMetricsToRemove= ...
    [4,5,6,7,11,16,19,20,21,29,30,31,32,33,37,38,39,41,42,46,47,48,49,50,51,52,55,56,58];
end
properties
  params= struct( ...
    'hiddenLayerSize',[20 5],...   % Size of each hidden layer
    'trainFcn','trainlm',...        % Training function (trainlm,trainscg,trainbr)
    'performFcn','mse',...          % Error function
    'max_fail',10,...               % Terminate if validation increases for this many epochs
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
    if nargin < 4, this.configureModel(dataset);
    else this.configureModel(dataset,repoStarts); end
    
    %% Autoencoder feature extraction
    %{
    xtrain= x(:,this.model.divideParam.trainInd);
    autoenc= trainAutoencoder(xtrain,this.params.hiddenLayerSize(1), ...
      'MaxEpochs',1500, ...
      'L2WeightRegularization',0.001, ...
      'SparsityRegularization',5, ...
      'SparsityProportion',0.2, ...
      'useGPU',true);
    plotWeights(autoenc);
    y= autoenc.predict(xtrain);
    autoencMAE= median(abs(y-xtrain))
    % Train regression layer
    features= autoenc.encode(x);
    [this.model,tr]= train(this.model,features,t, 'useParallel','yes', 'showresources','yes');
    this.model= stack(autoenc,this.model);
    % Tune stacked network
    %[this.model,tr]= train(this.model,x,t, 'useParallel','yes', 'showresources','yes');
    %}
    %% Train model
    [this.model,tr]= train(this.model,x,t, 'useParallel','yes', 'showresources','yes','useGPU','no');
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
  
  function this= configureModel(this, dataset,repoStarts)
    this.model.input.processFcns= {'removeconstantrows','mapminmax','processpca'};
    this.model.output.processFcns= {'removeconstantrows','mapminmax'};
    this.model.performFcn= this.params.performFcn;
    this.model.plotParams{3}.bins= 40;
    %this.model.layers{1}.transferFcn= 'tansig';
    %this.model.layers{2}.transferFcn= 'radbasn';
    
    % Training parameters
    this.model.trainParam.showCommandLine= true;
    this.model.trainParam.showWindow= true;
    if strcmp(this.params.trainFcn,'trainlm'), this.model.trainParam.show= 10; end;
    this.model.trainParam.max_fail= this.params.max_fail;
    
    %% Divide dataset to train,validation,test parts
    % For the time being, the naive approach of treating each sample independently is followed
    this.params.ratios= this.params.ratios/sum(this.params.ratios);
    %if nargin < 3
      % If this is a single repo, split among the data
      n= size(dataset,1);
      idx= zeros(n,1); population= 1:n;
      testIdx= randsample(population, floor(this.params.ratios(3)*n));
      idx(testIdx)= 3; population= find(idx==0);
      valIdx= randsample(population, floor(this.params.ratios(2)*n));
      idx(valIdx)= 2;
      trainIdx= find(idx==0);
      
      this.model.divideFcn= 'divideind';
      this.model.divideParam.trainInd= trainIdx;
      this.model.divideParam.valInd= valIdx;
      this.model.divideParam.testInd= testIdx;
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
