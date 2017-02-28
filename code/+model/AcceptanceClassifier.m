classdef AcceptanceClassifier < model.Model
% Decides if the input quality is acceptable for further analysis

properties
  %storedmodelpath= 'code/+model/AcceptanceClassifier_storedmodel.mat';
  %model;
end

methods
  function this= AcceptanceClassifier()
    %{
    if ~isempty(dir(this.storedmodelpath))  % If stored parameters exist
      try
        load(this.storedmodelpath);
        this.model= storedmodel;  % storedmodel: var name in file
      catch
      end
    end
    %}
    this@model.Model('code/+model/AcceptanceClassifier_storedmodel.mat');
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
