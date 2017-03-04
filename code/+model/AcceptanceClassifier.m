classdef AcceptanceClassifier < model.Model
% Decides if the input quality is acceptable for further analysis

properties (SetAccess= immutable)
  acceptanceMetrics= ...    % Metrics that decide if the object is accepted
    [25    59     3    15    57    22    17    12    14    54];
    %{'TCLOC','TNPM','CCO','NII','TNOS','PDA','RFC','WMC','CBOI','TNLPM'};
end
properties
  %storedmodelpath= 'code/+model/AcceptanceClassifier_storedmodel.mat';
  %model;
  supportVectorRatio;
  outlierFraction;
  params= struct( ...
    'passScore',0.9 ...
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
    this.model= fitcsvm(dataset,ones(size(dataset,1),1), 'Standardize',true, ...
      'KernelScale',0.1, 'Nu',0.1, 'Verbose',1);
    % Assess outlier fraction
    %
    cvmodel= crossval(this.model,'kfold',3);
    [~,score]= cvmodel.kfoldPredict();
    this.outlierFraction= mean(score < 0)
    %}
    this.supportVectorRatio= size(this.model.SupportVectors,1)/size(dataset,1)
    
    this.model= compact(this.model);  % Shed training data from model
    this.saveModel();
    this.initialized= true;
  end

  function y= infer(x)
  end
  
  function pass= filter(this, dataset)
    [~,score]= this.model.predict(dataset);
    pass= score > this.params.passScore;
  end
  
end

end
