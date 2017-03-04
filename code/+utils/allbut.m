function s= allbut(l,toremove)
s= logical(1:l);
s(toremove)= 0;
