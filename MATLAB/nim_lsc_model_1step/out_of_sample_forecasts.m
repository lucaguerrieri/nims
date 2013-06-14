function [forecasts] = out_of_sample_forecasts(param_vec, yobs, xi10, p10, ntrain, tau, nfactors, nothers, forecast_horizon)

%%%Maximum-Likelihood out of sample forecasts%%%

[f, q, r, x, a, lambda, h, xi_means, error] = kalmanFilterSetup(param_vec,tau,nfactors,nothers);

[logLikel,errcode,xi1tHistory,xi10History,xi11History]= ...
    kalmanFilterSmoother_v2(f, h, yobs, a, x, xi10, p10, q, r, ntrain);

nstates = nfactors+nothers;

xi = zeros(nstates,forecast_horizon+1);

xi(:,1) = xi11History(:,end);

for i_index = 1:forecast_horizon
    xi(:,i_index+1) = f*xi(:,i_index);
end
xi = xi(:,2:end);

forecasts = h'*(xi + kron(ones(1,forecast_horizon),xi_means));

