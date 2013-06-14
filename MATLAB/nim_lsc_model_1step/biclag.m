function [optbiclag criterion] = biclag(vardata,startlag,endlag) 
%%% Searches for the lag length that minimizes the BIC criterion

% Estimate the VAR with a varying laglength
% as determined by lagindx.
% Then determine which laglength minimizes the BIC criterion

criterion = zeros(endlag-endlag+1,1);
if (startlag<1)
    error('second argument to biclag must be a integer greater than zero');
end

for lagindx = startlag:endlag
    
    y = vardata;
    startdt = 1;
    enddt = size(y,1);
    
    varlags = lagindx*ones(size(y,2));
    
    neqs = size(varlags,1);
    contemp = zeros(neqs);          % no contemporaneous variables present
    
    %%%%%% Check structure of the VAR
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
    
    %%%%% Estimate the VAR
    
    % coefs will store the regression coefficients
    % each equation is on a different column
    % if there is a constant, the first entry is the intercept term
    % then variables entering contemporaneously,
    % then the firt lags, and so on.
    
    [coefs,coverr]=estimate(varlags,contemp,constant,y);
    nobs = max(size(y))-lagindx;
    neqs = min(size(y));
    piconst = 3.14159265358979;
    kparams = neqs*(lagindx+1);
    lik = -nobs*neqs/2*(1+log(2*piconst))- nobs/2*log(det(coverr));
    criterion(lagindx) = -2*lik/nobs + kparams * log(nobs)/nobs;
   
end
minpos = find(criterion==min(criterion));
optbiclag = startlag + minpos -1;












