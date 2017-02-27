classdef AcceptanceClassifier < Model
% Decides if the input quality is acceptable for further analysis

properties
  storedmodelpath= 'code/+model/AcceptanceClassifier_storedmodel.mat';
  model
end

methods
  function this= AcceptanceClassifier()
    if ~isempty(dir(this.storedmodelpath))  % If stored parameters exist
      load(storedmodelpath);
      this.model= storedmodel;  % storedmodel: var name in file
    end
  end

  function evalResults= train(this, dataset, targetset)
  % After training, the model is stored in the 'storedmodelpath' file and can be
  % used after MATLAB restarts, until train is called again.
    model= fitcsvm();
  end
end

end
