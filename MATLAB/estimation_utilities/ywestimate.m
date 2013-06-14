function [A,a0,coverr,err] = ywestimate(y,nlags)
% Input arguments:
% consider the multivariate process
% y = ones(T,N) a0' + y(-1) a1' +  ... + y(-p) an' + err
%
% The matrix y is T by N,
% where T is the number of observations and N is the number of processes.
% If y is N by T it is rearranged within the subroutine.
% 
% nlags is the order p of the autoregressive process to fit.
%
% Output arguments
% A stores [a1, a2, ... , an] horizontally.
% a0 contains the intercept term.
% coverr is the variance covariance matrix for the residuals
% err is the T by N matrix of residuals
%
%
% For references check Lutkepohl "Introduction to Multiple Time Series
% Analysis", page 78.
% depart from Lutkepohl, by dividing covariance

% get some sizes
nvars = min(size(y));
nobs = max(size(y));

% make sure that observations are stacked vertically
if (size(y,1)<size(y,2))
    y = y';
end

% demean data
mean_y = mean(y);
y0m = y - ones(size(y,1),size(y,2))*diag(mean_y);

% initialize gamma matrix
gammamat = zeros(nvars*nlags);

% create gamma matrix 
% follow Lutkepohl "Introduction to Multiple Time Series Analysis", page 78
% define gammamat as [ g(0)    ...    g(p-1) 
%                       .      .        .
%                       .       .       .
%                       .        .      .
%                      g(-p+1)         g(0) ]
% 
% 
% where g(i) is the ith autocovariance matrix, taking into account as many
% observations from the presample as are available
% NB if the presample were ignored, the procedure would produce the OLS
% estimates.

% Since matrix gammamat is symmetric, only build the upper triangle.
% In the loop below, the first iteration puts down g(0) on the diagonal,
% and so on, moving towards the upper-right corner.
for i = 0:nlags-1
    g = y0m(i+1:nobs,:)'*y0m(1:nobs-i,:)/nobs;  
    for p = 0:nlags-1-i
        gammamat(p*nvars+1:(p+1)*nvars,(i+p)*nvars+1:(i+p+1)*nvars) = g;
    end
end

% now copy upper half of gammamat onto its lower half
gammamat = triu(gammamat);
d = diag(diag(gammamat));
gammamat = gammamat'+gammamat-d;

% initialize gamma vector
% gamma vector is defined as [g(1), ..., g(p)] where g(i) is the ith
% autocovariance
gammavec = zeros(nvars,nvars*nlags);

for i = 1:nlags
    gammavec(:,(i-1)*nvars+1:i*nvars) = y0m(i+1:nobs,:)'*y0m(1:nobs-i,:)/nobs;
end

% build estimates
A = gammavec * gammamat^(-1);

% estimate intercept
sum_lhs = eye(nvars);
for i = 1:nlags
    sum_lhs = sum_lhs - A(:,nvars*(i-1)+1:i*nvars);
end
a0 = sum_lhs * mean_y';

% estimate varcov of residuals
% generate residuals:
[cofb,cofc] = yw2ar(A,a0);

err=y(nlags+1:end,:)-ones(nobs-nlags,nvars)*diag(cofc);
for i=1:nlags
    err = err - y(nlags-i+1:nobs-i,:)*cofb(:,:,i)';
end

coverr = err'*err/(nobs-nlags-1);
