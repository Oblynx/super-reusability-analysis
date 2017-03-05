function r_data= metricCorr(table,threshold,toremove)

idx= utils.allbut(size(table,2),toremove);
r_data= corr( table{:,idx} );
lidx= 1:size(table,2); lidx= lidx(idx);
surf(lidx,lidx, r_data.*(r_data>threshold) );
colorbar; title('Metrics correlations after elimination');
view([0,90]);
