function beta = estimate_ols(yobs,xobs)

yreg = yobs';
xreg = xobs';



beta  = mldivide(xreg'*xreg,xreg'*yreg);

