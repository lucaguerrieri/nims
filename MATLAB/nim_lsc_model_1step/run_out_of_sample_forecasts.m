
[yobs, dates, yields, nims, nfactors, nothers, tau, factors] = load_data_ml; 

load this_iter; 

forecast_horizon = 10;
nobs_history = 90;

[forecast] = out_of_sample_forecasts(param_vec, yobs, xi10_demeaned, p10, ntrain, tau, nfactors, nothers, forecast_horizon);

figure
plot(dates(end-nobs_history:end), yobs(end,end-nobs_history:end), 'k-');
hold on
plot(dates(end)+.25:.25:dates(end)+forecast_horizon/4, forecast(end,:), 'k--');


%% Now redo for VAR

var_data= [factors' nims'];

varlag = 4;

[coefb,const,coverr] = runvar_general(var_data,varlag);

f_var=companion(coefb,const);

[forecast_var] = var_out_of_sample_forecasts(f_var, var_data, varlag, nfactors, nothers, forecast_horizon);

plot(dates(end)+.25:.25:dates(end)+forecast_horizon/4, forecast_var(nfactors+1,:), 'r--');

vline(dates(end),'b');