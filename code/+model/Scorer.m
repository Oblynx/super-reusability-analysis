classdef Scorer < model.Model
% Estimates a reusability score for each input
properties
end

methods
  function this= Scorer()
    this@model.Model('code/+model/Scorer_storedmodel.mat');
  end

  function evalResults= train(this, dataset, targetset)
  % After training, the model is stored in the 'storedmodelpath' file and can be
  % used after MATLAB restarts, until train is called again.
    this.model= fitcsvm();
  end
  
  function y= infer(x)
  end
end

end
