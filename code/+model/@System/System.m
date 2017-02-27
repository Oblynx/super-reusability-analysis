classdef System
  % The system is a network of connected models that infers
  properties
    reader;
    acceptanceModel;
    scorer;
  end
  
  methods
    
    function this= System()
      this.reader= DataReader;
      this.acceptanceModel= AcceptanceModel;
      this.scorer= Scorer;
    end
    
    train(this)
  end
end
