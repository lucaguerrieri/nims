function [beta, yreg, xreg] = get_simple_ols(y,x)

% run ols of y on lag of y and lag of x and a constant

yreg = y(2:end);
xreg = [y(1:end) x(1:end-1,:) ones(length(y)-1,1)];
beta = estimate_ols(yreg,xreg);