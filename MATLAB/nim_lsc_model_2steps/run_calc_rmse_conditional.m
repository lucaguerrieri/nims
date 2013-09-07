
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
forecast_horizon = 10;


%% extract smoothed estimates of the yield curve factors
forecast_horizon = 10;

[f, q, r, x, a, lambda, h, xi_means, error] = kalmanFilterSetup(param_vec,tau,nfactors,nothers);

[logLikel,errcode,xi1tHistory]= ...
    kalmanFilterSmoother_v2(f, h, yobs, a, x, xi10_demeaned, p10, q, r, ntrain);  


smoothed_factors = xi1tHistory(1:3,:);


%% get RMSEs
lag = 1;

% Table 1 -- Shortened sample:
[rmse_forecast_combination_mat1, forecast_combination_mat1,...
 forecast_combination_errors_mat1 insample_forecast_combination_errors_mat1] = calc_rmse_forecast_combination_conditional(nims(:,15:end),yields(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);

[rmse_forecast_combination_rolling_mat1, forecast_combination_rolling_mat1,...
 forecast_combination_errors_mat1 insample_forecast_combination_errors_mat1] = calc_rmse_forecast_combination_conditional_rolling(nims(:,15:end),yields(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);


nims_change = nims(:,15:end)-nims(:,14:end-1);
nims_change_out_of_sample = nims_change(out_of_sample_start_pos-14:end);
nims_change_pre_out_of_sample = nims_change(out_of_sample_start_pos-15);
[rmse_forecast_combination_change_mat1, forecast_combination_change_mat1] = calc_rmse_forecast_combination_conditional(nims_change,yields(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);
[rmse_forecast_combination_level_mat1, forecast_combination_level_mat1] = rmse_change2level(forecast_combination_change_mat1,nims_change_out_of_sample,nims_change_pre_out_of_sample); 


[rmse_multivariate_mat1, forecast_multivariate_mat1] = calc_rmse_multivariate_conditional(nims(:,15:end), smoothed_factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, lag);

[rmse_multivariate_rolling_mat1, forecast_multivariate_rolling_mat1 ...
 multivariate_errors_mat1 insample_multivariate_errors_mat1] = calc_rmse_multivariate_conditional_rolling(nims(:,15:end), smoothed_factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, lag);


[rmse_forecast_combination_mat2, forecast_combination_mat2] = calc_rmse_forecast_combination_conditional(nims(:,15:end),smoothed_factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);
[rmse_forecast_combination_rolling_mat2, forecast_combination_rolling_mat2...
    forecast_combination_errors_mat2 insample_forecast_combination_errors_mat2] = calc_rmse_forecast_combination_conditional_rolling(nims(:,15:end),smoothed_factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);


npc = 3;
[rmse_pc_mat1, forecast_pc_mat1] = calc_rmse_pc(nims(:,15:end), yields(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, npc);
[rmse_pc_rolling_mat1, forecast_pc_rolling_mat1, pc_forecast_errors_mat, insample_pc_forecast_errors_mat] = calc_rmse_pc_rolling(nims(:,15:end), yields(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, npc);

npls = 5;
[rmse_pls_mat1, forecast_pls_mat1] = calc_rmse_pls_conditional(nims(:,15:end), yields(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, npls);

[rmse_forecast_combination_mat3, forecast_combination_mat3] = calc_rmse_forecast_combination_conditional(nims(:,15:end),factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);
[rmse_forecast_combination_rolling_mat3, forecast_combination_rolling_mat3 forecast_combination_errors_mat3 insample_forecast_combination_errors_mat3] = calc_rmse_forecast_combination_conditional_rolling(nims(:,15:end),factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);


varlag=4;
[rmse_var_mat1, forecast_var_mat1] = calc_rmse_var_conditional(nims(:,15:end), smoothed_factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, varlag);
[rmse_var_rolling_mat1, forecast_var_rolling_mat1 ...
  var_forecast_errors_mat1 insample_var_forecast_errors_mat1] = calc_rmse_var_conditional_rolling(nims(:,15:end), smoothed_factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, varlag);



[rmse_var_mat2, forecast_var_mat2] = calc_rmse_var_conditional(nims(:,15:end), factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, varlag);
[rmse_var_rolling_mat2, forecast_var_rolling_mat2,...
    var_forecast_errors_mat2 insample_var_forecast_errors_mat2] = calc_rmse_var_conditional_rolling(nims(:,15:end), factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, varlag);


[rmse_nochange_mat1, forecast_nochange_mat1, forecast_errors_nochange_mat, insample_forecast_errors_nochange_mat] = calc_rmse_nochange(nims(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon);



% Run the RS test on all models
RLout = forecast_combination_errors_mat1(:,1).^2-forecast_errors_nochange_mat(:,1).^2;
RLin = insample_forecast_combination_errors_mat1.^2 - insample_forecast_errors_nochange_mat.^2;
qn = floor(size(forecast_combination_errors_mat1,1)^(1/4))+1;
m = 4;



test_results = run_rs_tests(forecast_combination_errors_mat1(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_forecast_combination_errors_mat1,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table = [test_results];

test_results = run_rs_tests(multivariate_errors_mat1(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_multivariate_errors_mat1,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table = [test_table; test_results];                       
                        
test_results = run_rs_tests(forecast_combination_errors_mat2(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_forecast_combination_errors_mat2,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table = [test_table; test_results];  

test_results = run_rs_tests(pc_forecast_errors_mat(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_pc_forecast_errors_mat,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table = [test_table; test_results];  

test_results = run_rs_tests(forecast_combination_errors_mat3(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_forecast_combination_errors_mat3,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table = [test_table; test_results];     
                      
test_results = run_rs_tests(var_forecast_errors_mat2(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_var_forecast_errors_mat1,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table = [test_table; test_results];                             


%%%%%%%%%%%%%%%%%%%%
% now repeat test for different m

m = 12;

test_results = run_rs_tests(forecast_combination_errors_mat1(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_forecast_combination_errors_mat1,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table2 = [test_results];

test_results = run_rs_tests(multivariate_errors_mat1(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_multivariate_errors_mat1,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table2 = [test_table2; test_results];                       
                        
test_results = run_rs_tests(forecast_combination_errors_mat2(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_forecast_combination_errors_mat2,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table2 = [test_table2; test_results];  

test_results = run_rs_tests(pc_forecast_errors_mat(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_pc_forecast_errors_mat,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table2 = [test_table2; test_results];  

test_results = run_rs_tests(forecast_combination_errors_mat3(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_forecast_combination_errors_mat3,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table2 = [test_table2; test_results];     
                      
test_results = run_rs_tests(var_forecast_errors_mat2(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_var_forecast_errors_mat1,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table2 = [test_table2; test_results];                             






columnlabels_test = char('m = 4', 'm=12');
rowlabels_test = char('1. F. Combination - Yields',...
                 '3a. DFM with 2nd Step Reg.',...
                 '3b. DFM with F. Combination',...
                 '4. PCR',...
                 '6. F. Combination - Observed Factors',...
                 '7. VAR on Observed Factors');
test_table_tex =tablelatex_testresults([test_table test_table2],columnlabels_test,rowlabels_test);

char(test_table_tex)



% ols_beta  = mldivide(RLin'*RLin,RLin'*RLout);
% ols_err = RLout - RLin*ols_beta;
% 
% a1 = sum(RLout)/length(RLout);
% b1 = ols_beta*sum(RLin)/length(RLout);
% u1 = sum(ols_err)/length(RLout);
% 
% 
% figure
% subplot(3,1,1)
% plot(dates(out_of_sample_start_pos:end_sample_pos),RLout)
% hold on
% plot(dates(out_of_sample_start_pos:end_sample_pos),a1+0*RLout,'r--')
% title('out of sample')
% 
% subplot(3,1,2)
% plot(dates(out_of_sample_start_pos:end_sample_pos),ols_beta*RLin); hold on
% plot(dates(out_of_sample_start_pos:end_sample_pos),b1+0*RLin,'r--')
% title('in sample')
% 
% subplot(3,1,3)
% plot(dates(out_of_sample_start_pos:end_sample_pos),ols_err); hold on
% plot(dates(out_of_sample_start_pos:end_sample_pos),u1+0*ols_err,'r--')
% title('residual')





table1 = [
rmse_forecast_combination_mat1
rmse_forecast_combination_level_mat1
rmse_multivariate_mat1
rmse_forecast_combination_mat2
rmse_pc_mat1
rmse_pls_mat1
rmse_forecast_combination_mat3
rmse_var_mat2
rmse_nochange_mat1]




columnlabels = char('Step 1','Step 2','Step 3','Step 4','Step 5','Step 6','Step 7','Step 8','Step 9','Step 10');
rowlabels = char('1. F. Combination - Yields',...
                 '1b. F. Combination of change - Yields',... 
                 '3a. DFM with 2nd Step Reg.',...
                 '3b. DFM with F. Combination',...
                 '4. PCR',...
                 '5. PLS',...
                 '6. F. Combination - Observed Factors',...
                 '7. VAR on Observed Factors',...
                 '8. No-Change Forecast');
table1_tex = tablelatex(table1,columnlabels,rowlabels);
char(table1_tex)


%%% same as table 1 but with rolling sample


table1_rolling = [
rmse_forecast_combination_rolling_mat1
rmse_multivariate_rolling_mat1
rmse_forecast_combination_rolling_mat2
rmse_pc_rolling_mat1
rmse_forecast_combination_rolling_mat3
rmse_var_rolling_mat2
rmse_nochange_mat1]




columnlabels = char('Step 1','Step 2','Step 3','Step 4','Step 5','Step 6','Step 7','Step 8','Step 9','Step 10');
rowlabels_rolling = char('1. F. Combination - Yields',...
                 '3a. DFM with 2nd Step Reg.',...
                 '3b. DFM with F. Combination',...
                 '4. PCR',...
                 '6. F. Combination - Observed Factors',...
                 '7. VAR on Observed Factors',...
                 '8. No-Change Forecast');
table1_rolling_tex = tablelatex(table1_rolling,columnlabels,rowlabels_rolling);
char(table1_rolling_tex)




% for i = [2, 4, 10]
%    figure
%    plot(dates(15:end),nims(end,15:end),'k','lineWidth',2)
%    hold on
%    plot(dates(out_of_sample_start_pos+i-1:end),forecast_combination_mat1(1:end-i+1,i)','b--','lineWidth',2)
%    plot(dates(out_of_sample_start_pos+i-1:end),forecast_nochange_mat1(1:end-i+1,i)','r:','lineWidth',2)
%    
%    for j = out_of_sample_start_pos+i-1:end_sample_pos
%        if abs(forecast_combination_mat1(j-out_of_sample_start_pos-i+2,i)'-yobs(end,j))<=abs(forecast_nochange_mat1(j-out_of_sample_start_pos-i+2,i)'-nims(j))
%            plot(dates(j),nims(j),'bo','lineWidth',2)
%        else
%            plot(dates(j),nims(j),'rx','lineWidth',2)
%        end
%    end
%    legend('Data','Forecast Combination','No-change forecast')
%    title(['Assessing the ',num2str(i),'-step-ahead forecast'])
%    
%    xlim([dates(15) dates(end)])
% end


% 

% Table 2 -- full sample
[rmse_forecast_combination_mat1, forecast_multivariate_mat1] = calc_rmse_forecast_combination_conditional(nims,yields, out_of_sample_start_pos, end_sample_pos, forecast_horizon, 1,4);

[rmse_multivariate_mat1, forecast_multivariate_mat1] = calc_rmse_multivariate_conditional(nims, smoothed_factors, out_of_sample_start_pos, end_sample_pos, forecast_horizon, lag);
[rmse_forecast_combination_mat2, forecast_multivariate_mat2] = calc_rmse_forecast_combination_conditional(nims,smoothed_factors, out_of_sample_start_pos, end_sample_pos, forecast_horizon, 1,4);
npc = 3;
[rmse_pc_mat1, forecast_pc_mat1] = calc_rmse_pc(nims, yields, out_of_sample_start_pos, end_sample_pos, forecast_horizon, npc);


[rmse_forecast_combination_mat3, forecast_multivariate_mat3] = calc_rmse_forecast_combination_conditional(nims,factors, out_of_sample_start_pos, end_sample_pos, forecast_horizon, 1,4);

varlag=4;
[rmse_varmat1, forecast_var_mat1] = calc_rmse_var_conditional(nims, smoothed_factors, out_of_sample_start_pos, end_sample_pos, forecast_horizon, varlag);
[rmse_varmat2, forecast_var_mat2] = calc_rmse_var_conditional(nims, factors, out_of_sample_start_pos, end_sample_pos, forecast_horizon, varlag);
[rmse_nochangemat1, forecast_nochange_mat1] = calc_rmse_nochange(nims, out_of_sample_start_pos, end_sample_pos, forecast_horizon);

table2 = [
rmse_forecast_combination_mat1
rmse_multivariate_mat1
rmse_forecast_combination_mat2
rmse_pc_mat1
rmse_forecast_combination_mat3
rmse_varmat2
rmse_nochangemat1];



table2_tex = tablelatex(table2,columnlabels,rowlabels);
char(table2_tex)



% Table 3 -- Short sample + measures of competition
[rmse_forecast_combination_mat1, forecast_combination_mat1] = calc_rmse_forecast_combination_conditional(nims(:,15:end),[yields(:,15:end);shadow_bank_share_assets(:,15:end)], out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);

[rmse_multivariate_mat1, forecast_multivariate_mat1] = calc_rmse_multivariate_conditional(nims(:,15:end), [smoothed_factors(:,15:end);shadow_bank_share_assets(:,15:end)], out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, lag);
[rmse_forecast_combination_mat2, forecast_combination_mat2] = calc_rmse_forecast_combination_conditional(nims(:,15:end),[smoothed_factors(:,15:end);shadow_bank_share_assets(:,15:end)], out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);


npc = 4;
[rmse_pc_mat1, forecast_pc_mat1] = calc_rmse_pc(nims(:,15:end), [yields(:,15:end); shadow_bank_share_assets(:,15:end)] , out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, npc);

npls = 5;
[rmse_pls_mat1, forecast_pls_mat1] = calc_rmse_pls_conditional(nims(:,15:end), [yields(:,15:end); shadow_bank_share_assets(:,15:end)], out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, npls);


[rmse_forecast_combination_mat3, forecast_combination_mat3] = calc_rmse_forecast_combination_conditional(nims(:,15:end),[factors(:,15:end) ;shadow_bank_share_assets(:,15:end)], out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);

varlag=3;
[rmse_varmat1, forecast_var_mat1] = calc_rmse_var_conditional(nims(:,15:end), [smoothed_factors(:,15:end);shadow_bank_share_assets(:,15:end)], out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, varlag);
[rmse_varmat2, forecast_var_mat2] = calc_rmse_var_conditional(nims(:,15:end), [factors(:,15:end);shadow_bank_share_assets(:,15:end)], out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, varlag);
[rmse_nochangemat1, forecast_nochange_mat1] = calc_rmse_nochange(nims(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon);



table3 = [
rmse_forecast_combination_mat1
rmse_multivariate_mat1
rmse_forecast_combination_mat2
rmse_pc_mat1
rmse_pls_mat1
rmse_forecast_combination_mat3
rmse_varmat2
rmse_nochangemat1];


table3_tex = tablelatex(table3,columnlabels,rowlabels);
char(table3_tex)



% Determine which forecast combination is best in RMSE
[rmse_forecast_combination_mat0, forecast_combination_mat0] = calc_rmse_forecast_combination_conditional(nims(:,15:end), yields(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);
[rmse_forecast_combination_mat1, forecast_combination_mat1] = calc_rmse_forecast_combination_conditional(nims(:,15:end), factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);
[rmse_forecast_combination_mat2, forecast_combination_mat1] = calc_rmse_forecast_combination_conditional(nims(:,15:end), smoothed_factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);
[rmse_forecast_combination_mat3, forecast_combination_mat1] = calc_rmse_forecast_combination_conditional(nims(:,15:end),yields([find(tau==3),find(tau==24),find(tau==120)],15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);
[rmse_forecast_combination_mat4, forecast_combination_mat1] = calc_rmse_forecast_combination_conditional(nims(:,15:end),yields([find(tau==3),find(tau==120)],15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, 1,4);

table4 = [rmse_forecast_combination_mat0
          rmse_forecast_combination_mat1
          rmse_forecast_combination_mat2
          rmse_forecast_combination_mat3
          rmse_forecast_combination_mat4
          ];

rowlabels = char('All yields',...
                 'Observed Factors',...
                 'Smoothed Factors',...
                 '3-month, 2-year, 10-year',...
                 '3-month, 10-year');
      
table4_tex = tablelatex(table4,columnlabels,rowlabels);
char(table4_tex)


% additional tests
lag = 1;
[rmse_multivariate_mat1, forecast_multivariate_mat1] = calc_rmse_multivariate_conditional(nims(:,15:end), factors(:,15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, lag);
[rmse_multivariate_mat2, forecast_multivariate_mat1] = calc_rmse_multivariate_conditional(nims(:,15:end), yields([find(tau==3),find(tau==24),find(tau==120)],15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, lag);
[rmse_multivariate_mat3, forecast_multivariate_mat1] = calc_rmse_multivariate_conditional(nims(:,15:end), yields([find(tau==3),find(tau==120)],15:end), out_of_sample_start_pos-14, end_sample_pos-14, forecast_horizon, lag);


table5 = [rmse_multivariate_mat1 
          rmse_multivariate_mat2
          rmse_multivariate_mat3]




figure
subplot(2,1,1)
thistitle='Nims (solid) and 3-Month Yields (dashed)';
doubleplot(nims,yields(1,:),dates,thistitle)

subplot(2,1,2)
thistitle='Nims (solid) and 10-Year Yields (dashed)';
doubleplot(nims,yields(9,:),dates,thistitle)


figure
subplot(3,1,1)
thistitle='Nims (solid) and Observed Level Factor (dashed)';
doubleplot(nims,factors(1,:),dates,thistitle)


subplot(3,1,2)
thistitle='Nims (solid) and Observed Slope Factor (dashed)';
doubleplot(nims,factors(2,:),dates,thistitle)

subplot(3,1,3)
thistitle='Nims (solid) and Observed Curvature Factor (dashed)';
doubleplot(nims,factors(3,:),dates,thistitle)


figure
thistitle='Nims (solid) and Asset Share of Shadow Banking Sector (dashed)';
doubleplot(nims,shadow_bank_share_assets,dates,thistitle)
xlim([dates(1) dates(end)])

figure
thistitle = 'Interest Income (% of i.e. assets), Interest Expenses (% of i.e. assets) and the 3-month Treasury yield (RHS scale)'; 
tripleplot(interest_income_to_ie_assets, interest_expense_to_ie_assets, yields(1,:),dates,thistitle)