% This is an old copy that needs to be updated. -- Copy again from 1step
% directory and update for 2step procedure.



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

[rmse_mlmat rmse_varmat rmse_nochangemat ml_forecasts nochange_forecasts] = calc_rmse_conditional(opt_param_mat, out_of_sample_start_pos, end_sample_pos, yobs, factors, xi10_demeaned, p10, ntrain, tau, nfactors, nothers, forecast_horizon, dates);
for i = 1:forecast_horizon
   figure
   plot(dates,yobs(end,:),'k','lineWidth',2)
   hold on
   plot(dates(out_of_sample_start_pos+i-1:end),ml_forecasts(i,1:end-i+1),'b--','lineWidth',2)
   plot(dates(out_of_sample_start_pos+i-1:end),nochange_forecasts(i,1:end-i+1),'r:','lineWidth',2)
   
   for j = out_of_sample_start_pos+i-1:end_sample_pos
       if abs(ml_forecasts(i,j-out_of_sample_start_pos-i+2)-yobs(end,j))<=abs(nochange_forecasts(i,j-out_of_sample_start_pos-i+2)-yobs(end,j))
           plot(dates(j),yobs(end,j),'bo','lineWidth',2)
       else
           plot(dates(j),yobs(end,j),'rx','lineWidth',2)
       end
   end
   legend('Data','Forecast from DFM','No-change forecast')
   title(['Assessing the ',num2str(i),'-step-ahead forecast'])
   
   xlim([dates(1) dates(end)])
end

