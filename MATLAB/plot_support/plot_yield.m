function plot_yield(param_vec,tau,nfactors,nothers,yobs,ntrain,xi10_demeaned,p10,dates,factor1,factor2,factor3)

[f, q, r, x, a, lambda, h, xi_means, error] = kalmanFilterSetup(param_vec,tau,nfactors,nothers);

[logLikel,errcode,xi1tHistory]= ...
    kalmanFilterSmoother_v2(f, h, yobs, a, x, xi10_demeaned, p10, q, r, ntrain);  

%t = find(dates==1990.25);

yields = yobs(1:end-nothers,:);

figure 
tau_grid = 3:360;
for tindx = 1:8
    t = 15+tindx*6; 
  subplot(4,2,tindx)
plot(tau_grid, yield_calc(tau_grid, lambda, xi_means(1:end-nothers), xi1tHistory(1:end-nothers,t))); %xi1tHistory(:,t)
hold on
plot(tau, yields(:,t), 'o')
title(['Yield Curve in ',num2str(dates(t))])
  
end



figure
subplot(3,1,1)
plot(dates, factor1, 'k')
hold on
plot(dates, xi1tHistory(1,:)+xi_means(1), 'r--')
title('Level Factor')
legend('Diebold-Li Estimate of the Factor','Smoothed Estimate of the Factor')
xlim([dates(16) dates(end)])
subplot(3,1,2)
plot(dates, factor2, 'k')
title('Slope Factor')
hold on
plot(dates, xi1tHistory(2,:)+xi_means(2), 'r--')
xlim([dates(16) dates(end)])

subplot(3,1,3)
plot(dates, factor3, 'k')
hold on
plot(dates, xi1tHistory(3,:)+xi_means(3), 'r--')
title('Curvature Factor')
xlim([dates(16) dates(end)])
