function [rmse_mat, forecast_mat, forecast_errors_mat] = calc_rmse_pls_conditional(yobs, other_obs, out_of_sample_start_pos, end_sample_pos, forecast_horizon, npls )

% FOR NOW -- reglag does not affect anything. The regression is run with
% only one lag of other_obs

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
%NPC is the number of the largest principal components used in the regression.
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
    
    ylag = 1;
    
    mean_this_yobs = mean(this_yobs);
    this_yobs_demeaned = this_yobs-mean_this_yobs;
    
    mean_this_other_obs = mean(this_other_obs,2);
    this_other_obs_demeaned = this_other_obs-kron(mean_this_other_obs,ones(1,size(this_other_obs,2)));

    beta_y = regress(this_yobs_demeaned(2:end)',this_yobs_demeaned(1:end-1)');
    u_y = this_yobs_demeaned(2:end)' - this_yobs_demeaned(1:end-1)'*beta_y;
    
    %u_x = zeros(n_other_obs,size(this_yobs_demeaned,2)-1);
    beta_x = zeros(1,n_other_obs);  
    for x_pos =1:n_other_obs
        beta_x(x_pos) = regress(this_other_obs_demeaned(x_pos,2:end)',this_yobs_demeaned(1:end-1)');
    end
    u_x = this_other_obs_demeaned(:,2:end)'-kron(this_yobs_demeaned(1:end-1)',beta_x);


    %[XL,YL,XS,YS,beta_pls] = plsregress(u_x,u_y,npls);
    
    % the PLS factors are in T
    % u_x *R = T
    [B,C,P,T,U,R,R2X,R2Y]=plssim(u_x,u_y,npls);
    
    beta_pls = regress(this_yobs_demeaned(2:end)',[this_yobs_demeaned(1:end-1)',T]);
    
    this_forecast_horizon = min(end_sample_pos-pos_index+1,10);
    forecast = zeros(1,this_forecast_horizon);
    previous_forecast = this_yobs(1,end);
    for this_step = 1:this_forecast_horizon
        % to finish off -- 
        % construct u_x
        % apply 
        this_u_x = (other_obs_out_of_sample(:,this_step)'-mean_this_other_obs')-(previous_forecast-mean_this_yobs)*beta_x;
        forecast(this_step) = [previous_forecast-mean_this_yobs, this_u_x*R ]*...
                              beta_pls+mean_this_yobs;
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

% figure
% plot(forecast_mat(:,1),'r--')
% hold on
% plot(yobs(out_of_sample_start_pos:end))


rmse_mat = (nansum((forecast_errors_mat.^2))./(size(forecast_errors_mat,1)-sum(isnan(forecast_errors_mat)))).^0.5;
