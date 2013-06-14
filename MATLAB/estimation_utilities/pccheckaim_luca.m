function err = pccheckaim_luca(neq, nlag, nlead, h, b)

%   Substitute the reduced form, b, into the structural 
%   equations, h, and display the maximum absolute error.

% Append negative identity matrix to b

b = [b, -eye(neq)];

%  Define indexes into the lagged part (minus) and the current and
%  lead part (plus) of h 

minus =          1:           neq*nlag;
plus  = neq*nlag+1: neq*(nlag+1+nlead);

% Initialize q

q = zeros(neq*(nlead+1), neq*(nlag+1+nlead));

% Stuff b into the upper left-hand block of q

[rb,cb] = size(b);
q(1:rb,1:cb) = b(1:rb,1:cb);

%  Copy b into the (nlead) row blocks of q, shifting right by neq once
%  more for each block: this produces a coefficient matrix that 
%  solves for (x(t),..., x(t+nlead))' in terms of (x(t-nlag),..., x(t-1))'.

for i = 1:nlead
   rows = i*neq + (1:neq);
   q(rows,:) = shiftright( q(rows-neq,:), neq );
end

%  Premultiply the left block of q by the negative inverse of the right
%  block of q

q(:,minus) =  -q(:,plus)\q(:,minus);

% Define the solution error

error = h(:,minus) + h(:,plus)*q(:,minus);
err = max(max(abs( error )));


return
