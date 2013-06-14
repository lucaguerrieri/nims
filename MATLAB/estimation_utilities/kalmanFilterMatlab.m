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
function [logLikel,errcode]= kalmanFilterMatlab(f, h, y, a, x, xi10, p10, q, r, ntrain)

tol0 = 1e-5;
errcode = 0;
likel = 0;
logLikel = 0;

n = size(h,2);
t = size(y,2);

xi10History(:,1) = xi10(:,1);

xi11History(:,1) = xi10History(:,1);

likel = zeros(t,1);
% see formula in 13.4
for i=1:t
    if min(diag(p10))<0+tol0
        logLikel = -10e300; errcode=-1;
    else
        
        det_hpp10hr = det(h'*p10*h+r);
        if cond(h'*p10*h+r)<1e10
            %(det_hpp10hr>10e-300)
            hP_p10_hr = (h'*p10*h+r)^-1;
            part1(:,1) = y(:, i) - a'*x - h'*xi10History(:,1);
            
            likel(i) = 0;
            if i > ntrain
                part2 = -0.5 * part1'*hP_p10_hr*part1;
                
                if det(h'*p10*h+r)<0
                likel(i) = - 10e300;
                errcode = -1;
                else
                likel(i) = (-n/2)*log(2*pi)-0.5*log(det(h'*p10*h+r))+part2;
                end
                if logLikel+likel > 10e300
                    errcode = -1;
                    logLikel = -10e300;
                else
                    logLikel=logLikel + likel(i);
                end
            end
            
            % 13.2.15
            xi11History(:,1) = xi10History(:,1) + p10*h*hP_p10_hr*part1(:,1);
            
            % 13.2.16
            p11 = p10 - p10*h*hP_p10_hr*h'*p10;
            
            % 13.2.17
            xi10History(:,1) = f*xi11History(:,1);
            
            % 13.2.21
            p10 = f*p11*f' + q;
            %        if ~isempty(find(eig(p10)<1+tol0))
            %            error = -1;
            %         end
        else
            errcode = -1; logLikel = -1e300;
        end
    end
end
logLikel = -logLikel;
