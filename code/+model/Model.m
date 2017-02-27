classdef Model
  methods (Abstract)
    y= infer(x);
    evalResults= train(this, dataset, targetset);
  end
  methods (Access= protected)
    function score= evaluate(this, testSet)
      ???
    end
  end
end
