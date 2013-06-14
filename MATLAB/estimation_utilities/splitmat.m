function [amat,bmat,endogs,newerrlist]=splitmat(cofb,scof,endog,errlist,droplist)
% given law of motion of the form
% [x_t]' = cofb [x_{t-1}]' 
% this function produces
% amat and bmat such that
% y_t = amat y_{t-1} + bmat e_t
% 
% the names of the variables in x_t are listed in endog
% the names of the variables in e_t are listed in errlist
% if 'one' is a variable name the column and the row corresponding to the
% variable are excluded from cofb
% if 'one' is not a variable name the program assumes that the model
% conforms to the certainty-equivalent representation


% find position of variables in errlist within endog
nerr = size(errlist,1);
nendog = size(endog,1);
nendogs =  nendog - nerr;

% find positions of variables to drop
rowkeep = [];
keepindx = 0;
for indxi=1:nendog
    if (isempty(strmatch(deblank(endog(indxi,:)),droplist,'exact')))
        keepindx = keepindx+1;
        rowkeep(keepindx)=indxi;
    end
end

endog = endog(rowkeep,:);
cofb = cofb(rowkeep,rowkeep);

nendog = size(endog,1);
nendogs =  nendog - nerr;

% make a list of positions within endog of endogenous variables and
% exogenous innovations
endogposlist = zeros(nendogs,1);
errposlist = zeros(nerr,1);
endogscounter = 0;
errcounter = 0;
for i=1:nendog 
   % case when variable in endog is not in errlist
   if isempty(strmatch(deblank(endog(i,:)),errlist,'exact'))
       endogscounter = endogscounter+1;
       endogposlist(endogscounter) = i;
   % case when variable is in errlist
   else
       errcounter = errcounter+1;
       errposlist(errcounter) = i;
   end
end

% update list of endogenous variables
endogs = endog(endogposlist,:);
newerrlist = endog(errposlist,:);

% eliminate the column and the row of the 'one' variable (if it exists)   
onepos= strmatch('one',endogs,'exact');
if (~isempty(onepos))
    selectvec = [1:onepos-1,onepos+1:length(endogposlist)];
    endogposlist=endogposlist(selectvec);
    endogs = endog(endogposlist,:);
end    

% split transition matrix between endog and error matrix
amat = cofb(endogposlist,endogposlist);
if (isempty(onepos))
    bmat = cofb(endogposlist,errposlist);
else
    bstar=inv(scof(:,nendog+(1:nendog)));
    bmat=bstar(endogposlist,errposlist);
end
