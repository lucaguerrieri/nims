function [flag,lam,F] = singulartest(cofb)

flag = 0;
k = size(cofb,2);
q = size(cofb,3);
F = zeros(k*q,k*q);
for i=1:q
    F(1:k,k*(i-1)+1:k*(i)) = cofb(:,:,i);
end
F(k+1:k*q,1:k*(q-1)) = eye(k*(q-1));
[lam] = eig(F);
condn = max(condeig(F));
if condn > 1000000
   flag = -1
   fprintf('VAR is too close to being singular \n');
   condn 
end
