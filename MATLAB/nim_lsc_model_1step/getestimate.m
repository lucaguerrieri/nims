%% first step regression
% data starts in 1974:1 and ends in 2005:6
load monthdata.txt

%varlag = [12 12 12];
%[coefs,coverr,errmat,icode]=estimateg(varlag,monthdata);

varlag = 12;
varlagmat = varlag*ones(3);
startpos =1;
endpos = size(monthdata,1);
[coefs,coverr,errmat]=estimate(varlagmat,zeros(3),[1 1 1]',monthdata,startpos,endpos);


coverr = errmat'*errmat/(size(errmat,1)-sum(sum(varlagmat)));
a0inv = transpose(chol(coverr));

% separate out the standard deviation from the
% diagonal of the cholesky decomposition
sd = diag(a0inv);
a0inv = a0inv*diag(sd.^-1);


% get the IRFs
isconstant = 1;
iscontemp = 0;
nperiods = 24;
yw=0;     % switch for the confidence intervals (0 = OLS, 1=Yule-Walker estimation)
nreps = 20;  % repetitions for Monte Carlo confidence intervals 
[cofb,const_b]=ols2ar(coefs(1:end,:),isconstant,iscontemp);

shock = [sd(1) 0 0]';
history=mkirf(a0inv*shock,cofb,nperiods);
IRF_1 = history(:,max(varlag+1):nperiods+max(varlag))';
rand('seed',125);       % set the seed for generating Monte Carlo samples
shock = [1 0 0]';
[upperbound_1,lowerbound_1] = ...
         confint(coefs,errmat,monthdata,varlag,nreps,nperiods,isconstant,iscontemp,yw,shock,IRF_1);


shock = [0 sd(2) 0]';
history=mkirf(a0inv*shock,cofb,nperiods);
IRF_2 = history(:,max(varlag+1):nperiods+max(varlag))';
rand('seed',125);       % set the seed for generating Monte Carlo samples
shock = [0 1 0]';
[upperbound_2,lowerbound_2] = ...
         confint(coefs,errmat,monthdata,varlag,nreps,nperiods,isconstant,iscontemp,yw,shock,IRF_2);



shock = [0 0 sd(3)]';
history=mkirf(a0inv*shock,cofb,nperiods);
IRF_3 = history(:,max(varlag+1):nperiods+max(varlag))';
rand('seed',125);       % set the seed for generating Monte Carlo samples
shock = [0 0 1]';
[upperbound_3,lowerbound_3] = ...
         confint(coefs,errmat,monthdata,varlag,nreps,nperiods,isconstant,iscontemp,yw,shock,IRF_3);



figure
subplot(3,3,1)
plot(1:nperiods,IRF_1(:,1),'k',1:nperiods,upperbound_1(:,1),'b--',1:nperiods,lowerbound_1(:,1),'b--')
title('Growth in Oil Supply, Response to Oil Supply Shock')

subplot(3,3,2)
plot(1:nperiods,IRF_1(:,2),'k',1:nperiods,upperbound_1(:,2),'b--',1:nperiods,lowerbound_1(:,2),'b--')
title('Industrial Activity, Response to Oil Supply Shock')


subplot(3,3,3)
plot(1:nperiods,IRF_1(:,3),'k',1:nperiods,upperbound_1(:,3),'b--',1:nperiods,lowerbound_1(:,3),'b--')
title('Real Oil Price, Response to Oil Supply Shock')

subplot(3,3,4)
plot(1:nperiods,IRF_2(:,1),'k',1:nperiods,upperbound_2(:,1),'b--',1:nperiods,lowerbound_2(:,1),'b--')
title('Growth in Oil Supply, Activity Shock')

subplot(3,3,5)
plot(1:nperiods,IRF_2(:,2),'k',1:nperiods,upperbound_2(:,2),'b--',1:nperiods,lowerbound_2(:,2),'b--')
title('Industrial Activity, Activity Shock')

subplot(3,3,6)
plot(1:nperiods,IRF_2(:,3),'k',1:nperiods,upperbound_2(:,3),'b--',1:nperiods,lowerbound_2(:,3),'b--')
title('Real Oil Price, Activity Shock')

subplot(3,3,7)
plot(1:nperiods,IRF_3(:,1),'k',1:nperiods,upperbound_3(:,1),'b--',1:nperiods,lowerbound_3(:,1),'b--')
title('Growth in Oil Supply, Response to Demand Shock')

subplot(3,3,8)
plot(1:nperiods,IRF_3(:,2),'k',1:nperiods,upperbound_3(:,2),'b--',1:nperiods,lowerbound_3(:,2),'b--')
title('Industrial Activity, Response to Demand Shock')

subplot(3,3,9)
plot(1:nperiods,IRF_3(:,3),'k',1:nperiods,upperbound_3(:,3),'b--',1:nperiods,lowerbound_3(:,3),'b--')
title('Real Oil Price, Response to Demand Shock')


% set axes
hold on
for i=1:9
    subplot(3,3,i)
    xlim([1,24])
    if(i==1 | i==4 | i==7)
        ylabel('Percentage Point')
    else
        ylabel('Percent')
    end
end

for i=7:9
    subplot(3,3,i)
    xlabel('Months')
end
hold off

