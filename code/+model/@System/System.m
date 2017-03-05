classdef System < handle
  % The system is a network of connected models that infers
  properties
    reader;
    acceptanceClassifier;
    scorer;
    dataset;
  end
  
  methods
    function this= System()
      this.reader= DataReader;
      this.acceptanceClassifier= model.AcceptanceClassifier;
      this.scorer= model.Scorer;
    end
    
    function prepareDataset(this, type, maxrepo)
    % type: {'Method','Class','Package'}
    % maxrepo: keep repos from 1 to maxrepo
      % Load all project class metrics
      this.dataset= this.reader.loadAll(type,true);
      this.dataset.selectedRepos(maxrepo+1:end)= 0;
      this.dataset.selector.scorerC(61:end)= 0;
      this.dataset.selector.accC(:)= 0;
      
      % Remove low quality data based on fixed rules
      this.filterDataset(this.lowQualityMask());
      % Eliminate correlations
      this.dataset.selector.scorerC(this.scorer.correlatedMetricsToRemove)= 0;
      % Select ACC metrics based on PCA
      this.dataset.selector.accC(this.acceptanceClassifier.acceptanceMetrics)= 1;
    end
    
    function mask= lowQualityMask(this)
      d= this.dataset.getScorer();
      f1= d.TNOS > 8;         % Remove too small classes (>50% of dataset!!!)
      f2= d.CBO > 0;          % Remove classes that aren't used by anyone else (not reusable)
      f3= (d.NLPM > 0) | (d.NLPA > 0);  % Remove classes without any public methods or attributes
      mask= f1&f2&f3;
    end
    
    function filterDataset(this, mask)
    % Apply filters to data. Only deselects.
      currentlySelected= this.dataset.selector.R==1;
      this.dataset.selector.R(currentlySelected)= ...
        this.dataset.selector.R(currentlySelected) & mask;
    end

    a= trainSingle(this);
    a= trainAll(this);
  end
end
