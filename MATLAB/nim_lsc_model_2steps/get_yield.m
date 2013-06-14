clear;

setpath;

load_paramvec_from_disk = 0;  % set to 1 to load saved param_vec from disk
                             % set to 0 to use first guess as defined below

%SVENY yields can be found in the 'yields' FAME db under the mnemonics in
%yields_varlist.
yields = csvread('/ofs/research2/Guerrieri/valentin/nim_lsc_model/data/yields_sveny_only_1985quarterly.csv', 1, 2);
dates = 1985.75:.25:2013.0;
end_pos = find(dates==2008.25);
yields = yields(1:end_pos,:)';
yields_varlist = char('SVENY0025','SVENY0050','SVENY0075','SVENY0100','SVENY0200','SVENY0300','SVENY0500', 'SVENY0700', 'SVENY1000', 'SVENY1500', 'SVENY2000', 'SVENY3000');

nstates = 3;
tau = [3 6 9 12 24 36 60 84 120 180 240 360];
tau = tau([1,5,9]);
yields = yields([1,5,9],:);
ntaus = length(tau);
lambda = .18;
ntrain = 15; %We have 153 observations per time t; we're setting ntrain to ~15% of observation pool.

factor1 = (yields(find(tau == 3),:)... 
           +  yields(find(tau == 24),:)...
           +  yields(find(tau == 120),:) )/3;
       
%factor1 = (yields(find(tau == 60),:));       
       
factor2 = (yields(find(tau == 3),:) - yields(find(tau == 120),:));

factor3 = ( 2*yields(find(tau == 24),:) ...
             - yields(find(tau == 120),:) ...
             - yields(find(tau == 3),:)  )*5; 

xi = [factor1; factor2; factor3];
xi_means = mean(xi,2);

% If OLS is preferred, uncomment the following section of code.
xi_demeaned = xi-kron(ones(1,size(xi,2)),xi_means);
xi10_demeaned = xi_demeaned(:,1); % Initial guess of unobserved states
var_data = xi_demeaned';

nvars = size(var_data,2);
varlag = 1;
varlagmat = varlag*ones(nvars);
[coefs,coverr,errmat]=estimate(varlagmat,zeros(nvars),ones(nvars,1),var_data(1:end-14,:));
isconstant = 1;
iscontemp = 0;
[f,const]=ols2ar(coefs(1:end,:),isconstant,iscontemp);

q = coverr;

%f = diag(0.5*ones(nstates,1));
%q = diag(1*ones(nstates,1));
r = diag(0*ones(ntaus,1));

q_n = length(diag(q));
r_n = length(diag(r));

q_diag_vec = [];
for this_n=1:q_n
    q_diag_vec = [q_diag_vec 
                  diag(q,q_n-this_n)];
end

r_diag_vec = [];
for this_n=1:r_n
    r_diag_vec = [r_diag_vec 
                  diag(r,r_n-this_n)];
end

param_vec = [ reshape(f,size(f,1)*size(f,2),1)
      q_diag_vec
      r_diag_vec
      xi_means %const
      lambda
      ];      

plot_yield(param_vec,tau,nstates,yields,ntrain,xi10_demeaned,q,dates,end_pos,factor1,factor2,factor3)
