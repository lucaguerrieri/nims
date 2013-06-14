function [y] = yield_calc(tau, lambda, xi_means, xi1t)

if size(tau,2)>size(tau,1)
tau = tau';
end

h_prime = get_h_prime(tau, lambda);

%h = eye(3); %should be 3x3
%h_prime = h';

%Calculate the yield at given maturity using the measurement equation.
%There are three instances of xi1tHistory because we have three state
%variables.
%We are adding in the constants (the Mu_L, Mu_S, and Mu_C) because
%estimates of the state variables are de-meaned in xi1tHistory.
y = h_prime*(xi1t + kron(ones(1,size(xi1t,2)), xi_means));
