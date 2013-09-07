function coeff = olsbeta(y,x);

%Calculates OLS coefficients for an unrestricted VAR(p)
%y must have different variables as columns

[n k]=size(y);
phi=zeros(k,1); res=zeros(n,1);
coeff=((inv(x'*x))*(x'*y))';

