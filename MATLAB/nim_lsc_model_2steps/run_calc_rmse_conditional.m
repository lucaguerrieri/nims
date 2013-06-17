
clear;

setpath;

load_paramvec_from_disk = 1;  % set to 1 to load saved param_vec from disk
% set to 0 to use first guess as defined below

ntrain = 15; %We have 153 observations per time t; we're setting ntrain to ~15% of observation pool.

[yobs, dates, yields, nims, nfactors, nothers, tau, factors] = load_data_ml; 

out_of_sample_start_pos = find(dates==2000.0);
end_sample_pos = length(dates);

nstates = nfactors + nothers;
ntaus = length(tau);

load this_iter; %includes the full sample param_vec, xi10_demeaned, p10, ntrain

param_vec_full_sample = param_vec;
opt_param_mat = zeros(length(param_vec), end_sample_pos-out_of_sample_start_pos+1);
options = optimset('HessUpdate','bfgs','display','iter','MaxIter',10000,'MaxFunEvals',1e10,'TolFun',10e-3,'TolX',1e-4);

compute_param_mat = 0;

if compute_param_mat
for pos_index = out_of_sample_start_pos:end_sample_pos
    [yobs, dates, yields, nims, nfactors, nothers, tau] = load_data_ml;
    
    display(['working on observation for date ', num2str(dates(pos_index))]);
    
    yobs = yobs(:,1:pos_index-1);
    dates = dates(:,1:pos_index-1);
    yields = yields(:,1:pos_index-1);
    nims = nims(:,1:pos_index-1);
    
    
    for fminsearch_rep = 1:1
        loss = @(x0)mylikelihood(x0,yobs,xi10_demeaned,tau,nfactors,nothers,ntrain,p10);
        option = anneal();
        option.Verbosity = 2;
        [opt_param_mat(:,pos_index-(out_of_sample_start_pos-1)), fval] = anneal(loss,param_vec_full_sample);
                
        [opt_param_mat(:,pos_index-(out_of_sample_start_pos-1)),fval,exitflag] = ...
            fminsearch('mylikelihood',opt_param_mat(:,pos_index-(out_of_sample_start_pos-1)),options,yobs,xi10_demeaned,tau,nfactors,nothers,ntrain,p10);
        
        save this_out_of_sample opt_param_mat xi10_demeaned p10 ntrain
        
    end
    
end
end
%
load this_out_of_sample
[yobs, dates, yields, nims, nfactors, nothers, tau, factors] = load_data_ml;
forecast_horizon = 10;


%% extract smoothed estimates of the yield curve factors
[yobs, dates, yields, nims, nfactors, nothers, tau, factors,  shadow_bank_share_assets] = load_data_ml;
forecast_horizon = 10;

[f, q, r, x, a, lambda, h, xi_means, error] = kalmanFilterSetup(param_vec,tau,nfactors,nothers);

[logLikel,errcode,xi1tHistory]= ...
    kalmanFilterSmoother_v2(f, h, yobs, a, x, xi10_demeaned, p10, q, r, ntrain);  


smoothed_factors = xi1tHistory(1:3,:);


%% get RMSEs
lag = 1;

