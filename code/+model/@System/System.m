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
    
    function y= infer(this, x)
    % Shows the datapath through the system. The Dataset class is not used for clarity.
      x= x(:,11:70);  % Keep metrics only
      % Determine if some preprocessing filter fails
      selectedData= logical(ones(size(x,1),1));   % First, everything is selected
      rulesMask= this.lowQualityMask(x);          % Mask which keeps only the classes that pass
      selectedData= selectedData & rulesMask;
      % Eliminate correlated metrics
      selectedMetrics= logical(ones(size(x,2),1));
      selectedMetrics(this.scorer.correlatedMetricsToRemove)= 0;
      
      xSVM= x(selectedData,selectedMetrics);
      % Pass through SVM one-class classifier
      acceptanceMask= this.acceptanceClassifier.filter(xSVM);
      selectedData(selectedData==1)= selectedData(selectedData==1) & acceptanceMask;
      % Finally, remove metrics correlated to the targetset
      selectedMetrics([14 44 59])= 0;             % Metrics correlated to targetset
      
      % Now all the filters have been applied
      y= zeros(size(x,1),1);
      xscorer= x(selectedData, selectedMetrics);
      y(selectedData)= this.scorer.infer(xscorer);
    end
    
    
    function prepareDataset(this, type, maxrepo)
    % type: {'Method','Class','Package'}
    % maxrepo: keep repos from 1 to maxrepo
      % Load all project class metrics
      this.dataset= this.reader.loadAll(type,true);
      this.dataset.selectedRepos(maxrepo+1:end)= 0;
      % Remove top-5% most-starred & forked repos (from total repos)
      repoCut= 95;
      repoRmMask= this.filterRepos(repoCut);
      this.dataset.selectedRepos(repoRmMask)= 0;
      % Deselect all acceptanceClassifier columns at first
      this.dataset.selector.accC(:)= 0;
      % Remove violations
      this.dataset.selector.scorerC(61:end)= 0;
      % Remove low quality data based on fixed rules
      data= this.dataset.getScorer();
      this.filterDataset(this.lowQualityMask(data));
      % Select ACC metrics based on PCA
      this.dataset.selector.accC(this.acceptanceClassifier.acceptanceMetrics)= 1;
      % Eliminate correlations
      this.dataset.selector.scorerC(this.scorer.correlatedMetricsToRemove)= 0;
    end
    
    function mask= lowQualityMask(this, d)
      f1= d.TNOS > 4;         % Remove too small classes (>40% of dataset!!!)
      f2= d.CBO > 0;          % Remove classes that aren't used by anyone else (not reusable) (15%)
      f3= (d.NLPM > 0) | (d.NLPA > 0);  % Remove classes without any public methods or attributes (11%)
      mask= f1&f2&f3;
    end
    function rmMask= filterRepos(this,repoCut)
      repos= this.reader.repositories;
      accS= repos.Stars < prctile(repos.Stars,repoCut);
      accF= repos.Forks < prctile(repos.Forks,repoCut);
      splusf= repos.Stars + repos.Forks;
      accSplusF= splusf < prctile(splusf,repoCut);
      rmMask= ~(accS & accF & accSplusF);   % Accepted by Stars, Forks and (Stars+Forks)
    end
    
    function filterDataset(this, mask)
    % Apply filters to data. Only deselects.
      currentlySelected= this.dataset.selector.R==1;
      this.dataset.selector.R(currentlySelected)= ...
        this.dataset.selector.R(currentlySelected) & mask;
    end

    a= trainSingle(this); %%  ###***   O.B.S.O.L.E.T.E   ***### (use trainAll instead)
    a= trainAll(this);
  end
end
