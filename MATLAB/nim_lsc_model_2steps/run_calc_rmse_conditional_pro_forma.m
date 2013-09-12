
clear;

setpath;


dataset_option = 1;
sample_start = 1989.25; %1996;
sample_end = 2008.25; %2013;
    
[yobs, dates, yields, nims, nfactors, nothers, tau, factors,...
    shadow_bank_share_assets,...
    total_interest_earning_assets,...
    assets_depository_inst, assets_securities_notrade,...
    assets_fedfunds, assets_all_loans, assets_trading_accnts, ... 
    interest_income_to_ie_assets, interest_expense_to_ie_assets] = load_data_ml(dataset_option,sample_end,sample_start);
 

% get list of banks
pro_forma_data_info = load_pro_forma_data;

bank_ids = pro_forma_data_info{1};
bank_names = pro_forma_data_info{2};

% overwrite nims with bank-specific data
%bank_data= load_pro_forma_data(bank_ids(1));
%nims = bank_data{1};


out_of_sample_start_pos = find(dates==2000);
end_sample_pos = length(dates);

nstates = nfactors + nothers;
ntaus = length(tau);

forecast_horizon = 10;



%% get RMSEs
lag = 1;

% Table 1 -- Shortened sample:
[rmse_forecast_combination_mat1, forecast_combination_mat1,...
 forecast_combination_errors_mat1 insample_forecast_combination_errors_mat1] = calc_rmse_forecast_combination_conditional(nims,yields, out_of_sample_start_pos, end_sample_pos, forecast_horizon, 1,4);

[rmse_forecast_combination_rolling_mat1, forecast_combination_rolling_mat1,...
 forecast_combination_errors_rolling_mat1 insample_forecast_combination_errors_rolling_mat1] = calc_rmse_forecast_combination_conditional_rolling(nims,yields, out_of_sample_start_pos, end_sample_pos, forecast_horizon, 1,4);


npc = 3;
[rmse_pc_mat1, forecast_pc_mat1,...
    pc_forecast_errors_mat] = calc_rmse_pc(nims, yields, out_of_sample_start_pos, end_sample_pos, forecast_horizon, npc);
[rmse_pc_rolling_mat1, forecast_pc_rolling_mat1,...
    pc_forecast_errors_rolling_mat, insample_pc_forecast_errors_rolling_mat] = calc_rmse_pc_rolling(nims, yields, out_of_sample_start_pos, end_sample_pos, forecast_horizon, npc);

npls = 3;
[rmse_pls_mat1, forecast_pls_mat1,...
    pls_forecast_errors_mat] = calc_rmse_pls_conditional(nims, yields, out_of_sample_start_pos, end_sample_pos, forecast_horizon, npls);
[rmse_pls_rolling_mat1, forecast_pls_rolling_mat1, ...
    pls_forecast_errors_rolling_mat, insample_pls_forecast_errors_rolling_mat] = ...
    calc_rmse_pls_conditional_rolling(nims, yields, ...
    out_of_sample_start_pos, end_sample_pos, forecast_horizon, npls);


[rmse_forecast_combination_mat3, forecast_combination_mat3,...
    forecast_combination_errors_mat3] = calc_rmse_forecast_combination_conditional(nims,factors, out_of_sample_start_pos, end_sample_pos, forecast_horizon, 1,4);
[rmse_forecast_combination_rolling_mat3, forecast_combination_rolling_mat3,...
    forecast_combination_errors_rolling_mat3 insample_forecast_combination_errors_rolling_mat3] = calc_rmse_forecast_combination_conditional_rolling(nims,factors, out_of_sample_start_pos, end_sample_pos, forecast_horizon, 1,4);

varlag=4;
[rmse_var_mat2, forecast_var_mat2, var_forecast_errors_mat2] = calc_rmse_var_conditional(nims, factors, out_of_sample_start_pos, end_sample_pos, forecast_horizon, varlag);
[rmse_var_rolling_mat2, forecast_var_rolling_mat2,...
    var_forecast_errors_rolling_mat2 insample_var_forecast_errors_rolling_mat2] = calc_rmse_var_conditional_rolling(nims, factors, out_of_sample_start_pos, end_sample_pos, forecast_horizon, varlag);


