function [amat, bmat]=ar2companion(cofb,a0inv)

nlags = size(cofb,3);
nvars = size(cofb,2);
amat = zeros(nlags*nvars);

for i=1:nlags
    % deal with first row
    amat(1:nvars,(i-1)*nvars+1:i*nvars)=cofb(:,:,i);
end

amat(nvars+1:end,1:(nvars*(nlags-1)))=eye(nvars*(nlags-1));
bmat = [a0inv;zeros(nvars*(nlags-1),nvars)];

