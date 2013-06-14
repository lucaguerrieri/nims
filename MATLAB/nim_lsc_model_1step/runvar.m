function [coefb,coverr] = runvar(var_data)

%var_data is in column format
var_data = var_data - kron(ones(size(var_data,1),1),mean(var_data));


nvars = size(var_data,2);
varlag = 1;
varlagmat = varlag*ones(nvars);
[coefs,coverr,errmat]=estimate(varlagmat,zeros(nvars),ones(nvars,1),var_data(1:end-14,:));
isconstant = 1;
iscontemp = 0;
[coefb,const]=ols2ar(coefs(1:end,:),isconstant,iscontemp);