% Table 1 -- Shortened sample:
[rmse_forecast_combination_mat1, forecast_combination_mat1] = calc_rmse_forecast_combination_conditional(nims(:,15:end),yields(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);

[rmse_multivariate_mat1, forecast_multivariate_mat1] = calc_rmse_multivariate_conditional(nims(:,15:end), smoothed_factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, lag);
[rmse_forecast_combination_mat2, forecast_combination_mat2] = calc_rmse_forecast_combination_conditional(nims(:,15:end),smoothed_factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);

[rmse_forecast_combination_mat3, forecast_combination_mat3] = calc_rmse_forecast_combination_conditional(nims(:,15:end),factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);

varlag=4;
[rmse_varmat1, forecast_var_mat1] = calc_rmse_var_conditional(nims(:,15:end), smoothed_factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, varlag);
[rmse_varmat2, forecast_var_mat2] = calc_rmse_var_conditional(nims(:,15:end), factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, varlag);
[rmse_nochangemat1, forecast_nochange_mat1] = calc_rmse_nochange(nims(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon);



table1 = [
rmse_forecast_combination_mat1
rmse_multivariate_mat1
rmse_forecast_combination_mat2
rmse_forecast_combination_mat3
rmse_varmat1
rmse_varmat2
rmse_nochangemat1];


columnlabels = char('Step 1','Step 2','Step 3','Step 4','Step 5','Step 6','Step 7','Step 8','Step 9','Step 10');
rowlabels = char('Forecast Combination of Yields',...
                 'DFM + 2nd Step Regression',...
                 'DFM + Forecast Combination',...
                 'Forecast Combination of Simple Factors',...
                 'VAR on DF',...
                 'VAR on Simple Factors',...
                 'No-Change Forecast');
table1_tex = tablelatex(table1,columnlabels,rowlabels)



for i = 1:forecast_horizon
   figure
   plot(dates(15:end),nims(end,15:end),'k','lineWidth',2)
   hold on
   plot(dates(out_of_sample_start_pos+i-1:end),forecast_combination_mat1(1:end-i+1,i)','b--','lineWidth',2)
   plot(dates(out_of_sample_start_pos+i-1:end),forecast_nochange_mat1(1:end-i+1,i)','r:','lineWidth',2)
   
   for j = out_of_sample_start_pos+i-1:end_sample_pos
       if abs(forecast_combination_mat1(j-out_of_sample_start_pos-i+2,i)'-yobs(end,j))<=abs(forecast_nochange_mat1(j-out_of_sample_start_pos-i+2,i)'-nims(j))
           plot(dates(j),nims(j),'bo','lineWidth',2)
       else
           plot(dates(j),nims(j),'rx','lineWidth',2)
       end
   end
   legend('Data','Forecast Combination','No-change forecast')
   title(['Assessing the ',num2str(i),'-step-ahead forecast'])
   
   xlim([dates(15) dates(end)])
end


% 

% Table 2 -- full sample
[rmse_forecast_combination_mat1, forecast_multivariate_mat1] = calc_rmse_forecast_combination_conditional(nims,yields, out_of_sample_start_pos, end_sample_pos, forecast_horizon, 1,4);

[rmse_multivariate_mat1, forecast_multivariate_mat1] = calc_rmse_multivariate_conditional(nims, smoothed_factors, out_of_sample_start_pos, end_sample_pos, forecast_horizon, lag);
[rmse_forecast_combination_mat2, forecast_multivariate_mat2] = calc_rmse_forecast_combination_conditional(nims,smoothed_factors, out_of_sample_start_pos, end_sample_pos, forecast_horizon, 1,4);

[rmse_forecast_combination_mat3, forecast_multivariate_mat3] = calc_rmse_forecast_combination_conditional(nims,factors, out_of_sample_start_pos, end_sample_pos, forecast_horizon, 1,4);

varlag=4;
[rmse_varmat1, forecast_var_mat1] = calc_rmse_var_conditional(nims, smoothed_factors, out_of_sample_start_pos, end_sample_pos, forecast_horizon, varlag);
[rmse_varmat2, forecast_var_mat2] = calc_rmse_var_conditional(nims, factors, out_of_sample_start_pos, end_sample_pos, forecast_horizon, varlag);
[rmse_nochangemat1, forecast_nochange_mat1] = calc_rmse_nochange(nims, out_of_sample_start_pos, end_sample_pos, forecast_horizon);

table2 = [
rmse_forecast_combination_mat1
rmse_multivariate_mat1
rmse_forecast_combination_mat2
rmse_forecast_combination_mat3
rmse_varmat1
rmse_varmat2
rmse_nochangemat1];



columnlabels = char('Step 1','Step 2','Step 3','Step 4','Step 5','Step 6','Step 7','Step 8','Step 9','Step 10');
rowlabels = char('Forecast Combination of Yields',...
                 'DFM + 2nd Step Regression',...
                 'DFM + Forecast Combination',...
                 'Forecast Combination of Simple Factors',...
                 'VAR on DF',...
                 'VAR on Simple Factors',...
                 'No-Change Forecast');
table2_tex = tablelatex(table2,columnlabels,rowlabels)



% Table 3 -- Short sample + measures of competition
[rmse_forecast_combination_mat1, forecast_combination_mat1] = calc_rmse_forecast_combination_conditional(nims(:,15:end),[yields(:,15:end);shadow_bank_share_assets(:,15:end)], out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);

[rmse_multivariate_mat1, forecast_multivariate_mat1] = calc_rmse_multivariate_conditional(nims(:,15:end), [smoothed_factors(:,15:end);shadow_bank_share_assets(:,15:end)], out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, lag);
[rmse_forecast_combination_mat2, forecast_combination_mat2] = calc_rmse_forecast_combination_conditional(nims(:,15:end),[smoothed_factors(:,15:end);shadow_bank_share_assets(:,15:end)], out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);

[rmse_forecast_combination_mat3, forecast_combination_mat3] = calc_rmse_forecast_combination_conditional(nims(:,15:end),[factors(:,15:end) ;shadow_bank_share_assets(:,15:end)], out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);

varlag=3;
[rmse_varmat1, forecast_var_mat1] = calc_rmse_var_conditional(nims(:,15:end), [smoothed_factors(:,15:end);shadow_bank_share_assets(:,15:end)], out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, varlag);
[rmse_varmat2, forecast_var_mat2] = calc_rmse_var_conditional(nims(:,15:end), [factors(:,15:end);shadow_bank_share_assets(:,15:end)], out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, varlag);
[rmse_nochangemat1, forecast_nochange_mat1] = calc_rmse_nochange(nims(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon);



table3 = [
rmse_forecast_combination_mat1
rmse_multivariate_mat1
rmse_forecast_combination_mat2
rmse_forecast_combination_mat3
rmse_varmat1
rmse_varmat2
rmse_nochangemat1];



columnlabels = char('Step 1','Step 2','Step 3','Step 4','Step 5','Step 6','Step 7','Step 8','Step 9','Step 10');
rowlabels = char('Forecast Combination of Yields',...
                 'DFM + 2nd Step Regression',...
                 'DFM + Forecast Combination',...
                 'Forecast Combination of Simple Factors',...
                 'VAR on DF',...
                 'VAR on Simple Factors',...
                 'No-Change Forecast');
table3_tex = tablelatex(table3,columnlabels,rowlabels)

