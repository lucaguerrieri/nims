
clear;

setpath;


dataset_option = 1;
sample_start = 1996; %1989.25; %1996;
sample_end = 2013; %2008.25; %2013;
    
[yobs, dates, yields, nims, nfactors, nothers, tau, factors,...
    shadow_bank_share_assets,...
    total_interest_earning_assets,...
    assets_depository_inst, assets_securities_notrade,...
    assets_fedfunds, assets_all_loans, assets_trading_accnts, ... 
    interest_income_to_ie_assets, interest_expense_to_ie_assets] = load_data_ml(dataset_option,sample_end,sample_start);
 

out_of_sample_start_pos = find(dates==2007.75);
end_sample_pos = length(dates);

nstates = nfactors + nothers;
ntaus = length(tau);

forecast_horizon = 10;

% get list of banks
pro_forma_data_info = load_pro_forma_data;

bank_ids = pro_forma_data_info{1};
bank_names = pro_forma_data_info{2};

nbanks = length(bank_ids);

bank_rmse_forecast_combination_recursive = nan*ones(nbanks,forecast_horizon);
bank_dmw_forecast_combination_recursive = nan*ones(nbanks,forecast_horizon);
bank_dmw_sig_forecast_combination_recursive = nan*ones(nbanks,forecast_horizon);

bank_rmse_forecast_combination_rolling = nan*ones(nbanks,forecast_horizon);
bank_dmw_forecast_combination_rolling = nan*ones(nbanks,forecast_horizon);
bank_dmw_sig_forecast_combination_rolling = nan*ones(nbanks,forecast_horizon);


bank_rmse_pcr_recursive = nan*ones(nbanks,forecast_horizon);
bank_dmw_pcr_recursive = nan*ones(nbanks,forecast_horizon);
bank_dmw_sig_pcr_recursive = nan*ones(nbanks,forecast_horizon);

bank_rmse_pcr_rolling = nan*ones(nbanks,forecast_horizon);
bank_dmw_pcr_rolling = nan*ones(nbanks,forecast_horizon);
bank_dmw_sig_pcr_rolling = nan*ones(nbanks,forecast_horizon);


bank_rmse_pls_recursive = nan*ones(nbanks,forecast_horizon);
bank_dmw_pls_recursive = nan*ones(nbanks,forecast_horizon);
bank_dmw_sig_pls_recursive = nan*ones(nbanks,forecast_horizon);


bank_rmse_pls_rolling = nan*ones(nbanks,forecast_horizon);
bank_dmw_pls_rolling = nan*ones(nbanks,forecast_horizon);
bank_dmw_sig_pls_rolling = nan*ones(nbanks,forecast_horizon);



bank_rmse_no_change = nan*ones(nbanks,forecast_horizon);


for this_bank = 1:nbanks

% overwrite nims with bank-specific data
bank_data= load_pro_forma_data(bank_ids(this_bank));
nims = bank_data{1};



%% get RMSEs
lag = 1;

% Table 1 -- Shortened sample:
[rmse_forecast_combination_mat1, forecast_combination_mat1,...
 forecast_combination_errors_mat1 insample_forecast_combination_errors_mat1] = calc_rmse_forecast_combination_conditional(nims,yields, out_of_sample_start_pos, end_sample_pos, forecast_horizon, 1,4);
bank_rmse_forecast_combination_recursive(this_bank,:)=rmse_forecast_combination_mat1;


[rmse_forecast_combination_rolling_mat1, forecast_combination_rolling_mat1,...
 forecast_combination_errors_rolling_mat1 insample_forecast_combination_errors_rolling_mat1] = calc_rmse_forecast_combination_conditional_rolling(nims,yields, out_of_sample_start_pos, end_sample_pos, forecast_horizon, 1,4);
bank_rmse_forecast_combination_rolling(this_bank,:) = rmse_forecast_combination_rolling_mat1;

npc = 3;
[rmse_pc_mat1, forecast_pc_mat1,...
    pc_forecast_errors_mat] = calc_rmse_pc(nims, yields, out_of_sample_start_pos, end_sample_pos, forecast_horizon, npc);
bank_rmse_pcr_recursive(this_bank,:) = rmse_pc_mat1;

[rmse_pc_rolling_mat1, forecast_pc_rolling_mat1,...
    pc_forecast_errors_rolling_mat, insample_pc_forecast_errors_rolling_mat] = calc_rmse_pc_rolling(nims, yields, out_of_sample_start_pos, end_sample_pos, forecast_horizon, npc);
