function [rmse_mlmat, forecast_mat] = calc_rmse_ml_conditional(opt_param_mat, out_of_sample_start_pos, end_sample_pos, yobs, xi10, p10, ntrain, tau, nfactors, nothers, forecast_horizon, dates,plotbool)

%%%Maximum-Likelihood pseudo-out of sample forecasts%%%
nstates = nfactors+nothers;
num_periods = end_sample_pos - out_of_sample_start_pos +1;
forecast_errors_mat = nan*ones(num_periods, forecast_horizon);
forecast_mat = nan*ones(num_periods, forecast_horizon);


ntau = length(tau);


mat_counter = 0;
for pos_index = out_of_sample_start_pos:end_sample_pos
    mat_counter = mat_counter+1;
    param_vec = opt_param_mat(:,pos_index-out_of_sample_start_pos+1);
    
    [f, q, r, x, a, lambda, h, xi_means, error] = kalmanFilterSetup(param_vec,tau,nfactors,nothers);
    
    [logLikel,errcode,xi1tHistory,xi10History,xi11History,p10History]= ...
        kalmanFilterSmoother_v2(f, h, yobs , a, x, xi10, p10, q, r, ntrain);
    
    
    xi10new = xi10History(:,pos_index);
    p10new = p10History(:,:,pos_index);
    if pos_index <= end_sample_pos - forecast_horizon
        [logLikel,errcode,xi1tHistory,xi10History,xi11History]= ...
            kalmanFilterSmoother_v2(f, h(:,1:ntau), yobs(1:ntau,pos_index:pos_index+forecast_horizon-1), a(1:ntau,1:ntau), x(1:ntau,:), xi10new, p10new, q, r(1:ntau,1:ntau), ntrain);
    else
        [logLikel,errcode,xi1tHistory,xi10History,xi11History]= ...
            kalmanFilterSmoother_v2(f, h(:,1:ntau), yobs(1:ntau,pos_index:end_sample_pos), a(1:ntau,1:ntau), x(1:ntau,:), xi10new, p10new, q, r(1:ntau,1:ntau), ntrain);
    end
    
    
    forecast_errors = zeros(1,forecast_horizon);
    
    
    
    if  end_sample_pos - pos_index + 1 >= forecast_horizon
        forecasts = xi11History + kron(ones(1,forecast_horizon),xi_means);
        if plotbool
            figure
            plot(dates(pos_index-20:pos_index-1), yobs(end,pos_index-20:pos_index-1), 'k-','lineWidth',2);
            hold on
            plot(dates(pos_index):.25:dates(pos_index)+(forecast_horizon-1)/4, forecasts(end,:), 'b--','lineWidth',2);
            plot(dates(pos_index):.25:dates(pos_index)+(forecast_horizon-1)/4,yobs(end,pos_index:pos_index+forecast_horizon-1), 'k-');
        end
    
        forecast_errors = yobs(end,pos_index:pos_index+forecast_horizon-1) - forecasts(end,:);
        forecast_errors_mat(mat_counter,:) = forecast_errors;
    else
        forecasts = xi11History + kron(ones(1,size(xi11History,2)),xi_means);
        forecast_errors = yobs(end,pos_index:end_sample_pos) - forecasts(end,1:end_sample_pos-pos_index+1);
        forecast_errors_mat(mat_counter,1:end_sample_pos-pos_index+1) = forecast_errors;
        
        
    end
    forecast_mat(mat_counter,1:length(forecasts(end,:))) = forecasts(end,:);
    title('Conditional Forecast from Dynamic Factor Modforecast_mat(mat_counter,1:length(forecast)=forecasts(end,:);el for NIMs')
end

rmse_mlmat = (nansum((forecast_errors_mat.^2))./(size(forecast_errors_mat,1)-sum(isnan(forecast_errors_mat)))).^0.5;

