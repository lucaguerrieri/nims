function beta = estimate_ols(yreg,xreg)

beta = mldivide((xreg*xreg'),xreg'*yreg);
