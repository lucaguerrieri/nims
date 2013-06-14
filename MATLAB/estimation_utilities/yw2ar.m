function [cofb,const]=yw2ar(A,a0) 

% Rewrite VAR as Y_t=const+cofb(:,:,1) Y_{t-1} + cofb(:,:,2) Y_{t-2}+...
% A and a0 come from YW estimation of the VAR


nendog=max(size(a0));

maxlag=(size(A,2))/nendog;

cofb=zeros(nendog,nendog,maxlag);

for indxi=1:maxlag
    cofb(:,:,indxi) = A(:,(indxi-1)*nendog+1:indxi*nendog);  
end

const = a0;
return
