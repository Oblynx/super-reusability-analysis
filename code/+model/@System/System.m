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
end
