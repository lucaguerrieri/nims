function [rmse_mat, forecast_mat] = calc_rmse_multivariate_conditional(yobs, other_obs, out_of_sample_start_pos, end_sample_pos, forecast_horizon, reglag)
%This function computes rmse for a VAR forecast and also returns
%forecast history over a pseudo-out of sample portion of the sample.
%
%Inputs: 
%yobs is a row vector, a series spanning entire available sample.
%other_obs is a matrix, each row is an additional series entering the
%seond step regression and spanning the entire available sample. NB: The rmse is going to be
%conditional on everything in other_var_obs. Needs to have the same number
%of columns as yobs.
%out_of_sample_start_pos is the position of the first pseudo-out of sample
%observation.
%end_sample_pos is the position of the last pseudo-out of sample
%observation.
%varlag is the number of lags used in the VAR.
%
%Outputs:
% rmse_mat is a row vector containing RMSEs for each forecast step.
% var_forecasts is a matrix containing a forecast for each period in the
% pseudo-out of sample. Each row of forecast_mat contains a forecast for
% the horizon desired.

%Now get RMSEs using the VAR model
n_other_obs = size(other_obs, 1);

num_periods = end_sample_pos - out_of_sample_start_pos + 1;
forecast_errors_mat = nan*ones(num_periods, forecast_horizon);
forecast_mat = nan*ones(num_periods, forecast_horizon);

for pos_index = out_of_sample_start_pos:end_sample_pos
    
    
    % strategy keep this part unchanged -- do not lag here. 
    if  end_sample_pos - pos_index + 1  >= forecast_horizon 
        
        % notice that since everything is lagged in the regression, it was
        % convenient to move these back by 1 period.
    
        other_obs_out_of_sample = other_obs(:,pos_index-1:pos_index+forecast_horizon-1-1);
    else
        other_obs_out_of_sample = other_obs(:,pos_index-1:end);  
    end
    
    this_yobs = yobs(1:pos_index-1);
    this_other_obs = other_obs(:,1:pos_index-1); %factors
    
    % if yobs has more than one row, fold all the rows after the first in
    
    yreg = this_yobs(2:end);
    xreg = [ones(1,length(yreg)); this_yobs(1:end-1); this_other_obs(:,1:end-1)];

    
% this is the start of the code that allows for multiple lags
% it still needs to be debugged and the forecast code below needs to be 
% made compatible with it
%
%     yreg = this_yobs(1+reglag:end);
%     xreg = [];
%     for this_lag=1:reglag
%         xreg = [xreg; this_other_obs(1+reglag-this_lag:end-this_lag)];
%     end
%     xreg = [ones(1,length(yreg); this_yobs(1+reglag-1:end-1); xreg];
%     
    ols_coef = estimate_ols(yreg,xreg);
    
    % combine forecast part and relevant lags here.
    
    this_forecast_horizon = min(end_sample_pos-pos_index+1,10);
    forecast = zeros(1,this_forecast_horizon);
    previous_forecast = this_yobs(1,end);
    for this_step = 1:this_forecast_horizon
        % figure out dimensions
        forecast(this_step) = [1, previous_forecast, transpose(other_obs_out_of_sample(:,this_step)) ]*...
                              ols_coef;
        previous_forecast = forecast(this_step);
    end
    
    
    forecast_mat(pos_index-out_of_sample_start_pos+1,1:length(forecast)) = forecast;
    
    
    if  end_sample_pos - pos_index + 1 >= forecast_horizon 
        forecast_errors = yobs(1,pos_index:pos_index+forecast_horizon-1) - forecast(end,:);
        forecast_errors_mat(pos_index-out_of_sample_start_pos+1,:) = forecast_errors;
    else
        forecast_errors = yobs(1,pos_index:end_sample_pos) - forecast(1:end_sample_pos-pos_index+1);
        forecast_errors_mat(pos_index-out_of_sample_start_pos+1,1:end_sample_pos-pos_index+1) = forecast_errors;
        
    end
    
end

rmse_mat = (nansum((forecast_errors_mat.^2))./(size(forecast_errors_mat,1)-sum(isnan(forecast_errors_mat)))).^0.5;
