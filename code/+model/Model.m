classdef Model
% Defines the interface for each model
properties %(Access= protected)
  storedmodelpath;
  model;
  initialized= false;
end

methods (Abstract)
  y= infer(x);
  evalResults= train(this, dataset, targetset);
end

methods (Access= protected)
  function this= Model(storedmodelpath)
    this.storedmodelpath= storedmodelpath; 
    if ~isempty(dir(this.storedmodelpath))  % If stored parameters exist
      try
        load(this.storedmodelpath);
        this.model= storedmodel;  % storedmodel: var name in file
        this.initialized= true;
      catch
        % Doesn't matter if it fails
        fprintf('No model was loaded from "%s"\n', this.storedmodelpath);
      end
    end
  end
  
  function score= evaluate(this, testSet)
  end
end
end
