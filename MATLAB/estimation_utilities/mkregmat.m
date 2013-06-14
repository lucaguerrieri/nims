function xmat=mkregmat(ymat,nlags,isconstant,contemp)

% this function creates a matrix of regressors
% given series for the endogenous variables in a VAR

% the lag structure for the VAR is specified by nlags
% if nlags is a scalar, then the lag structure is the
% same for all endog vars.

nendog=size(ymat,2);

%%%%% Check that isconstant is either 0 or 1
if isconstant~=0 & isconstant~=1
   error('The third argument to mkregmat should be either 0 or 1')
end


%%%%% Check that the dimension of iscontemp matches the number of series in y %%%%%%

if nendog~=max(size(contemp))
   error('the fourth argument to mkregmat should have as many rows as columns in the first argument')
end

%%%%% Check that all the entries in iscontemp are either 0 or 1 %%%%%

%if max(iscontemp)>1 or min(iscontemp)<0
%   error('The fourth argument to mkregmant should be a vector of zeros and ones only')
%end


%%%%% Check that all entries of nlags are +ve 

if min(nlags)<0 
   error('All entries of nlags need to be at least 0')
end


%%%% Create matrix of regressors
maxlag=max(nlags);
T=size(ymat,1);

% deal with constant term
if isconstant==0
   xmat=[];
else
   xmat=ones(T-maxlag,1);
end

% deal with contemporaneous variables
for indxi=1:nendog
    if contemp(indxi)==1
       xmat=[xmat ymat(1+maxlag:T,indxi)];     
    end
end
  
for indxi=1:maxlag
    for indxj=1:nendog
	if nlags(indxj)>=indxi
	   xmat=[xmat ymat(maxlag+1-indxi:T-indxi,indxj)];
	end
    end
end

return;





