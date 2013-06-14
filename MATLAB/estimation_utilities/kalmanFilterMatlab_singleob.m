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
function [logLikel,errcode]= kalmanFilterMatlab_singleob(f, h, y, xi10,p10,q,r,ntrain)


errcode = 0;
likel = 0;
logLikel = 0;

n = size(h,2);
t = size(y,2);

xi10History(:,1) = xi10(:,1);

xi11History(:,1) = xi10History(:,1);

% see formula in 13.4
for i=1:t
    hP_p10_h = (h'*p10*h)^-1;
    part1(:,1) = y(:, i) - h'*xi10History(:,1);
    
    if i > ntrain
        part2 = -0.5 * part1'*hP_p10_h*part1;
        det_hpp10h = det(h'*p10*h);
        if (det_hpp10h>10e-300)
            likel = (-n/2)*log(2*pi)-0.5*log(det(h'*p10*h))+part2;
            if logLikel+likel > 10e300
                errcode = -1;
                logLikel = 10e300;
            else
                logLikel=logLikel + likel;
            end
        else 
            errcode = -1;
        end
    end
    
    % 13.2.15
    xi11History(:,1) = xi10History(:,1) + p10*h*hP_p10_h*part1(:,1);

    % 13.2.16
    p11 = p10 - p10*h*hP_p10_h*h'*p10;

    % 13.2.17
    xi10History(:,1) = f*xi11History(:,1);

    % 13.2.21
    p10 = f*p11*f' + q;
end
logLikel = -logLikel;
