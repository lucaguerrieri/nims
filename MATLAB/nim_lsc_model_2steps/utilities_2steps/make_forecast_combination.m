function forecast_mat = make_forecast_combination(this_yobs, this_other_obs, previous_forecast, other_obs_out_of_sample,firstlag,lastlag)


    this_forecast_horizon = size(other_obs_out_of_sample,2)-lastlag;
    n_other_obs = size(this_other_obs,1);
    forecast = zeros(n_other_obs,this_forecast_horizon);
    
    for this_macro_factor = 1:n_other_obs
        
        yreg = this_yobs(1+max(lastlag,1):end);
        xreg = [];
        for this_lag=firstlag:lastlag
            xreg = [xreg; this_other_obs(this_macro_factor,1+max(lastlag,1)-this_lag:end-this_lag)];
        end
        xreg = [ones(1,length(yreg)); this_yobs(1+lastlag-firstlag:end-max(firstlag,1)); xreg];
        
        ols_coef = estimate_ols(yreg,xreg);
        
  
        for this_step = 1:this_forecast_horizon
            % figure out dimensions
            pos_vec =  (lastlag:-1:firstlag)-firstlag+this_step;
            forecast(this_macro_factor,this_step) = [1, previous_forecast, other_obs_out_of_sample(this_macro_factor,pos_vec) ]*...
                ols_coef;
            previous_forecast = forecast(this_macro_factor,this_step);
        end
        
    end
    

forecast_mat = mean(forecast);