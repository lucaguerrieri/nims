% !the inputs follow the notation in Hamilton, section 13.2
% !
% !f is the transition matrix for the hidden state
% !h relates the observable state to the hidden state
% !y holds the observed data
% !x10 is the initial prior on the initial state vector
% !q is the variance covariance matrix on error term in the hidden state
% !
% !likel is the log likelihood
% !x_t_t-1 is the history of priors
% !x_t_t is the history of posteriors

% ! full(T)         => f
% ! full(Z')        => h
% ! full(zdata')    => y
% ! full(b0)        => xi10
% ! full(Q)         => q
% ! ntrains         => ntrain

% Note:  Not Checking Input
function [logLikel,errcode,xi10History,xi1tHistory,errHistory]= kalmanFilterSmoother(f, h, y, xi10, q, bmatsmall, ntrain)
errcode = 0;
likel = 0;
logLikel = 0;

n = size(h,2);
t = size(y,2);
nstates = size(xi10,1);
xi10History =zeros(nstates,t+1);
xi10History(:,1) = xi10(:,1);

xi11History =zeros(nstates,t);
errhistory = zeros(size(bmatsmall,2),t);

% see 13.2.21
p10 = q;
p10History = zeros(nstates,nstates,t+1);
p11History = zeros(nstates,nstates,t);
p10History(:,:,1) = p10;

for i=1:t
    %(H'*(Pt|t-1)*H)^-1
    hP_p10_h = (h'*p10*h)^-1;
    part1(:,1) = y(:, i) - h'*xi10History(:,i);
    
    if i > ntrain
        part2 = -0.5 * part1'*hP_p10_h*part1;
        likel = (2*pi)^(-n/2)*det(h'*p10*h)^(-0.5)*exp(part2);
        
        if likel > exp(-300*log(10))
            logLikel=logLikel + log(likel);
        else
            errcode = -1;
        end
    end
    
    % 13.6.5
    xi11History(:,i) = xi10History(:,i) + p10*h*hP_p10_h*part1(:,1);

    % 13.6.7
    p11 = p10 - p10*h*hP_p10_h*h'*p10;
    p11History(:,:,i) = p11;
    % 13.6.6
    xi10History(:,i+1) = f*xi11History(:,i);

    % 13.2.21
    p10 = f*p11*f' + bmatsmall*bmatsmall';
    p10History(:,:,i+1) = p10;
end

% now do a second pass backwards
xi1tHistory=xi11History;
xi1tHistory(:,t)=xi11History(:,t);


r = 0*xi11History(:,end);
T = t;

for i=T:-1:1
    errHistory(:,i) = bmatsmall'*r;  % from Koopman's equation 4.41
    r=h*inv(h'*p10History(:,:,i)*h)*(y(:,i)-h'*xi10History(:,i)) ...
        + ( f'-h*(f*p10History(:,:,i)*h*(h'*p10History(:,:,i)*h)^-1)' )*r;
    xi1tHistory(:,i)=xi10History(:,i)+p10History(:,:,i)*r;
end

logLikel = -logLikel;
xi10History = xi10History(:,1:end-1);