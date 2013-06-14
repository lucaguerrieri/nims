function [rmse_mlmat rmse_varmat rmse_nochangemat ml_forecasts nochange_forecasts] = calc_rmse(opt_param_mat, out_of_sample_start_pos, end_sample_pos, yobs, factors, xi10, p10, ntrain, tau, nfactors, nothers, forecast_horizon, dates)

plotbool =1

%%%Maximum-Likelihood pseudo-out of sample forecasts%%%
nstates = nfactors+nothers;
num_periods = end_sample_pos - out_of_sample_start_pos;
errors_mat = zeros(num_periods, forecast_horizon);
rmse_mat = zeros(num_periods, 1);

ntau = length(tau);

ml_forecasts = nan*zeros(forecast_horizon,end_sample_pos - out_of_sample_start_pos+1);
for pos_index = out_of_sample_start_pos:end_sample_pos
    
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
    
    
    
    if pos_index <= end_sample_pos - forecast_horizon
        forecasts = xi11History + kron(ones(1,forecast_horizon),xi_means);
        if plotbool
        figure    
        plot(dates(pos_index-20:pos_index-1), yobs(end,pos_index-20:pos_index-1), 'k-','lineWidth',2);
        hold on
        plot(dates(pos_index):.25:dates(pos_index)+(forecast_horizon-1)/4, forecasts(end,:), 'b--','lineWidth',2);
        plot(dates(pos_index):.25:dates(pos_index)+(forecast_horizon-1)/4,yobs(end,pos_index:pos_index+forecast_horizon-1), 'k-');
        end
        ml_forecasts(:,pos_index-out_of_sample_start_pos+1) = forecasts(end,:)';
        forecast_errors = yobs(end,pos_index:pos_index+forecast_horizon-1) - forecasts(end,:);
        errors_mat(pos_index-out_of_sample_start_pos+1,:) = forecast_errors;
    else
        forecasts = xi11History + kron(ones(1,size(xi11History,2)),xi_means);
        forecast_errors(1:end_sample_pos-pos_index) = yobs(end,pos_index:end_sample_pos-1) - forecasts(end,1:end_sample_pos-pos_index);
        forecast_errors(forecast_horizon - (end_sample_pos - pos_index)+1:end) = NaN;
        ml_forecasts(1:length(forecasts(end,:)), pos_index-out_of_sample_start_pos+1)=forecasts(end,:)';
        errors_mat(pos_index-out_of_sample_start_pos+1,:) = forecast_errors;
    end
    title('Conditional Forecast from Dynamic Factor Model for NIMs')
end

rmse_mlmat = (nansum((errors_mat.^2))./(size(errors_mat,1)-sum(isnan(errors_mat)))).^0.5;


%%
%Now get RMSEs using the VAR model
errors_mat = zeros(num_periods, forecast_horizon);

for pos_index = out_of_sample_start_pos:end_sample_pos
    [yobs, dates, yields, nims, nfactors, nothers, tau, factors] = load_data_ml;
    
    if pos_index <= end_sample_pos - forecast_horizon
    factors_out_of_sample = factors(:,pos_index:pos_index+forecast_horizon-1);
    else
      factors_out_of_sample = factors(:,pos_index:end);  
    end
    
    nims = nims(:,1:pos_index-1);
    factors = factors(:,1:pos_index-1);
    
    var_data= [factors' nims'];
    
    varlag = 1;
    
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
    h = zeros(nfactors,length(xi11));
    for factor_indx = 1:nfactors
        h(factor_indx,factor_indx) = 1;
    end
    
    h = h';
    
    % set x and a to zero
    a=zeros(nfactors);
    x=zeros(nfactors,1);
    
    [logLikel,errcode,xi10History,xi1tHistory,errHistory,xi11History]=kalmanFilterSmoother(f_var, h, factors_out_of_sample, xi10new, p10, bmatsmall, ntrain);
    
    forecast_var = xi10History;
    %[forecast_var] = var_out_of_sample_forecasts(f_var, var_data, varlag, nfactors, nothers, forecast_horizon);
    
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

nochane_forecasts = nan*zeros(forecast_horizon,end_sample_pos - out_of_sample_start_pos+1);

errors_mat = zeros(num_periods, forecast_horizon);
[yobs, dates, yields, nims, nfactors, nothers, tau, factors] = load_data_ml;
for pos_index = out_of_sample_start_pos:end_sample_pos
    
    
    forecast_nim = nims(pos_index-1)*ones(1,forecast_horizon);
    
    nochange_forecasts(:,pos_index-out_of_sample_start_pos+1)=forecast_nim';
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