bank_rmse_pcr_rolling(this_bank,:) = rmse_pc_rolling_mat1;

npls = 3;
[rmse_pls_mat1, forecast_pls_mat1,...
    pls_forecast_errors_mat] = calc_rmse_pls_conditional(nims, yields, out_of_sample_start_pos, end_sample_pos, forecast_horizon, npls);
bank_rmse_pls_recursive(this_bank,:)=rmse_pls_mat1;

[rmse_pls_rolling_mat1, forecast_pls_rolling_mat1, ...
    pls_forecast_errors_rolling_mat, insample_pls_forecast_errors_rolling_mat] = ...
    calc_rmse_pls_conditional_rolling(nims, yields, ...
    out_of_sample_start_pos, end_sample_pos, forecast_horizon, npls);
bank_rmse_pls_rolling(this_bank,:)=rmse_pls_rolling_mat1;



[rmse_nochange_mat1, forecast_nochange_mat1, forecast_errors_nochange_mat, insample_forecast_errors_nochange_mat] = calc_rmse_nochange(nims, out_of_sample_start_pos, end_sample_pos, forecast_horizon);
bank_rmse_no_change(this_bank,:)=rmse_nochange_mat1;


% Run the RS test on all models
RLout = forecast_combination_errors_mat1(:,1).^2-forecast_errors_nochange_mat(:,1).^2;
RLin = insample_forecast_combination_errors_mat1.^2 - insample_forecast_errors_nochange_mat.^2;
qn = floor(size(forecast_combination_errors_mat1,1)^(1/4));
m = 4;


% run the Diebold Mariano West test on all horizons for the rolling
% regressions
error_type_list = char('forecast_combination_errors_rolling_mat1',...
               'pc_forecast_errors_rolling_mat',...
               'pls_forecast_errors_rolling_mat');
           
n_error_types = size(error_type_list,1);

DMW_mat = nan*ones(n_error_types,forecast_horizon);
DMW_sig_mat = DMW_mat;

for this_error=1:n_error_types
    for this_horizon = 1:forecast_horizon
        eval(['[DMW_mat(this_error,this_horizon),DMW_sig_mat(this_error,this_horizon)]=dmw_test(',deblank(error_type_list(this_error,:)),'(1:end-(this_horizon-1),this_horizon),forecast_errors_nochange_mat(1:end-(this_horizon-1),this_horizon),this_horizon+1,0.05);'])                                
    end
end


% rowlabels_test = char('1. F. Combination - Yields',...
%                  '4. PCR',...
%                  '5. PLS');
% 
% columnlabels = char('Step 1','Step 2','Step 3','Step 4','Step 5','Step 6','Step 7','Step 8','Step 9','Step 10');
%dmw_test_table_tex = table_dmw_latex(DMW_mat,DMW_sig_mat,columnlabels,rowlabels_test);
%char(dmw_test_table_tex)

bank_dmw_forecast_combination_rolling(this_bank,:) = DMW_mat(1,:);
bank_dmw_pcr_rolling(this_bank,:) = DMW_mat(2,:);
bank_dmw_pls_rolling(this_bank,:) = DMW_mat(3,:);

bank_dmw_sig_forecast_combination_rolling(this_bank,:) = DMW_sig_mat(1,:);
bank_dmw_sig_pcr_rolling(this_bank,:) = DMW_sig_mat(2,:);
bank_dmw_sig_pls_rolling(this_bank,:) = DMW_sig_mat(3,:);







% run the Diebold Mariano West test on all horizons using recursive
% windows
error_type_list = char('forecast_combination_errors_mat1',...
               'pc_forecast_errors_mat',...
               'pls_forecast_errors_mat');
           
n_error_types = size(error_type_list,1);

DMW_mat = nan*ones(n_error_types,forecast_horizon);
DMW_sig_mat = DMW_mat;

for this_error=1:n_error_types
    for this_horizon = 1:forecast_horizon
        eval(['[DMW_mat(this_error,this_horizon),DMW_sig_mat(this_error,this_horizon)]=dmw_test(',deblank(error_type_list(this_error,:)),'(1:end-(this_horizon-1),this_horizon),forecast_errors_nochange_mat(1:end-(this_horizon-1),this_horizon),this_horizon+1,0.05);'])                                
    end
end

bank_dmw_forecast_combination_recursive(this_bank,:) = DMW_mat(1,:);
bank_dmw_pcr_recursive(this_bank,:) = DMW_mat(2,:);
bank_dmw_pls_recursive(this_bank,:) = DMW_mat(3,:);

