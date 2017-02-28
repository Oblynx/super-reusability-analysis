classdef AcceptanceClassifier < model.Model
% Decides if the input quality is acceptable for further analysis

properties
  %storedmodelpath= 'code/+model/AcceptanceClassifier_storedmodel.mat';
  %model;
end

methods
  function this= AcceptanceClassifier()
    this= this@model.Model('code/+model/AcceptanceClassifier_storedmodel.mat');
  end

  function train(this, dataset)
  % After training, the model is stored in the 'storedmodelpath' file and can be
  % used after MATLAB restarts, until train is called again.
    this.model= fitcsvm(dataset,ones(size(dataset,1),1), 'Standardize',true, ...
      'KernelFunction','RBF', ...
      'KernelScale','auto', 'OutlierFraction',0.05, 'Nu',0.3);
    this.saveModel();
  end

  function y= infer(x)
  end
end

end
