% the q was added to the output by Phillip, 7/13
function [likel q history amatsmall bmatsmall endogsmall smoothedhistory] = updatemod(params,paramlabels,modnam,parnam1,parnam2,observedlabels,upperbound,lowerbound,listdrop,ntrain)
                                                           

% implements penalty function to ensure function evaluation is within
% desired bounds

% declare data matrix as global
global zdata endog_ errlist slist 

aimtol = 1e-4;

% Define parameters and matrices for state and observable transition
% equations.
% 
% The state evolution equation takes the form:
% b_k = T b_{k-1} + q w_k.
% The observable equation takes the form:
% y_k = Z b_{k} + r e_k.
% where w_k and e_k are drawn from a  multinormal distribution with variance sigma^2
% 


% check inputs and modify them if outside boundaries (impose penalty later)
origparams = params;
params = min(max(params,lowerbound),upperbound);

% obtain decision rule
printflag = 0;
parseflag = 0;
[cofb,scof,endog_,xxxx,xxxxx,aimcode,aimerr]=eggmodfunestim(modnam,parnam1,parnam2,parseflag,params,paramlabels);

if (aimerr<aimtol & aimcode==1) 
[amat,bmat,endogs]=splitmat(cofb,scof,endog_,errlist,listdrop);
[amatsmall, bmatsmall, endogsmall]=shrinkspacesmall(amat,bmat,endogs,strvcat(observedlabels,slist));


penalty =0;
nparams = max(size(params));
 
    T = amatsmall;

    q = bmatsmall;
     
    Q= q*q';
    
    
    nobserved = size(observedlabels,1);
    nendogsmall = size(endogsmall,1);
    b0 = zeros(nendogsmall,1);
    Z = zeros(nobserved,nendogsmall);
    for observedindx=1:nobserved
        observedpos(observedindx)=strmatch(observedlabels(observedindx,:),endogsmall,'exact');
        Z(observedindx,observedpos(observedindx))=1;
        b0(observedpos(observedindx)) = zdata(1,observedindx);
    end
        
  
    r = zeros(nobserved,1);
    R = r*r';

    % Find unconditional variance of state vector
    % covb = varsigma(T,Q);
    
    
    
    
    trendpos = strmatch('c1trend',endogsmall,'exact');
    b0(trendpos) = 1;
    
   
    
    
% defines size of training sample
if nargout<3
        [likel errcode]= kalmanFilterMatlab(T,Z',zdata',b0,Q,ntrain);
        history = [];
else
        [likel,errcode,history,smoothedhistory]= kalmanFilterSmoother(T,Z',zdata',b0,Q,bmatsmall,ntrain);
end

likel = likel +10000*sum(abs(params-origparams));
else
likel = 1000000000; 
end

