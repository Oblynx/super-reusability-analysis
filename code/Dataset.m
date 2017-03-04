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
        %c= cellfun(@(x) this.fulldata{i,1}, cell(size(this.fulldata{i,2},1),1));
        %this.fulldata{i,2}.RepoName= c;
      end
      %this.repoNames= this.fulldata(:,1);
      %this.fulldata= vertcat(this.fulldata{:,2});     % Implode all tables into one
      
      this.selectedRepos= logical(ones(this.repoNum,1));
      this.initSelectors();
      this.cache.valid= false;
      this.targetset= cell(this.repoNum,1);
    end
    
    function setTarget(this,targetFunc,metricsToRemove)
      this.targetset(this.selectedRepos)= cellfun(targetFunc, ...
        this.fulldata(this.selectedRepos,2), ...
        this.fulldata(this.selectedRepos,1), 'UniformOutput',false);
      this.selector.scorerC(metricsToRemove)= 0;
    end
    
    function [data,target]= getScorer(this)
      if ~this.cache.valid
        this.cache.data= vertcat(this.fulldata{this.selectedRepos,2});
        this.cache.target= vertcat(this.targetset{this.selectedRepos});
        this.cache.valid= true;
      end
      data= this.cache.data(this.selector.scorerR, this.selector.scorerC);
      target= this.cache.target(this.selector.scorerR,:);
    end
    function data= getAcc(this)
      if ~this.cache.valid
        this.cache.data= vertcat(this.fulldata{this.selectedRepos,2});
        this.cache.valid= true;
      end
      data= this.cache.data(this.selector.accR, this.selector.accC);
    end
    %
    function set.selectedRepos(this,nval)
      this.selectedRepos= nval;
      this.initSelectors();
      this.cache.valid= false;
    end
    %
    
    function initSelectors(this)
      fullsize= 0;
      repos= 1:this.repoNum;
      repos= repos(this.selectedRepos);
      for i= 1:length(repos)
        fullsize= fullsize+ size(this.fulldata{repos(i),2},1);
      end
      this.selector.scorerR= logical(ones(fullsize,1));
      this.selector.scorerC= logical(ones(size(this.fulldata{1,2},2),1));
      this.selector.accR= this.selector.scorerR;
      this.selector.accC= this.selector.scorerC;
    end
  end
end
