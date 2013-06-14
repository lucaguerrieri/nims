function [optparams, exitflag, fval, ...
          fitted, smoothedhistory, ...
          errhistory b0]=estimfun(paramlabels,params,upperbound,lowerbound,...
                                  observedlabels,fittedlabels,modnam,parnam1,parnam2,ntrain)
      
global zdata slist errlist slistfull errlistfull


eval(parnam1); 
eval(parnam2);

 

%filename = 'U:\TQS\luca\SECOND_DERIVATIVE\oilmod\NODLL\zdatanew_010510.txt';
%exportmat(zdata',filename);
%save estimdata zdata

listdrop = makelistdrop(strvcat(slist,errlist),strvcat(slistfull,errlistfull));

%[likel,q,history,amatsmall,bmatsmall,endogsmall smoothedhistory] = updatemod(params,paramlabels,modnam,parnam1,parnam2,observedlabels,upperbound,lowerbound,listdrop);

display('Starting optimization')

%options = optimset('HessUpdate','bfgs','display','iter','MaxIter',1e10,'MaxFunEvals',1e10,'TolFun',10e-3,'TolX',1e-4);

%code for tomlab optimizer
%options = optimset;
%Prob=ProbDef;
%Prob.Solver.Tomlab='snopt'
% options = optimset('HessUpdate','bfgs','display','iter','MaxIter',5e2,'MaxFunEvals',1e10,'TolFun',10e-3,'TolX',1e-4);


options = optimset('HessUpdate','bfgs','display','iter','MaxIter',1000,'MaxFunEvals',1e10,'TolFun',10e-3,'TolX',1e-4);



% fminunc
%
%[likel,optparams,firstd,secondd] = csminwel('updatemod',params,0.01*eye(max(size(params))),[],10e-4,10000,paramlabels,modnam,parnam1,parnam2,observedlabels,upperbound,lowerbound,listdrop)


optparams = params;
%annealing
for j = 1:10
% loss = @(x0)updatemod(x0,paramlabels,modnam,parnam1,parnam2,observedlabels,upperbound,lowerbound,listdrop,ntrain);
% option = anneal();
% option.Verbosity = 2;
% [optparams, fval] = anneal(loss,params);
% exitflag = 0;


%fminsearch
for i = 1:3
%display(['iteration ',num2str(i)])
params = optparams;
results = strcat(deblank(paramlabels),' = ',deblank(num2str(params,14)),';')
[optparams,fval,exitflag] = ...
   fminsearch('updatemod',params,options,paramlabels,modnam,parnam1,parnam2,observedlabels,upperbound,lowerbound,listdrop,ntrain);

end

params = optparams;

end

[optparams,fval,exitflag,outparms] = ...
    fminunc('updatemod',params,options,paramlabels,modnam,parnam1,parnam2,observedlabels,upperbound,lowerbound,listdrop,ntrain);

% to test
%likel1 = loss(params);
%likel2 = updatemod(params,paramlabels,modnam,parnam1,parnam2,observedlabels,upperbound,lowerbound,listdrop);


%% get fitted values
[likel,q,amatsmall,bmatsmall,endogsmall,fitted, smoothedhistory, errhistory, b0] = updatemod_full(optparams,paramlabels,modnam,parnam1,parnam2,observedlabels,upperbound,lowerbound,listdrop,ntrain);

nobs = size(zdata,1);

nvars = size(fittedlabels,1);
for i=1:nvars
     selectfitted(i) = strmatch(fittedlabels(i,:),endogsmall,'exact');
end
 
fitted = fitted(selectfitted,:)';

%xiinit = smoothedhistory(:,1);
%[newzdata]=mkdata_asmallbsmall(amatsmall,bmatsmall,endogsmall,errlistfull,'c1oilrelpobs',errlist,errhistory,xiinit)
%stddev = transpose((diag(inv(sigmaTilde))).^.5);
%plot(smoothedhistory(:,6),'r')
%hold on
%plot(newzdata,'k.')

%display('done')
