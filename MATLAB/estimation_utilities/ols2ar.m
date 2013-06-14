function [cofb,const]=ols2ar(coefs,isconstant,iscontemp) 

% Rewrite VAR as Y_t=const+cofb(:,:,1) Y_{t-1} + cofb(:,:,2) Y_{t-2}+...
% coefs comes from OLS estimation of the VAR


nendog=size(coefs,2);

maxlag=(size(coefs,1)-isconstant)/nendog;
if iscontemp==1
   maxlag=maxlag-1;
end

cofb=zeros(nendog,nendog,maxlag);

cofa=iscontemp*coefs(1+isconstant:nendog+isconstant,:)';
cofainv=(eye(nendog)-cofa)^(-1);


for indxi=1:maxlag
    startindx = isconstant+iscontemp*nendog+nendog*(indxi-1)+1;
    endindx = isconstant+iscontemp*nendog+nendog*(indxi);
    
    cofb(:,:,indxi)=coefs(startindx:endindx,:)';
    if iscontemp == 1
       cofb(:,:,indxi) = cofainv*cofb(:,:,indxi);
    end
end

const = coefs(1,:)';
return