[rmse_nochange_mat1, forecast_nochange_mat1, forecast_errors_nochange_mat, insample_forecast_errors_nochange_mat] = calc_rmse_nochange(nims, out_of_sample_start_pos, end_sample_pos, forecast_horizon);



% Run the RS test on all models
RLout = forecast_combination_errors_mat1(:,1).^2-forecast_errors_nochange_mat(:,1).^2;
RLin = insample_forecast_combination_errors_mat1.^2 - insample_forecast_errors_nochange_mat.^2;
qn = floor(size(forecast_combination_errors_mat1,1)^(1/4));
m = 4;


% run the Diebold Mariano West test on all horizons for the rolling
% regressions
error_type_list = char('forecast_combination_errors_rolling_mat1',...
               'pc_forecast_errors_rolling_mat',...
               'pls_forecast_errors_rolling_mat',...
               'forecast_combination_errors_rolling_mat3',...
               'var_forecast_errors_rolling_mat2');
           
n_error_types = size(error_type_list,1);

DMW_mat = nan*ones(n_error_types,forecast_horizon);
DMW_sig_mat = DMW_mat;

for this_error=1:n_error_types
    for this_horizon = 1:forecast_horizon
        eval(['[DMW_mat(this_error,this_horizon),DMW_sig_mat(this_error,this_horizon)]=dmw_test(',deblank(error_type_list(this_error,:)),'(1:end-(this_horizon-1),this_horizon),forecast_errors_nochange_mat(1:end-(this_horizon-1),this_horizon),this_horizon+1,0.05);'])                                
    end
end


rowlabels_test = char('1. F. Combination - Yields',...
                 '4. PCR',...
                 '5. PLS',...
                 '6. F. Combination - Observed Factors',...
                 '7. VAR on Observed Factors');

columnlabels = char('Step 1','Step 2','Step 3','Step 4','Step 5','Step 6','Step 7','Step 8','Step 9','Step 10');
dmw_test_table_tex = table_dmw_latex(DMW_mat,DMW_sig_mat,columnlabels,rowlabels_test);

char(dmw_test_table_tex)





% run the Diebold Mariano West test on all horizons using recursive
% windows
error_type_list = char('forecast_combination_errors_mat1',...
               'pc_forecast_errors_mat',...
               'pls_forecast_errors_mat',...
               'forecast_combination_errors_mat3',...
               'var_forecast_errors_mat2');
           
n_error_types = size(error_type_list,1);

DMW_mat = nan*ones(n_error_types,forecast_horizon);
DMW_sig_mat = DMW_mat;

for this_error=1:n_error_types
    for this_horizon = 1:forecast_horizon
        eval(['[DMW_mat(this_error,this_horizon),DMW_sig_mat(this_error,this_horizon)]=dmw_test(',deblank(error_type_list(this_error,:)),'(1:end-(this_horizon-1),this_horizon),forecast_errors_nochange_mat(1:end-(this_horizon-1),this_horizon),this_horizon+1,0.05);'])                                
    end
end


rowlabels_test = char('1. F. Combination - Yields',...
                 '4. PCR',...
                 '5. PLS',...
                 '6. F. Combination - Observed Factors',...
                 '7. VAR on Observed Factors');

columnlabels = char('Step 1','Step 2','Step 3','Step 4','Step 5','Step 6','Step 7','Step 8','Step 9','Step 10');
dmw_test_table_tex = table_dmw_latex(DMW_mat,DMW_sig_mat,columnlabels,rowlabels_test);

char(dmw_test_table_tex)




% now run Barbara's test

