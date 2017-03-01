classdef System
  % The system is a network of connected models that infers
  properties %(Access= private)
    reader;
    acceptanceClassifier;
    scorer;
  end
  
  methods
    function this= System()
      this.reader= DataReader;
      this.acceptanceClassifier= model.AcceptanceClassifier;
      this.scorer= model.Scorer;
    end
    
    a= trainSingle(this)
    a= trainAll(this)
    s= pcaSelector(this,k)
  end
  
  methods (Static)
  % Data preprocessing functions
    function nocorrCols= onlyNocorrCols()
    % Correlation analysis has found many correlated columns and some have been
    % eliminated to simplify the dataset. These are in the "toremove" vector
      toremove= [5,6,7,8,20,21,19,37,27,29,31,32,42,46,47,33,43,48,35,38,50,40,41,44,52,56];
      nocorrCols= (11:70)-10;
      for i=1:length(toremove)
        j= find(nocorrCols==toremove(i));
        nocorrCols= [nocorrCols(1:j-1),nocorrCols(j+1:end)];
      end
    end
  % Remove low-PCA metrics
    function highPCA= onlyHighPCACols()
      
      [~,pcProjection,~,~,var_attr]= pca(dset);
      var_attr(1:22)
      r_pca= corr(dset, pcProjection(:,1:5));
      pred_score= sum(abs(r_pca),2);
      [~,best_pred]= sort(pred_score,'descend');
    end
  end
end
