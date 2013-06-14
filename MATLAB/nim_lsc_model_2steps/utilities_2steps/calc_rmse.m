function [rmse_mlmat rmse_varmat rmse_nochangemat] = calc_rmse(opt_param_mat, out_of_sample_start_pos, end_sample_pos, yobs, factors, xi10, p10, ntrain, tau, nfactors, nothers, forecast_horizon)

%%%Maximum-Likelihood pseudo-out of sample forecasts%%%
nstates = nfactors+nothers;
num_periods = end_sample_pos - out_of_sample_start_pos;
errors_mat = zeros(num_periods, forecast_horizon);
rmse_mat = zeros(num_periods, 1);

for pos_index = out_of_sample_start_pos:end_sample_pos
    
    param_vec = opt_param_mat(:,pos_index-out_of_sample_start_pos+1);
    
    [f, q, r, x, a, lambda, h, xi_means, error] = kalmanFilterSetup(param_vec,tau,nfactors,nothers);
    
    [logLikel,errcode,xi1tHistory,xi10History,xi11History]= ...
        kalmanFilterSmoother_v2(f, h, yobs, a, x, xi10, p10, q, r, ntrain);
    
    xi = zeros(nstates,forecast_horizon+1);
    
    xi(:,1) = xi11History(:,pos_index-1);
    
    for i_index = 1:forecast_horizon
        xi(:,i_index+1) = f*xi(:,i_index);
    end
    xi = xi(:,2:end);
    
    forecasts = h'*(xi + kron(ones(1,forecast_horizon),xi_means));
    forecast_errors = zeros(1,forecast_horizon);
    
    if pos_index <= end_sample_pos - forecast_horizon
        forecast_errors = yobs(end,pos_index:pos_index+forecast_horizon-1) - forecasts(end,:);
        errors_mat(pos_index-out_of_sample_start_pos+1,:) = forecast_errors;
    else
        forecast_errors(1:end_sample_pos-pos_index) = yobs(end,pos_index:end_sample_pos-1) - forecasts(end,1:end_sample_pos-pos_index);
        forecast_errors(forecast_horizon - (end_sample_pos - pos_index)+1:end) = NaN;
        errors_mat(pos_index-out_of_sample_start_pos+1,:) = forecast_errors;
    end
    
end

rmse_mlmat = (nansum((errors_mat.^2))./(size(errors_mat,1)-sum(isnan(errors_mat)))).^0.5;


%%
%Now get RMSEs using VAR model
errors_mat = zeros(num_periods, forecast_horizon);

for pos_index = out_of_sample_start_pos:end_sample_pos
[yobs, dates, yields, nims, nfactors, nothers, tau, factors] = load_data_ml;

%nims = nims(:,1:pos_index-1);
factors = factors(:,1:pos_index-1);

var_data= factors'; %Before had nims' as well;

varlag = 4;

[coefb,const,coverr] = runvar_general(var_data,varlag);

f_var=companion(coefb,const);

[forecast_var] = var_out_of_sample_forecasts(f_var, var_data, varlag, nfactors, nothers, forecast_horizon);

    forecast_nim = forecast_var(nfactors+1,:);
    
    forecast_errors = zeros(1,forecast_horizon);
    
    if pos_index <= end_sample_pos - forecast_horizon
        forecast_errors = yobs(end,pos_index:pos_index+forecast_horizon-1) - forecast_nim(end,:);
        errors_mat(pos_index-out_of_sample_start_pos+1,:) = forecast_errors;
    else
        forecast_errors(1:end_sample_pos-pos_index) = yobs(end,pos_index:end_sample_pos-1) - forecast_nim(end,1:end_sample_pos-pos_index);
        forecast_errors(forecast_horizon - (end_sample_pos - pos_index)+1:end) = NaN;
        errors_mat(pos_index-out_of_sample_start_pos+1,:) = forecast_errors;
    end

end

rmse_varmat = (nansum((errors_mat.^2))./(size(errors_mat,1)-sum(isnan(errors_mat)))).^0.5;

%% No Change Forecast Block
errors_mat = zeros(num_periods, forecast_horizon);
[yobs, dates, yields, nims, nfactors, nothers, tau, factors] = load_data_ml;
for pos_index = out_of_sample_start_pos:end_sample_pos


    forecast_nim = nims(pos_index-1)*ones(1,forecast_horizon);
    
    forecast_errors = zeros(1,forecast_horizon);
    
    if pos_index <= end_sample_pos - forecast_horizon
        forecast_errors = yobs(end,pos_index:pos_index+forecast_horizon-1) - forecast_nim(end,:);
        errors_mat(pos_index-out_of_sample_start_pos+1,:) = forecast_errors;
    else
        forecast_errors(1:end_sample_pos-pos_index) = yobs(end,pos_index:end_sample_pos-1) - forecast_nim(end,1:end_sample_pos-pos_index);
        forecast_errors(forecast_horizon - (end_sample_pos - pos_index)+1:end) = NaN;
        errors_mat(pos_index-out_of_sample_start_pos+1,:) = forecast_errors;
    end

end
rmse_nochangemat = (nansum((errors_mat.^2))./(size(errors_mat,1)-sum(isnan(errors_mat)))).^0.5;
