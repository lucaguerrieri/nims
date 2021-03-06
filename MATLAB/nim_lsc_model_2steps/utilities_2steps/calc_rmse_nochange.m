function [rmse_nochangemat, forecast_mat, forecast_errors_mat, insample_forecast_errors_mat] = calc_rmse_nochange(yobs, out_of_sample_start_pos, end_sample_pos, forecast_horizon)
%This function computes rmse for a nochange forecast and also returns
%forecast history over a pseudo-out of sample portion of the sample.
%Inputs: 
%yobs is a row vector, a series spanning entire available sample.
%out_of_sample_start_pos is the position of the first pseudo-out of sample
%observation.
%end_sample_pos is the position of the last pseudo-out of sample
%observation.
%Outputs:
% rmse_nochangemat is a row vector containing RMSEs for each forecast step.
% forecast_mat is a matrix containing a forecast for each period in the
% pseudo-out of sample. Each row of forecast_mat contains a forecast for
% the horizon desired.

%% No Change Forecast
num_periods = end_sample_pos - out_of_sample_start_pos + 1;
forecast_errors_mat = nan*ones(num_periods, forecast_horizon);

forecast_mat = kron(yobs(out_of_sample_start_pos-1:end_sample_pos-1)',ones(1,forecast_horizon));
insample_forecast_mat = yobs(out_of_sample_start_pos-2:end_sample_pos-2);


[y_mat] = make_y_mat(yobs(out_of_sample_start_pos:end_sample_pos)',forecast_horizon);

forecast_errors_mat = forecast_mat -y_mat;
insample_forecast_errors_mat = insample_forecast_mat' - yobs(out_of_sample_start_pos:end)';

rmse_nochangemat = (nansum((forecast_errors_mat.^2))./(size(forecast_errors_mat,1)-sum(isnan(forecast_errors_mat)))).^0.5;
