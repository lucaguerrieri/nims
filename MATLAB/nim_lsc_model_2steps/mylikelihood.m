function [logLikel] = mylikelihood(param_vec,yobs,xi10,tau,nfactors,nothers,ntrain,p10)

[f, q, r, x, a, lambda, h, xi_means, error] = kalmanFilterSetup(param_vec,tau,nfactors,nothers);
    
if error == 0    
%Call to Kalman Filter
%[logLikel1,errcode] = kalmanFilterMatlab(f, h, yields, a, x, xi10, p10, q, r, ntrain);

[logLikel,errcode,xi1tHistory,xi10History,xi11History]= ...
    kalmanFilterSmoother_v2(f, h, yobs, a, x, xi10, p10, q, r, ntrain);

%[logLikel,errcode]= kalmanFilterMatlab(f, h, yields, a, x, xi10, p10, q, r, ntrain);

% check that that yield curve does not go too far down at any one point in
% time
[y] = yield_calc(tau, lambda, xi_means(1:end-nothers), xi1tHistory(1:end-nothers,:));
if min(min(y))<0.01
    logLikel = 1e300;
end

else
    logLikel = 1e300;
end