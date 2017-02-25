classdef DataReader
  properties (SetAccess= private)
    repositories;
    %mstore; cstore; pstore;
  end
  
  methods
    function reader= DataReader()
      reader.repositories= readtable('data/repositories_info.csv');
      %reader.mstore= datastore('data/Method/*.csv');
      %reader.cstore= datastore('data/Class/*.csv');
      %reader.pstore= datastore('data/Package/*.csv');
    end
    function data= loadAll(this, type)
      data= cell(size(this.repositories,1),1);
      for i= 1:size(this.repositories,1)
        data{i}= DataReader.load(this.repositories.Project_Name(i), type);
      end
    end
  end
  methods (Static)    
    function data= load(name,type)
      if iscell(name)
        name= name{1};
      end
      assert(strcmp(type,'Method') || strcmp(type,'Class') || strcmp(type,'Package'));
      
      try
        data= readtable(['data/',type,'/',name,'-',type,'.csv']);
      catch     % Some csv have values with commas, which need different handling
        f= fopen(['data/',type,'/',name,'-',type,'.csv']);
        a= textscan(f,'%q','Delimiter',','); a= a{1};
        a= reshape(a,99,[]); a= a';
        tableheader= cellfun(@(str) regexprep(str,'\s+(\w)','${upper($1)}'),a(1,:), 'UniformOutput',0);
        data= cell2table(a(2:end,:),'VariableNames',tableheader);
        fclose(f);
      end
    end
  end
end
