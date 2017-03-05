function idx= findStrCell(cell,str)
if iscell(str)
  idx= zeros(length(str),1);
  for s= 1:length(str)
    for i=1:length(cell)
      if(strcmp(cell{i},str{s})), idx(s)= i; break; end
    end
  end
else
  for i=1:length(cell)
    if(strcmp(cell{i},str)), idx= i; break; end
  end
end
end
