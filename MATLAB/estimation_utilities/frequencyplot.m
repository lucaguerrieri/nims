function var_decomp=frequencyplot(omega0,omega1,maxiter,amat,gamma0,gamma0_partial)

spectraldecomp = intspectrum(omega0,omega1,amat,maxiter);
gamma0_bp=spectraldecomp*gamma0;


nerrs = size(gamma0_partial,3);
var_decomp=zeros(size(amat,1),nerrs);
for i=1:nerrs
    %display(['Computing Variance Decomposition for ',newerrlist(i,:)])
    gamma0_partial_bp=spectraldecomp*gamma0_partial(:,:,i);
    var_decomp(:,i)=diag(gamma0_partial_bp)./diag(gamma0_bp);
end