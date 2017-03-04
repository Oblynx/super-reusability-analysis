classdef DataReader
properties (SetAccess= private)
  repositories;
  savedCsvdataPath= 'data/cachedCsvdata';
end

methods
  
  function reader= DataReader()
    reader.repositories= readtable('data/repositories_info.csv');
    reader.repositories.Properties.RowNames= reader.repositories{:,'Project_Name'};
    reader.repositories= reader.repositories(:,[1,3:7]);
  end
  
  function data= loadAll(this, type, reload)
    if (reload && ~isempty(dir([this.savedCsvdataPath,type,'.mat'])))  % If stored data exist
      load([this.savedCsvdataPath,type,'.mat']);
    else
      data= cell(size(this.repositories,1),2);
      for i= 1:size(this.repositories,1)
        data{i,1}= this.repositories.Properties.RowNames(i);
        data{i,2}= DataReader.load(this.repositories.Properties.RowNames(i), type);
      end
      save([this.savedCsvdataPath,type,'.mat'], 'data');
    end
    data= Dataset(data);
  end
end

methods (Static) 
  
  function data= load(name,type)
    if iscell(name)
      name= name{1};
    end
    assert(strcmp(type,'Method') || strcmp(type,'Class') || strcmp(type,'Package'), ...
           '[DataReader::load]: Invalid data type: "Method", "Class" or "Package" expected');
         
    try
      data= readtable(['data/',type,'/',name,'-',type,'.csv']);
    catch     % Some csv have values with commas, which need different handling
        fprintf('[DataReader::load]: %s loaded specially\n', name);
      f= fopen(['data/',type,'/',name,'-',type,'.csv']);
      
      format= [ones(6,1)*'%q';ones(99-6,1)*'%f']; format= char(reshape(format',1,[]));
      
      a= textscan(f,format,'Delimiter',',', 'Headerlines',1);
      %a= reshape(a,99,[]); a= a';
      frewind(f);
      b= textscan(f,'%q','Delimiter',','); b= b{1}(1:99);
      tableheader= cellfun(@(str) regexprep(str,'\s+(\w)','${upper($1)}'),b, 'UniformOutput',0);
      c= cell(352,99);
      for i= 1:6; c(:,i)= a{i}; end;
      for i= 7:99; c(:,i)= mat2cell(a{i}, ones(352,1),1); end;
      data= cell2table(c,'VariableNames',tableheader);
      fclose(f);
    end
    data.Path= zeros(size(data,1),1);
  end
end
end
