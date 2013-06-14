function [f, q, r, x, a, lambda, h, xi_means, error] = kalmanFilterSetup(param_vec,tau,nfactors,nothers)

ntaus = length(tau);
nstates = nfactors + nothers;
error = 0;

tol0 = 1e-8;
f = reshape(param_vec(1:(nfactors)^2),nfactors,nfactors);
f_end = (nfactors)^2;
f = [[f zeros(nfactors,nothers)]; reshape(param_vec(f_end+1:(f_end+nothers*(nfactors+nothers))), nothers, nfactors+nothers)];

if max(abs(eig(f)))>1+tol0
    error = -1;
end

q_start = f_end+nothers*(nfactors+nothers)+1;
q_end =  f_end+nothers*(nfactors+nothers) + (nstates*(nstates+1))/2;
q_all = reshape(param_vec(q_start:q_end), (nstates*(nstates+1)/2), 1);

q = zeros(nstates);

qdiag_start_counter = 1;
qdiag_end_counter = 1;
for diag_index = (nstates)-1:-1:1
    q=q+diag(q_all(qdiag_start_counter:qdiag_end_counter),diag_index);
    qdiag_start_counter=qdiag_end_counter+1;
    qdiag_end_counter = qdiag_end_counter+1+(nstates)-diag_index;
end
q = (q + q') + diag(q_all(qdiag_start_counter:qdiag_end_counter));

%    q = (diag(q_all(1), 2) + diag(q_all(2:3), 1));
%    q = (q + q') + diag(q_all(4:6), 0);

% check that q is positive semi-definite == det > 0    
if  min(eig(q))< 0
    error = -1;
end

r_start = q_end+1;
r_end = q_end + ntaus+nothers;

% check that r is positive semi-definite == det > 0    
if min(param_vec(r_start:r_end))< 0
    error = -1;
end

r = diag(param_vec(r_start:r_end));

Mu_L = param_vec(r_end+1, 1);
Mu_S = param_vec(r_end+2, 1);
Mu_C = param_vec(r_end+3, 1);
Mu_Nims = param_vec(r_end+4, 1);

% check that lambda is positive
lambda = param_vec(size(param_vec,1));
if lambda < tol0
    error = -1;
end

a=eye(ntaus+nothers);
%h = zeros(nstates,ntaus);
%h = eye(nstates,ntaus); %should be 3x3
%for tau_indx = 1:ntaus
%    h(:,tau_indx) = [1; (1-exp(-tau(tau_indx)*lambda))/tau(tau_indx)*lambda; ((1-exp(-tau(tau_indx)*lambda))/tau(tau_indx)*lambda)-exp(-tau(tau_indx)*lambda)];  
%end

h_prime = get_h_prime(tau, lambda);
h_prime = [[h_prime zeros(ntaus,nothers)]; zeros(nothers,nfactors) eye(nothers)];

h = h_prime';

% h = eye(nstates,ntaus); %should be 3x3
% h_prime = h';

xi_means = [Mu_L; Mu_S; Mu_C; Mu_Nims];

x = h_prime*xi_means; %Defining exogenous variables

