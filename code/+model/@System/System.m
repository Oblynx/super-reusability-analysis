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
    
    %function [dataset,repoStarts,allDatasets]= prepareDataset(this, type, maxrepo)
    function this= prepareDataset(this, type, maxrepo)
    % type: {'Method','Class','Package'}
    % maxrepo: keep repos from 1 to maxrepo
      % Load all project class metrics
      this.dataset= this.reader.loadAll(type,true);
      %{
      dataset= vertcat(allDatasets{1:maxrepo,2});     % Implode all tables into one
      dataset= dataset(:,11:70);                      % Select static analysis metrics
      dataset= utils.eliminateCorrelatedMetrics(dataset);
      % Keep track of how many classes were in each repo. Useful in dividing train/test sets
      repoLengths= cellfun(@(x) size(x,1), allDatasets(:,2));
      repoStarts= cumsum([1;repoLengths]);
      %}
      this.dataset.selectedRepos(maxrepo+1:end)= 0;
      this.dataset.selector.scorerC(61:end)= 0;
      
      % Eliminate correlations
      this.dataset.selector.scorerC(this.scorer.correlatedMetricsToRemove)= 0;
      % Select based on PCA
      this.dataset.selector.accC(this.acceptanceClassifier.acceptanceMetrics)= 1; 
    end
    
    a= trainSingle(this)
    a= trainAll(this)
    
    function filterDataset(this, acceptanceMask)
      f1= this.dataset.getScorer().TNOS > 12;
      %f2=
      
      % Apply filters
      this.dataset.selector.scorerR= this.dataset.selector.scorerR & f1 & acceptanceMask;
      this.dataset.selector.accR= this.dataset.selector.accR & f1 & acceptanceMask;
    end
  end
end