test_results = run_rs_tests(forecast_combination_errors_rolling_mat1(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_forecast_combination_errors_rolling_mat1,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table = [test_results];


test_results = run_rs_tests(pc_forecast_errors_rolling_mat(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_pc_forecast_errors_rolling_mat,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table = [test_table; test_results]; 

test_results = run_rs_tests(pls_forecast_errors_rolling_mat(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_pls_forecast_errors_rolling_mat,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table = [test_table; test_results]; 

test_results = run_rs_tests(forecast_combination_errors_rolling_mat3(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_forecast_combination_errors_rolling_mat3,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table = [test_table; test_results];     
                      
test_results = run_rs_tests(var_forecast_errors_rolling_mat2(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_var_forecast_errors_rolling_mat2,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table = [test_table; test_results];                             


%%%%%%%%%%%%%%%%%%%%
% now repeat test for different m

m = 12;

test_results = run_rs_tests(forecast_combination_errors_rolling_mat1(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_forecast_combination_errors_rolling_mat1,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table2 = [test_results];

test_results = run_rs_tests(pc_forecast_errors_rolling_mat(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_pc_forecast_errors_rolling_mat,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table2 = [test_table2; test_results];  

test_results = run_rs_tests(pls_forecast_errors_rolling_mat(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_pls_forecast_errors_rolling_mat,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table2 = [test_table2; test_results];  

test_results = run_rs_tests(forecast_combination_errors_rolling_mat3(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_forecast_combination_errors_rolling_mat3,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table2 = [test_table2; test_results];     
                      
test_results = run_rs_tests(var_forecast_errors_rolling_mat2(:,1),...
                            forecast_errors_nochange_mat(:,1),...
                            insample_var_forecast_errors_rolling_mat2,...
                            insample_forecast_errors_nochange_mat,...
                            qn,m);
test_table2 = [test_table2; test_results];                             

columnlabels_test = char('m = 4', 'm=12');
test_table_tex =tablelatex_testresults([test_table test_table2],columnlabels_test,rowlabels_test)

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
rmse_pc_mat1
rmse_pls_mat1
rmse_forecast_combination_mat3
rmse_var_mat2
rmse_nochange_mat1]




columnlabels = char('Step 1','Step 2','Step 3','Step 4','Step 5','Step 6','Step 7','Step 8','Step 9','Step 10');
rowlabels = char('1. F. Combination - Yields',...
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
rmse_pc_rolling_mat1
rmse_pls_rolling_mat1
rmse_forecast_combination_rolling_mat3
rmse_var_rolling_mat2
rmse_nochange_mat1]




columnlabels = char('Step 1','Step 2','Step 3','Step 4','Step 5','Step 6','Step 7','Step 8','Step 9','Step 10');
rowlabels_rolling = char('1. F. Combination - Yields',...
                 '4. PCR',...
                 '5. PLS',...
                 '6. F. Combination - Observed Factors',...
                 '7. VAR on Observed Factors',...
                 '8. No-Change Forecast');
table1_rolling_tex = tablelatex(table1_rolling,columnlabels,rowlabels_rolling);
char(table1_rolling_tex)


figure
subplot_index = 0;
horizon_plot_list = [1, 4, 10];
n_horizon_plot = length(horizon_plot_list);
for i = horizon_plot_list
   subplot_index = subplot_index+1;
   subplot(n_horizon_plot,1,subplot_index)
   plot(dates(15:end),nims(end,15:end),'k','lineWidth',2)
   hold on
   plot(dates(out_of_sample_start_pos+i-1:end),forecast_combination_mat1(1:end-i+1,i)','b--','lineWidth',2)
   plot(dates(out_of_sample_start_pos+i-1:end),forecast_nochange_mat1(1:end-i+1,i)','r:','lineWidth',2)
   
   for j = out_of_sample_start_pos+i-1:end_sample_pos
       if abs(forecast_combination_mat1(j-out_of_sample_start_pos-i+2,i)-nims(j))<=abs(forecast_nochange_mat1(j-out_of_sample_start_pos-i+2,i)-nims(j))
           plot(dates(j),nims(j),'bo','lineWidth',2)
       else
           plot(dates(j),nims(j),'rx','lineWidth',2)
       end
   end
   if subplot_index ==1
   legend('Data','Forecast Combination','No-change forecast')
   end
   title(['Assessing the ',num2str(i),'-step-ahead forecast'])
   
   xlim([dates(35) dates(end)])
end




