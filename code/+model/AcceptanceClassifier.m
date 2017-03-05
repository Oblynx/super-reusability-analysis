classdef AcceptanceClassifier < model.Model
% Decides if the input quality is acceptable for further analysis

properties (SetAccess= immutable)
  acceptanceMetrics= ...    % Metrics that decide if the object is accepted
    [25    57     3    22    12    17    59     8    23    13];
    %{'TCLOC','TNOS','CCO','PDA','WMC','RFC','TNPM','LLDC','PUA','CBO'};
end
properties
  %storedmodelpath= 'code/+model/AcceptanceClassifier_storedmodel.mat';
  %model;
  supportVectorRatio;
  outlierFraction;
  params= struct( ...
    'passScore',0 ...
    );
end

methods
  function this= AcceptanceClassifier()
    this= this@model.Model('code/+model/AcceptanceClassifier_storedmodel.mat');
  end

  function train(this, dataset)
  % Trains a one-class SVM that eliminates objects that don't meet the dataset's 
  % quality standards. After training, the model is stored in the 'storedmodelpath'
  % file and can be used after MATLAB restarts, until train is called again.
  % dataset [table]
    fprintf('[AcceptClassifier::train]: dataset size: %dx%d\n', ...
      size(dataset,1), size(dataset,2));
    this.model= fitcsvm(dataset,ones(size(dataset,1),1), 'Standardize',true, ...
      'KernelScale','auto', 'Nu',0.20, 'OutlierFraction',0.05,'Verbose',1);
    this.supportVectorRatio= size(this.model.SupportVectors,1)/size(dataset,1)
    this.model.KernelParameters
    this.saveModel();
    % Assess outlier fraction
    %{
    cvmodel= crossval(this.model,'kfold',3);
    [~,score]= cvmodel.kfoldPredict();
    [~,score2]= this.model.predict(dataset);
    this.outlierFraction= mean(score < 0)
    outlierFraction2= mean(score2 < 0)
    %this.model= compact(this.model);  % Shed training data from model
    this.saveModel();
    %}
    this.initialized= true;
  end

  function y= infer(x)
  end
  
  function passMask= filter(this, dataset)
    [~,score]= this.model.predict(dataset);
    passMask= score > this.params.passScore;
    fprintf('[Acceptance::filter]: %f%% rejected\n', 1-sum(passMask)/length(passMask));
  end
  
end

end
