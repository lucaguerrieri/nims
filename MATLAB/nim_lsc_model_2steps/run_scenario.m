
clear;

setpath;

load_paramvec_from_disk = 1;  % set to 1 to load saved param_vec from disk
% set to 0 to use first guess as defined below

ntrain = 15; %We have 153 observations per time t; we're setting ntrain to ~15% of observation pool.

dataset_option = 1;

[yobs, dates, yields, nims, nfactors, nothers, tau, factors,...
    shadow_bank_share_assets,...
    total_interest_earning_assets,...
    assets_depository_inst, assets_securities_notrade,...
    assets_fedfunds, assets_all_loans, assets_trading_accnts, ... 
    interest_income_to_ie_assets, interest_expense_to_ie_assets] = load_data_ml(dataset_option);
 
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


%% extract smoothed estimates of the yield curve factors
forecast_horizon = 10;

[f, q, r, x, a, lambda, h, xi_means, error] = kalmanFilterSetup(param_vec,tau,nfactors,nothers);

[logLikel,errcode,xi1tHistory]= ...
    kalmanFilterSmoother_v2(f, h, yobs, a, x, xi10_demeaned, p10, q, r, ntrain);  


smoothed_factors = xi1tHistory(1:3,:);


[rmse_forecast_combination_mat4, forecast_combination_mat1] = calc_rmse_forecast_combination_conditional(nims(:,15:end),yields([find(tau==3),find(tau==120)],15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);


% import scenarios
baseline_scen = [
0.100003007	1.699999995
0.10000251	1.799999972
0.100001751	1.999999908
0.200000742	2.099999801
0.199999685	2.299999755
0.454687757	2.589062469
0.607812537	2.798437496
0.77656239	3.004687513
0.960937317	3.207812522
1.153125	3.446875
1.371875	3.628125
1.609375	3.790625001
1.865625002	3.934375002
]';

adverse_scen = [0.5	2.528056564
1	2.917912452
1.500000001	3.349583553
2.000000005	3.356562622
2.500000016	3.62716268
2.750000041	4.003972959
3.000000083	4.245083321
3.000000129	4.434194862
3.000000152	4.649734856
3.250000092	4.919282927
3.499999851	5.138259743
3.749999314	5.323878072
3.999998356	5.438323268]';


severe_scen = [0.1	1.439401602
0.1	1.2394016
0.1	1.239401603
0.1	1.239401601
0.1	1.239401603
0.1	1.239401608
0.099999999	1.491521284
0.099999994	1.693217024
0.09999997	1.854573606
0.099999864	1.983658825
0.099999581	2.086926916
0.099999225	2.169541404
0.100000382	2.235633966]';

history_scen =[0.014754098	2.0939345
0.070645161	2.0632112
0.088281251	1.8260547
0.1015873	1.6394016]';


this_yobs = nims(:,15:end);
this_other_obs = yields([find(tau==3),find(tau==120)],15:end);
previous_forecast = 3.230921724000000;  % NIM obs for 2012q4
other_obs_out_of_sample = [history_scen baseline_scen(:,1:10)];
firstlag = 1;
lastlag = 4;
forecast_baseline =  make_forecast_combination(this_yobs, this_other_obs, previous_forecast, other_obs_out_of_sample,firstlag,lastlag);

other_obs_out_of_sample = [history_scen adverse_scen(:,1:10)];
forecast_adverse = make_forecast_combination(this_yobs, this_other_obs, previous_forecast, other_obs_out_of_sample,firstlag,lastlag);

other_obs_out_of_sample = [history_scen severe_scen(:,1:10)];
forecast_severe = make_forecast_combination(this_yobs, this_other_obs, previous_forecast, other_obs_out_of_sample,firstlag,lastlag);


figure

forecast_dates = 2012.75:.25:2015;

subplot(3,2,1)
plot(forecast_dates,baseline_scen(1,1:10),'k');
hold on
plot(forecast_dates,severe_scen(1,1:10),'r--');
title('3-Month Treasury Yields')
legend('Baseline','Severely Adverse Scenario','Location','NorthWest')
xlim([2012 2015])
ylim([0 4])


subplot(3,2,2)
plot(forecast_dates,baseline_scen(1,1:10),'k');
hold on
plot(forecast_dates,adverse_scen(1,1:10),'r--');

title('3-Month Treasury Yields')
legend('Baseline','Adverse Scenario','Location','NorthWest')
xlim([2012 2015])
ylim([0 4])

subplot(3,2,3)
plot(forecast_dates,baseline_scen(2,1:10),'k');
hold on
plot(forecast_dates,severe_scen(2,1:10),'r--');
title('10-Year Treasury Yields')
legend('Baseline','Severely Adverse Scenario','Location','NorthWest')
xlim([2012 2015])
ylim([0 5])


subplot(3,2,4)
plot(forecast_dates,baseline_scen(2,1:10),'k');
hold on
plot(forecast_dates,adverse_scen(2,1:10),'r--');

title('10-Year Treasury Yields')
legend('Baseline','Adverse Scenario','Location','NorthWest')
xlim([2012 2015])
ylim([0 5])


subplot(3,2,5)
plot(forecast_dates, forecast_baseline,'k'); hold on
plot(forecast_dates, forecast_severe,'r--')
plot(forecast_dates, forecast_severe+rmse_forecast_combination_mat4,'r-.')
title('Forecast of NIMs')
legend('Baseline','Severely Adverse','1-RMSE band','Location','SouthWest')

plot(forecast_dates, forecast_severe-rmse_forecast_combination_mat4,'r-.')



subplot(3,2,6)
plot(forecast_dates, forecast_baseline,'k'); hold on
plot(forecast_dates, forecast_adverse,'r--')
plot(forecast_dates, forecast_adverse+rmse_forecast_combination_mat4,'r-.')
legend('Baseline','Adverse','1-RMSE band','Location','SouthWest')
plot(forecast_dates, forecast_adverse-rmse_forecast_combination_mat4,'r-.')


title('Forecast of Nims')




