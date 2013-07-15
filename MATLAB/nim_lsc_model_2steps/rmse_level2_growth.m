function [rmse_level forecast_mat_level] = rmse_change2level(forecast_mat_change,out_of_sample_y,y_pre_out_of_sample) 

   
% forecast_mat_change contains the pseudo out-of-sample forecasts.
% the ith col holds the ith-step-ahead forecast.
%
% out_of_sample_y holds the level of the observed variable that was
% forecasted.
%
% y_pre_out_of_sample holds first y level value preceding the out-of-sample y levels.  It is needed to unravel
% the forecast for the level from the forecasts for the change.

if size(out_of_sample_y,1)<size(out_of_sample_y,2)
out_of_sample_y = transpose(out_of_sample_y);
end

n_steps_ahead = size(forecast_mat_change,2);
n_obs_out_of_sample = size(forecast_mat_change,1);

forecast_mat_level = forecast_mat_change;

level = y_pre_out_of_sample;
for this_obs = 1:n_obs_out_of_sample


for this_step = n_steps_ahead
    level = level+forecast_mat_change(this_obs,this_step);
    forecast_mat_level(this_obs,this_step) = level;    
end

level = out_of_sample_y(this_obs);
end


% arrange y data to be conformable with forecast matrix
y_mat = nan*out_of_sample_y;

for this_step = 1:n_steps_ahead
    y_mat(1:end-this_step+1,this_step) = out_of_sample_y(this_step:end);
end

forecast_errors_mat =forecast_mat_level-y_mat; 

rmse_level = (nansum((forecast_errors_mat.^2))./(size(forecast_errors_mat,1)-sum(isnan(forecast_errors_mat)))).^0.5;






