function h_prime = get_h_prime(tau, lambda)

if size(tau,2)>size(tau,1)
    tau=transpose(tau);
end
h1 = ones(length(tau),1);
h2 = ((1-exp(-tau*lambda))./(tau*lambda));
h3 = ((1-exp(-tau*lambda))./(tau*lambda)) - exp(-tau*lambda);

h_prime = [h1 h2 h3];