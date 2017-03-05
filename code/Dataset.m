classdef Dataset < handle
  properties (SetAccess= immutable)
    repoStarts;
    repoNum;
  end
  properties
    fulldata;
    selector;   %struct [logical]
    selectedRepos;
    cache;      %struct [score,acc,data,valid]
    targetset;
  end
  
  methods
    function this= Dataset(data)
      this.fulldata= data;
      this.repoNum= size(this.fulldata,1);
      repoLengths= cellfun(@(x) size(x,1), this.fulldata(:,2));
      this.repoStarts= cumsum([1;repoLengths]);
      for i=1:this.repoNum
        this.fulldata{i,2}= this.fulldata{i,2}(:,11:end);
      end
      this.selectedRepos= logical(ones(this.repoNum,1));
      this.initSelectors();
      this.cache.valid= false;
      this.targetset= cell(this.repoNum,1);
      for i=1:this.repoNum, this.targetset{i}= zeros(size(this.fulldata{i,2},1),1); end
    end
    
    function setTarget(this,targetFunc,metricsToRemove)
    % Calculate targetset and remove related metrics from the dataset
      this.targetset(this.selectedRepos)= cellfun(targetFunc, ...
        this.fulldata(this.selectedRepos,2), ...
        this.fulldata(this.selectedRepos,1), 'UniformOutput',false);
      this.updateCache();
      this.selector.scorerC(metricsToRemove)= 0;
    end
    
    function [data,target]= getScorer(this, addViolations)
      selectedCols= this.selector.scorerC;
      if nargin>1 && addViolations, selectedCols(61:end)= 1; end    % Add violations to results
      if ~this.cache.valid, this.updateCache(); end
      data= this.cache.data(this.selector.R, selectedCols);
      target= this.cache.target(this.selector.R,:);
    end
    function data= getAcc(this)
      if ~this.cache.valid, this.updateCache(); end
      data= this.cache.data(this.selector.R, this.selector.accC);
    end
    %
    function set.selectedRepos(this,nval)
      this.selectedRepos= nval;
      this.initSelectors();
      this.cache.valid= false;
    end
    %
  end
  
  methods (Access= private)
    function initSelectors(this)
      fullsize= 0;
      repos= 1:this.repoNum;
      repos= repos(this.selectedRepos);
      for i= 1:length(repos)
        fullsize= fullsize+ size(this.fulldata{repos(i),2},1);
      end
      this.selector.R= logical(ones(fullsize,1));
      this.selector.scorerC= logical(ones(size(this.fulldata{1,2},2),1));
      this.selector.accC= this.selector.scorerC;
    end
    function updateCache(this)
      this.cache.data= vertcat(this.fulldata{this.selectedRepos,2});
      this.cache.target= vertcat(this.targetset{this.selectedRepos});
      this.cache.valid= true;
    end
      
  end
end
