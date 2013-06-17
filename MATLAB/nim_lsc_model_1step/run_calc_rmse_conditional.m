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

% get the smoothed estimates of the factors
[yobs, dates, yields, nims, nfactors, nothers, tau, factors,  shadow_bank_share_assets] = load_data_ml;
forecast_horizon = 10;

[f, q, r, x, a, lambda, h, xi_means, error] = kalmanFilterSetup(param_vec,tau,nfactors,nothers);

[logLikel,errcode,xi1tHistory]= ...
    kalmanFilterSmoother_v2(f, h, yobs, a, x, xi10_demeaned, p10, q, r, ntrain);  

smoothed_factors = xi1tHistory(1:3,:);

lag = 1;


[rmse_nochangemat, forecast_nochange_mat1] = calc_rmse_nochange(nims, out_of_sample_start_pos, end_sample_pos, forecast_horizon);


plotbool = 0;                                   
[rmse_mlmat, forecast_ml_mat1] = calc_rmse_ml_conditional(opt_param_mat, out_of_sample_start_pos, end_sample_pos, yobs, xi10_demeaned, p10, ntrain, tau, nfactors, nothers, forecast_horizon, dates,plotbool);

columnlabels = char('Step 1','Step 2','Step 3','Step 4','Step 5','Step 6','Step 7','Step 8','Step 9','Step 10');
rowlabels = char('DFM');
table1_tex = tablelatex(rmse_mlmat,columnlabels,rowlabels);
char(table1_tex)


for i = 1:forecast_horizon
   figure
   plot(dates(15:end),nims(end,15:end),'k','lineWidth',2)
   hold on
   plot(dates(out_of_sample_start_pos+i-1:end),forecast_ml_mat1(1:end-i+1,i)','b--','lineWidth',2)
   plot(dates(out_of_sample_start_pos+i-1:end),forecast_nochange_mat1(1:end-i+1,i)','r:','lineWidth',2)
   
   for j = out_of_sample_start_pos+i-1:end_sample_pos
       if abs(forecast_ml_mat1(j-out_of_sample_start_pos-i+2,i)'-yobs(end,j))<=abs(forecast_nochange_mat1(j-out_of_sample_start_pos-i+2,i)'-nims(j))
           plot(dates(j),nims(j),'bo','lineWidth',2)
       else
           plot(dates(j),nims(j),'rx','lineWidth',2)
       end
   end
   legend('Data','Dynamic Factor Model','No-change forecast','Location','SouthWest')
   title(['Assessing the ',num2str(i),'-step-ahead forecast'])
   
   xlim([dates(15) dates(end)])
end