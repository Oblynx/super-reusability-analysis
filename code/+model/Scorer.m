classdef Scorer < model.Model
% Estimates a reusability score for each input

properties (SetAccess= immutable)
  correlatedMetricsToRemove= ...
    [4,5,6,7,11,16,19,20,21,29,30,31,32,33,37,38,39,41,42,46,47,48,49,50,51,52,55,56,58];
end
properties
  params= struct( ...
    'hiddenLayerSize',[80 8],...   % Size of each hidden layer
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
  function evalResults= train(this, dataset, targetset)
  % After training, the model is stored in the 'storedmodelpath' file and can be
  % used after MATLAB restarts, until train is called again.
    assert(~isempty(dataset));
    % NN requires observations in columns, not rows
    dataset= dataset{:,:};
    x= dataset'; t= targetset';
    
    this.model= fitnet(this.params.hiddenLayerSize(2),this.params.trainFcn);
    this.configureModel(dataset);
    
    %% Autoencoder feature extraction
    xtrain= x(:,this.model.divideParam.trainInd);
    autoenc= trainAutoencoder(xtrain,this.params.hiddenLayerSize(1), ...
      'MaxEpochs',2500, ...
      'L2WeightRegularization',0.001, ...
      'SparsityRegularization',10, ...
      'SparsityProportion',0.05, ...
      'useGPU',true);
    plotWeights(autoenc);
    xauto= autoenc.predict(xtrain);
    autoencMAE= mean(abs(xauto(:)-xtrain(:)))
    % Train regression layer
    features= autoenc.encode(x);
    this.model.trainParam.show= 20;
    [this.model,tr_regress]= train(this.model,features,t, 'useParallel','yes', 'showresources','yes');
    regressionLayer= this.model;
    save('untuned_net', 'autoenc','regressionLayer','tr_regress');
    % Evaluate without tuning
    y= this.model(features);
    rerr= gdivide(gsubtract(y,t), t+eps);
    trainRerr_untuned= median(abs(rerr(tr_regress.trainInd)))
    valRerr_untuned= median(abs(rerr(tr_regress.valInd)))
    testRerr_untuned= median(abs(rerr(tr_regress.testInd)))
    %% Tune stacked network
    this.model= stack(autoenc,this.model);
    this.model.trainParam.show= 5;
    [this.model,tr_stack]= train(this.model,x,t, 'useParallel','no', 'useGPU','yes', 'showresources','yes');
    tunedModel= this.model;
    save('tuned_net', 'tunedModel','tr_stack');
    %% Evaluate model
    %
    y= this.model(x);
    rerr= gdivide(gsubtract(y,t), t+eps);
    trainRerr= median(abs(rerr(tr_stack.trainInd)))
    valRerr= median(abs(rerr(tr_stack.valInd)))
    testRerr= median(abs(rerr(tr_stack.testInd)))
    %
    % Save to file and return evaluation
    this.saveModel();
    this.initialized= true;
    evalResults= struct('trainRerr',trainRerr,'valRerr',valRerr,'testRerr',testRerr);
  end

  function y= infer(this, x)
    if this.initialized
      x= x{:,:}';
      y= this.model(x);
    else
      fprintf('[Scorer::infer]: Attempted to use untrained model. Train first\n');
    end
  end
  
  function this= configureModel(this, dataset)
    this.model.input.processFcns= {'removeconstantrows','mapminmax'};
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
  end
end

end
