
clear;

setpath;
nreps_minimizer = 0;           % set to 0 to avoid re-optimizing

load_paramvec_from_disk = 1;  % set to 1 to load saved param_vec from disk
                             % set to 0 to use first guess as defined below

[yobs, dates, yields, nims, nfactors, nothers, tau, factors] = load_data_ml; 

nstates = nfactors + nothers;
ntaus = length(tau);

ntrain = 15; %We have 153 observations per time t; we're setting ntrain to ~15% of observation pool.

factor_means = mean(factors,2);
%nims_mean = mean(nims);

[f_factors] = runvar(factors');

% If OLS is preferred, uncomment the following section of code.
%factors_demeaned = factors-kron(ones(1,size(factors,2)),factor_means);
% CHANGE THIS 
%xi10_demeaned = xi_demeaned(:,1); % Initial guess of unobserved states
%var_data = factors_demeaned';

%nvars = size(var_data,2);
%varlag = 1;
%varlagmat = varlag*ones(nvars);
%[coefs,coverr,errmat]=estimate(varlagmat,zeros(nvars),ones(nvars,1),var_data(1:end-14,:));
%isconstant = 1;
%iscontemp = 0;
%[f_factors,const]=ols2ar(coefs(1:end,:),isconstant,iscontemp);

%[f_nims] = transpose(ols1lag(nims, factors));

f = [f_factors zeros(nfactors,nothers)]; %Before also had f_nims

[f_junk,coverr] = runvar(factors'); %Before also had nims'

q = coverr;
p10 = coverr;

%f = diag(0.5*ones(nstates,1));
%q = diag(1*ones(nstates,1));
r = diag(0.1*ones(ntaus+nothers,1));

q_n = length(diag(q));
r_n = length(diag(r));

q_diag_vec = [];
for this_n=1:q_n
    q_diag_vec = [q_diag_vec 
                  diag(q,q_n-this_n)];
end

r_diag_vec = [];
for this_n=1:r_n
    r_diag_vec = [r_diag_vec 
                  diag(r,r_n-this_n)];
end

lambda = .18;

xi = factors; %Before also had nims
xi_means = mean(xi,2);
xi10_demeaned = xi(:,1)-xi_means;

param_vec = [ reshape(f_factors,size(f_factors,1)*size(f_factors,2),1)
      %reshape(f_nims,size(f_nims,1)*size(f_nims,2),1)
      q_diag_vec
      r_diag_vec
      xi_means %const
      lambda
      ];      

  
if load_paramvec_from_disk == 1
    load this_iter
end

[f_opt, q_opt, r_opt, x_opt, a_opt, lambda_opt, h_opt, xi_means_opt, error] = kalmanFilterSetup(param_vec,tau,nfactors,nothers);

plot_yield(param_vec,tau,nfactors,nothers,yobs,ntrain,xi10_demeaned,q,dates,factors(1,:),factors(2,:),factors(3,:))

% for debugging
[logLikel1] = mylikelihood(param_vec,yobs,xi10_demeaned,tau,nfactors,nothers,ntrain,p10);

options = optimset('HessUpdate','bfgs','display','iter','MaxIter',10000,'MaxFunEvals',1e10,'TolFun',10e-3,'TolX',1e-4);


for fminsearch_rep = 1:nreps_minimizer
 if mod(fminsearch_rep,200) == 0
    plot_yield(param_vec,tau,nfactors,nothers,yobs,ntrain,xi10_demeaned,q,dates,factors(1,:),factors(2,:),factors(3,:))
 pause(5)
 end
 
% loss = @(x0)mylikelihood(x0,yobs,xi10_demeaned,tau,nfactors,nothers,ntrain,p10);
% option = anneal();
% option.Verbosity = 2;
% [opt_param_vec, fval] = anneal(loss,param_vec);

%param_vec = opt_param_vec;
%save this_iter param_vec xi10_demeaned p10 ntrain
% if mod(fminsearch_rep,1) == 0
%      plot_yield(param_vec,tau,nstates,yields,ntrain,xi10_demeaned,q,dates,factor1,factor2,factor3)
%      pause(5)
% end


[opt_param_vec,fval,exitflag] = ...
fminsearch('mylikelihood',param_vec,options,yobs,xi10_demeaned,tau,nfactors,nothers,ntrain,p10);
 
param_vec = opt_param_vec;
save this_iter param_vec xi10_demeaned p10 ntrain
 
% if mod(fminsearch_rep,1) == 0
%      plot_yield(param_vec,tau,nstates,yields,ntrain,xi10_demeaned,q,dates,factor1,factor2,factor3)
%   pause(5)
% end
 
 
% [opt_param_vec,fval,exitflag] = ...
%   fminunc('mylikelihood',param_vec,options,yobs,xi10_demeaned,tau,nfactors,nothers,ntrain,p10);
 
% param_vec = opt_param_vec;
% save this_iter param_vec xi10_demeaned p10 ntrain

end

[f_opt, q_opt, r_opt, x_opt, a_opt, lambda_opt, h_opt, xi_means, error] = kalmanFilterSetup(param_vec,tau,nfactors,nothers);

[logLikel1] = mylikelihood(param_vec,yobs,xi10_demeaned,tau,nfactors,nothers,ntrain,p10);


