function [bhat resids]= runreg(y,endogpp,q,pp)
% runs OLS for y on a constant, endogpp lags of y, and the current value of
% q, plus pp lags of q.

t=length(q);

maxpp = max(endogpp, pp);
Z=ones(1,t-maxpp);

for i=1:endogpp
    Z=[Z; y(maxpp+1-i:t-i,1)'];
end

% start from zero to identify contemporaneous response
for i=0:pp
    Z=[Z; q(maxpp+1-i:t-i,1)'];
end
Z=Z';

% y is dependent variable
yorig = y;
y=y(maxpp+1:t,1);

% OLS
bhat=inv(Z'*Z)*Z'*y;

if nargout>1
    resids = y-Z*bhat;
end