function p=mbic(y, x, maxp)
%AR lag length selection by BIC
%INPUT: y is regressand nx1 series
%       ly is lagged values already
%       included in the regression nxk series
%       x is univariate nx1 series
%       maxp is the max n. of lags

n = size(x,1); 
l = size(x,2);
T = n-maxp+1;
Y = y(maxp:n,1);
z = [];

for i = 1:maxp
    z = [z x(maxp-i+1:n-i+1,:)];
end

i=1;
while i<maxp
    [b bint v] = regress(Y,z(:,1:i+l));
    crit=log(v'*v/T)+(i+l)*log(T)/T; 
    if     i<=1; p=i; mincrit=crit; 
    elseif crit<mincrit; p=i; mincrit=crit; 
    end 
    i=i+1;
end; 