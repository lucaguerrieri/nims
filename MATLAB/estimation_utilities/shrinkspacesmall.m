function [amatsmall, bmatsmall, endogsmall]=shrinkspacesmall(amat,bmat,endog,observed)
% This function splits the state space into endogenous and control
% variables (which are discarded)
%
% The function looks for columns in the law of motion whose entries are all zeros
% those will correspond to the positions  of the control variables

nendog = size(endog,1);
tolzero = 10e-10;

countc = 0;
counte = 0;
for i = 1:nendog
     if ( max(abs(amat(:,i)))<tolzero & isempty( strmatch(deblank(endog(i,:)),observed,'exact') ) )
         countc=countc+1;
         controlselect(countc) = i;
     else
         counte = counte +1;
         endogselect(counte) = i;
     end
 end

 
 amatsmall = amat(endogselect,endogselect);
 bmatsmall = bmat(endogselect,:);
 
 
 endogsmall=endog(endogselect,:);

 