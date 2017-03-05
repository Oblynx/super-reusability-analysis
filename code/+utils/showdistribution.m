function showdistribution(data, reject_percentile)

discreteness= length(data)/length(unique(data));
if discreteness > 30
  data= data(data <= prctile(data,reject_percentile));
  x= tabulate(data); bar(x(:,1),x(:,2));
else
  histogram(data);
end
