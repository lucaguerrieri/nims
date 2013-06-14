function [coefs] = ols1lag(nims, factors)

yreg = transpose(nims(:,2:end));
xreg = [transpose(factors(:,1:end-1)) transpose(nims(:,1:end-1))]; 

coefs = (xreg'*xreg)\xreg'*yreg;