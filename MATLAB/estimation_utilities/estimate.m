function [coefs,errcov,errmat]=estimate(varlags,contemp,constant,y)

% coefs will store the regression coefficients
% each equation is on a different column
% if there is a constant, the first entry is the intercept term
% then variables entering contemporaneously,
% then the first lags, and so on.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Check structure of the VAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
neqs = size(varlags,1);
nvars = size(varlags,2);

constant = ones(neqs,1);  % if the nth entry of constant is 1 
                         % a constant is included in the nth equation of the VAR
if max(constant)==1
    isconstant=1;
else
    isconstant=0;
end


                      
% check that none of the
% diagonal elements of contemp is 1
% if so, one would be regressing a variable on itself.
contempcheck=diag(contemp);
if max(contempcheck)>=1 
    error('The matrix contemp cannot have ones along its diagonal')
end
                      
% Count number of variables entering contemporaneously in the VAR                                 
countcontemp=contemp'*ones(neqs,1);
ncontemp=0;    
for indxi=1:neqs
    if countcontemp(indxi)>0
       ncontemp=ncontemp+1;
    end
end

% set iscontemp to 1 if there are any variables entering contemporaneously
if ncontemp>0
   iscontemp=1;
else
   iscontemp=0;
end
                
varmaxlag=max(max(varlags));

if (neqs~=nvars) 
    error('nlags needs to be a square matrix')
end 

if (size(y,2)~=neqs)
   error('y needs to have as many columns as varlags')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Estimate the VAR    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% coefs will store the regression coefficients
% each equation is on a different column
% if there is a constant, the first entry is the intercept term
% then variables entering contemporaneously,
% then the first lags, and so on.

coefs = zeros(varmaxlag*neqs+isconstant+iscontemp*neqs,neqs);  
% errmat will hold the matrix of residuals
maxlag = max(max(varlags));
errmat = zeros(size(y,1)-maxlag,size(y,2));




for ieq=1:neqs
    % run regressions equation by equation
    eqlags = varlags(ieq,:);  
    maxlag = max(eqlags);
    xreg=mkregmat(y,eqlags,constant(ieq),contemp(ieq,:));
    yreg=y(1+maxlag:end,ieq);
    regcoef=(xreg'*xreg)^(-1)*xreg'*yreg;
    errmat(:,ieq)=yreg-xreg*regcoef;

    % store regression coefficients in the matrix coefs
    % start with constant
    coefcount=isconstant;
    regcoefcount=constant(ieq);
    if (constant(ieq)==1)
       coefs(1,ieq)=regcoef(1);
    end
    
    % store reg coefs for contemporaneous regressors
    if iscontemp==1    
        for ivar=1:neqs
            coefcount=coefcount+1;
            if contemp(ieq,ivar)==1
                regcoefcount=regcoefcount+1;
                coefs(coefcount,ieq)=regcoef(regcoefcount);
            end
        end
    end

    % store reg coefs for lagged regressors
    for ilag=1:maxlag
        for ivar=1:neqs
            coefcount=coefcount+1;
            if (eqlags(ivar)>=ilag)
               regcoefcount=regcoefcount+1;
               coefs(coefcount,ieq)=regcoef(regcoefcount);
            end
        end
    end
 end
 
 errcov=cov(errmat);


return
