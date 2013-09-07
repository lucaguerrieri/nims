function [rmse_varmat, forecast_mat, ...
          forecast_errors_mat, insample_forecast_errors_mat] = ...
          calc_rmse_var_conditional_rolling(yobs, other_var_obs, ...
         out_of_sample_start_pos, end_sample_pos, forecast_horizon, varlag)
%This function computes rmse for a VAR forecast and also returns
%forecast history over a pseudo-out of sample portion of the sample.
%
%Inputs: 
%yobs is a row vector, a series spanning entire available sample.
%other_var_obs is a matrix, each row is an additional series entering the
%VAR and spanning the entire available sample. NB: The rmse is going to be
%conditional on everything in other_var_obs. Needs to have the same number
%of columns as yobs.
%out_of_sample_start_pos is the position of the first pseudo-out of sample
%observation.
%end_sample_pos is the position of the last pseudo-out of sample
%observation.
%varlag is the number of lags used in the VAR.
%
%Outputs:
% rmse_varmat is a row vector containing RMSEs for each forecast step.
% var_forecasts is a matrix containing a forecast for each period in the
% pseudo-out of sample. Each row of forecast_mat contains a forecast for
% the horizon desired.

%Now get RMSEs using the VAR model
n_other_var_obs = size(other_var_obs, 1);

num_periods = end_sample_pos - out_of_sample_start_pos + 1;
forecast_errors_mat = nan*ones(num_periods, forecast_horizon);
forecast_mat = nan*ones(num_periods, forecast_horizon);
insample_forecast_mat = nan*ones(num_periods,1);

sample_size = out_of_sample_start_pos-1;
for pos_index = out_of_sample_start_pos:end_sample_pos
    
    if pos_index <= end_sample_pos - forecast_horizon
    other_var_obs_out_of_sample = other_var_obs(:,pos_index:pos_index+forecast_horizon-1);
    else
      other_var_obs_out_of_sample = other_var_obs(:,pos_index:end);  
    end
    
    this_yobs = yobs(:,pos_index-sample_size:pos_index-1);
    this_other_var_obs = other_var_obs(:,pos_index-sample_size:pos_index-1); %factors
    
    var_data= [this_other_var_obs' this_yobs'];
    
    % prepare matrices needed for call to Kalman smoother
    
    [coefb,const,coverr] = runvar_general(var_data,varlag);
    
    f_var=companion(coefb,const);
    
    
    xi11 = [var_data(end,:)]';
    for lag_num=1:varlag-1
        xi11 = [xi11; var_data(end-lag_num,:)'];
    end;
    xi11 = [xi11; 1];
    xi10new = f_var*xi11;
    
nvars = size(var_data,2);    
    %NB:  q is the Cholesky of Q in Hamilton's notation
bmatsmall = zeros(length(xi10new));  %q = zeros(nvars*varlag+1);
bmatsmall(1:nvars,1:nvars) = chol(coverr)';

% this is the variance covariance matrix for the initial state. 
% I am setting this to zero, equivalent to saying that we know the
% initial state with certainty.
p10 = 0.000000000001*eye(size(bmatsmall,1));
    
    % just select the positions in the state vector corresponding to interest
    % rates
    h = zeros(n_other_var_obs,length(xi11));
    for factor_indx = 1:n_other_var_obs
        h(factor_indx,factor_indx) = 1;
    end
    
    h = h';
    
    % set x and a to zero
    a=zeros(n_other_var_obs);
    x=zeros(n_other_var_obs,1);
    
    ntrain = 0; %ntrain is only needed for log-likelihood, which we are ignoring here.
    [logLikel,errcode,xi10History,xi1tHistory,errHistory,xi11History]=kalmanFilterSmoother(f_var, h, other_var_obs_out_of_sample, xi10new, p10, bmatsmall, ntrain);
    
    forecast_var = xi10History;
    
    
    xi11 = [var_data(end-1,:)]';
    for lag_num=1:varlag-1
        xi11 = [xi11; var_data(end-1-lag_num,:)'];
    end;
    
    xi11 = [xi11; 1];
    xi10new = f_var*xi11;
    insample_forecast = xi10new(n_other_var_obs+1,:);
    insample_forecast_mat(pos_index-out_of_sample_start_pos+1)=insample_forecast;
    
    forecast = forecast_var(n_other_var_obs+1,:); 
    forecast_mat(pos_index-out_of_sample_start_pos+1,1:length(forecast)) = forecast;
    
    forecast_errors = zeros(1,forecast_horizon);
    
    if  end_sample_pos - pos_index + 1 >= forecast_horizon 
        forecast_errors = yobs(1,pos_index:pos_index+forecast_horizon-1) - forecast(end,:);
        forecast_errors_mat(pos_index-out_of_sample_start_pos+1,:) = forecast_errors;
    else
        forecast_errors = yobs(1,pos_index:end_sample_pos) - forecast(1:end_sample_pos-pos_index+1);
        forecast_errors_mat(pos_index-out_of_sample_start_pos+1,1:end_sample_pos-pos_index+1) = forecast_errors;
        
    end
    
end

insample_forecast_errors_mat = insample_forecast_mat-yobs(out_of_sample_start_pos:end)';

rmse_varmat = (nansum((forecast_errors_mat.^2))./(size(forecast_errors_mat,1)-sum(isnan(forecast_errors_mat)))).^0.5;