bank_dmw_sig_forecast_combination_recursive(this_bank,:) = DMW_sig_mat(1,:);
bank_dmw_sig_pcr_recursive(this_bank,:) = DMW_sig_mat(2,:);
bank_dmw_sig_pls_recursive(this_bank,:) = DMW_sig_mat(3,:);


% rowlabels_test = char('1. F. Combination - Yields',...
%                  '4. PCR',...
%                  '5. PLS');
% 
% columnlabels = char('Step 1','Step 2','Step 3','Step 4','Step 5','Step 6','Step 7','Step 8','Step 9','Step 10');
% dmw_test_table_tex = table_dmw_latex(DMW_mat,DMW_sig_mat,columnlabels,rowlabels_test);
% char(dmw_test_table_tex)




% now run Barbara's test
% 
% test_results = run_rs_tests(forecast_combination_errors_rolling_mat1(:,1),...
%                             forecast_errors_nochange_mat(:,1),...
%                             insample_forecast_combination_errors_rolling_mat1,...
%                             insample_forecast_errors_nochange_mat,...
%                             qn,m);
% test_table = [test_results];
% 
% 
% test_results = run_rs_tests(pc_forecast_errors_rolling_mat(:,1),...
%                             forecast_errors_nochange_mat(:,1),...
%                             insample_pc_forecast_errors_rolling_mat,...
%                             insample_forecast_errors_nochange_mat,...
%                             qn,m);
% test_table = [test_table; test_results]; 
% 
% test_results = run_rs_tests(pls_forecast_errors_rolling_mat(:,1),...
%                             forecast_errors_nochange_mat(:,1),...
%                             insample_pls_forecast_errors_rolling_mat,...
%                             insample_forecast_errors_nochange_mat,...
%                             qn,m);
% test_table = [test_table; test_results]; 
% 
% test_results = run_rs_tests(forecast_combination_errors_rolling_mat3(:,1),...
%                             forecast_errors_nochange_mat(:,1),...
%                             insample_forecast_combination_errors_rolling_mat3,...
%                             insample_forecast_errors_nochange_mat,...
%                             qn,m);
% test_table = [test_table; test_results];     
%                       
% test_results = run_rs_tests(var_forecast_errors_rolling_mat2(:,1),...
%                             forecast_errors_nochange_mat(:,1),...
%                             insample_var_forecast_errors_rolling_mat2,...
%                             insample_forecast_errors_nochange_mat,...
%                             qn,m);
% test_table = [test_table; test_results];                             
% 
% 
% %%%%%%%%%%%%%%%%%%%%
% % now repeat test for different m
% 
% m = 12;
% 
% test_results = run_rs_tests(forecast_combination_errors_rolling_mat1(:,1),...
%                             forecast_errors_nochange_mat(:,1),...
%                             insample_forecast_combination_errors_rolling_mat1,...
%                             insample_forecast_errors_nochange_mat,...
%                             qn,m);
% test_table2 = [test_results];
% 
% test_results = run_rs_tests(pc_forecast_errors_rolling_mat(:,1),...
%                             forecast_errors_nochange_mat(:,1),...
%                             insample_pc_forecast_errors_rolling_mat,...
%                             insample_forecast_errors_nochange_mat,...
%                             qn,m);
% test_table2 = [test_table2; test_results];  
% 
% test_results = run_rs_tests(pls_forecast_errors_rolling_mat(:,1),...
%                             forecast_errors_nochange_mat(:,1),...
%                             insample_pls_forecast_errors_rolling_mat,...
%                             insample_forecast_errors_nochange_mat,...
%                             qn,m);
% test_table2 = [test_table2; test_results];  
% 
% test_results = run_rs_tests(forecast_combination_errors_rolling_mat3(:,1),...
%                             forecast_errors_nochange_mat(:,1),...
%                             insample_forecast_combination_errors_rolling_mat3,...
%                             insample_forecast_errors_nochange_mat,...
%                             qn,m);
% test_table2 = [test_table2; test_results];     
%                       
% test_results = run_rs_tests(var_forecast_errors_rolling_mat2(:,1),...
%                             forecast_errors_nochange_mat(:,1),...
%                             insample_var_forecast_errors_rolling_mat2,...
%                             insample_forecast_errors_nochange_mat,...
%                             qn,m);
% test_table2 = [test_table2; test_results];                             
% 
% columnlabels_test = char('m = 4', 'm=12');
% test_table_tex =tablelatex_testresults([test_table test_table2],columnlabels_test,rowlabels_test)
% 
% char(test_table_tex)







