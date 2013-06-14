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
function [logLikel,errcode,xi1tHistory,xi10History,xi11History]= ...
    kalmanFilterSmoother_v2(f, h, y, a, x, xi10, p10, q, r, ntrain)

tol0 = 1e-5;
errcode = 0;
likel = 0;
logLikel = 0;

n = size(h,2);
t = size(y,2);

nstates = size(xi10,1);
xi10History =zeros(nstates,t+1);
xi10History(:,1) = xi10(:,1);

xi11History =zeros(nstates,t);
%errHistory = zeros(size(q,2),t);

% see 13.2.21
p10History = zeros(nstates,nstates,t+1);
p11History = zeros(nstates,nstates,t);
p10History(:,:,1) = p10;

likel = zeros(t,1);

for i=1:t
    if min(diag(p10))<0+tol0
        logLikel = -10e300; errcode=-1;
    else
        det_hpp10hr = det(h'*p10*h+r);
        if cond(h'*p10*h+r)<1e10
            %(det_hpp10hr>10e-300)
            hP_p10_hr_inv = (h'*p10*h+r)^-1;
            part1(:,1) = y(:, i) - a'*x - h'*xi10History(:,i);
            
            likel(i) = 0;
            if i > ntrain
                part2 = -0.5 * part1'*hP_p10_hr_inv*part1;
                
                likel(i) = (-n/2)*log(2*pi)-0.5*log(det(h'*p10*h+r))+part2;
                if logLikel+likel > 10e300
                    errcode = -1;
                    logLikel = -10e300;
                else
                    logLikel=logLikel + likel(i);
                end
            end
            % 13.6.5
            xi11History(:,i) = xi10History(:,i) + p10*h*hP_p10_hr_inv*part1(:,1);
            
            % 13.6.6
            xi10History(:,i+1) = f*xi11History(:,i);
            
            % 13.6.7
            p11 = p10 - p10*h*hP_p10_hr_inv*h'*p10;
            p11History(:,:,i) = p11;
            
            % 13.6.8
            p10 = f*p11*f' + q;
            p10History(:,:,i+1) = p10;
        end
    end
end
% now do a second pass backwards
xi1tHistory=xi11History;
xi1tHistory(:,t)=xi11History(:,t);

T = t;

xi1tHistory = zeros(nstates, T+1);
xi1tHistory(:,T+1) = xi10History(:,T+1);

for i=T:-1:1
    if cond(p10History(:,:,i+1))<1e10
        J = (p11History(:,:,i)*f')/p10History(:,:,i+1);
        xi1tHistory(:,i) = xi11History(:,i) + J*(xi1tHistory(:,i+1) - xi10History(:,i+1));
    else
        xi1tHistory(:,i) = xi11History(:,i);
    end
end


%     err_vec = 0*xi11History(:,end);
% T = t;
%
% bmatsmall = transpose(chol(q));
%
% for i=T:-1:1
%     errHistory(:,i) = bmatsmall'*err_vec;  % from Koopman's equation 4.41
%     err_vec=h*inv(h'*p10History(:,:,i)*h)*(y(:,i)-h'*xi10History(:,i)) ...
%         + ( f'-h*(f*p10History(:,:,i)*h*(h'*p10History(:,:,i)*h)^-1)' )*err_vec;
%     xi1tHistory(:,i)=xi10History(:,i)+p10History(:,:,i)*err_vec;
% end
%




% for i=T:-1:1
%     errHistory(:,i) = bmatsmall'*r;  % from Koopman's equation 4.41
%     r=h*inv(h'*p10History(:,:,i)*h)*(y(:,i)-h'*xi10History(:,i)) ...
%         + ( f'-h*(f*p10History(:,:,i)*h*(h'*p10History(:,:,i)*h)^-1)' )*r;
%     xi1tHistory(:,i)=xi10History(:,i)+p10History(:,:,i)*r;
% end

logLikel = -logLikel;
xi10History = xi10History(:,1:end-1);
xi1tHistory = xi1tHistory(:,1:end-1);