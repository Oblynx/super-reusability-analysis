classdef DataReader
properties (SetAccess= private)
  repositories;
  %mstore; cstore; pstore;
end

methods
  
function reader= DataReader()
  reader.repositories= readtable('data/repositories_info.csv');
  reader.repositories.Properties.RowNames= reader.repositories{:,'Project_Name'};
  reader.repositories= reader.repositories(:,[1,3:7]);
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
  % Convert number cols from string to double
  numericColumns= [];
  for i= 1:size(data,2)
    if ~isnan(str2double(data{1,i}))
      numericColumns= [numericColumns,i];
    end
  end
  x= cellfun(@(s) sscanf(s,'%f',1), data{:,numericColumns});  % Slow
  % MEX ref:
  % https://www.mathworks.com/matlabcentral/answers/84135-getting-the-contents-from-cells-in-a-cell-array-using-mex
  % http://www.mathworks.com/help/matlab/cc-mx-matrix-library.html
  % http://www.mathworks.com/help/matlab/apiref/mxgetcell.html?searchHighlight=mxGetCell&s_tid=doc_srchtitle
  % http://www.mathworks.com/help/matlab/matlab_external/matlab-data.html
  % http://www.mathworks.com/help/matlab/mex-library.html
  data{:,numericColumns}= num2cell(x);
end
end
end