end




%%
columnlabels = char('Step 1','Step 2','Step 4','Step 6','Step 8','Step 10');

% forecast combination - recursive
table_rmse_forecast_combination_recursive = tablelatex(bank_rmse_forecast_combination_recursive(:,[1,2,4,6,8,10])-bank_rmse_no_change(:,[1,2,4,6,8,10]),columnlabels,bank_names);
char(table_rmse_forecast_combination_recursive)
dmw_test_table_tex = table_dmw_latex(bank_dmw_forecast_combination_recursive(:,[1,2,4,6,8,10]),bank_dmw_sig_forecast_combination_recursive(:,[1,2,4,6,8,10]),columnlabels,bank_names);
char(dmw_test_table_tex)

% forecast combination - rolling
table_rmse_forecast_combination_rolling = tablelatex(bank_rmse_forecast_combination_rolling(:,[1,2,4,6,8,10])-bank_rmse_no_change(:,[1,2,4,6,8,10]),columnlabels,bank_names);
char(table_rmse_forecast_combination_rolling)
dmw_test_table_tex = table_dmw_latex(bank_dmw_forecast_combination_rolling(:,[1,2,4,6,8,10]),bank_dmw_sig_forecast_combination_rolling(:,[1,2,4,6,8,10]),columnlabels,bank_names);
char(dmw_test_table_tex)

% pcr - recursive
table_rmse_pcr = tablelatex(bank_rmse_pcr_recursive(:,[1,2,4,6,8,10])-bank_rmse_no_change(:,[1,2,4,6,8,10]),columnlabels,bank_names);
char(table_rmse_pcr)
dmw_test_table_tex = table_dmw_latex(bank_dmw_pcr_recursive(:,[1,2,4,6,8,10]),bank_dmw_sig_pcr_recursive(:,[1,2,4,6,8,10]),columnlabels,bank_names);
char(dmw_test_table_tex)

% pcr - rolling
table_rmse_pcr = tablelatex(bank_rmse_pcr_rolling(:,[1,2,4,6,8,10])-bank_rmse_no_change(:,[1,2,4,6,8,10]),columnlabels,bank_names);
char(table_rmse_pcr)
dmw_test_table_tex = table_dmw_latex(bank_dmw_pcr_rolling(:,[1,2,4,6,8,10]),bank_dmw_sig_pcr_rolling(:,[1,2,4,6,8,10]),columnlabels,bank_names);
char(dmw_test_table_tex)


% pls - recursive
table_rmse_pls = tablelatex(bank_rmse_pls_recursive(:,[1,2,4,6,8,10])-bank_rmse_no_change(:,[1,2,4,6,8,10]),columnlabels,bank_names);
char(table_rmse_pls)
dmw_test_table_tex = table_dmw_latex(bank_dmw_pls_recursive(:,[1,2,4,6,8,10]),bank_dmw_sig_pls_recursive(:,[1,2,4,6,8,10]),columnlabels,bank_names);
char(dmw_test_table_tex)

% pls - rolling
table_rmse_pls = tablelatex(bank_rmse_pls_rolling(:,[1,2,4,6,8,10])-bank_rmse_no_change(:,[1,2,4,6,8,10]),columnlabels,bank_names);
char(table_rmse_pls)
dmw_test_table_tex = table_dmw_latex(bank_dmw_pls_rolling(:,[1,2,4,6,8,10]),bank_dmw_sig_pls_rolling(:,[1,2,4,6,8,10]),columnlabels,bank_names);
char(dmw_test_table_tex)


% Aggregate Table For 1-step ahead forecast

columnlabels = char('1. F. Comb','4. PCR','5. PLS','1. F. Comb','4. PCR','5. PLS','8. No Change','SNL')

table_mat = [bank_rmse_forecast_combination_recursive(:,1),...
             bank_rmse_pcr_recursive(:,1),...
             bank_rmse_pls_recursive(:,1)...
             bank_rmse_forecast_combination_rolling(:,1),...
             bank_rmse_pcr_rolling(:,1),...
             bank_rmse_pls_rolling(:,1),...
             bank_rmse_no_change(:,1),...
             0*bank_rmse_pls_rolling(:,1)];
table_mat = tablelatex(table_mat,columnlabels,bank_names);
char(table_mat)
         
    

