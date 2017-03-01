function s= pcaSelector(this, dataset,k)
% Selects the k-most significant elements of the dataset
% dataset [matrix]

[pc,~,~,~,var_attr]= pca(dataset);
