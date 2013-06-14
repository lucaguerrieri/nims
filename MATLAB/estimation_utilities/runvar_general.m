function [coefb,const,coverr] = runvar_general(var_data,varlag)

%var_data is in column format

nvars = size(var_data,2);
varlagmat = varlag*ones(nvars);
[coefs,coverr,errmat]=estimate(varlagmat,zeros(nvars),ones(nvars,1),var_data(1:end-14,:));
isconstant = 1;
iscontemp = 0;
[coefb,const]=ols2ar(coefs(1:end,:),isconstant,iscontemp);