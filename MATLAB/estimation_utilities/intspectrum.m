function sint=intspectrum(omega0,omega1,amat,maxiter)

% postmultiply by gamma0 to obtain the variance 

% See DeJong and D
iter=0;

[vamat lambdaamat] = eig(full(amat));

lambdadiag = diag(lambdaamat);

n=size(amat,1);

sint = zeros(n,1); 
for iter = 1:maxiter
    sint = sint+2*(lambdadiag.^iter)*(1/iter*(sin(omega1*iter)-sin(omega0*iter)));     
end


sint = (eye(n)*(omega1-omega0)+vamat*diag(sint)*inv(vamat))/2/pi;
 
