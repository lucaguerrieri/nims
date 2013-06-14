function [zdata]=mkdata(nperiods,cofb,endog_,wishlist,errlist,irfshock,scalefactormod)

%[nsim, ksim, ysim, isim, csim] = mkdata(nperiods,cofb,endog_)

% given decision rule 
neqs = size(endog_,1);

if nargin>5
if isempty(scalefactormod);
    scalefactormod=1;
end
end

history = zeros(neqs,nperiods+1);

if nargin>5
    irfshockpos = strmatch(irfshock,endog_,'exact');
end

% find position of shocks in the vector of endogenous variables
nerrs = size(errlist,1);
errpos = zeros(size(errlist,1),1);
for errindx = 1:nerrs
    errpos(errindx) = strmatch(errlist(errindx,:),endog_,'exact');
end

% generate data
% history will contain data, the state vector at each period in time will
% be stored columnwise.
history = zeros(neqs,nperiods+1);
if nargin>5
    history(irfshockpos,1) = 1/scalefactormod;
end
for i = 2:nperiods+1
    % set shocks
    if nargin<=5 
        history(errpos,i-1) = randn(nerrs,1);
    end
    % update endogenous variables
    history(:,i) = cofb * history(:,i-1);
end

% list of variables we wish to extract from data matrix
%wishlist = char('eff','ukp','ugdp','uinv','ucc','kp');
nwish=size(wishlist,1);
wishpos = zeros(nwish,1);

history=history';
for i=1:nwish
    wishpos(i) = strmatch(wishlist(i,:),endog_,'exact');
end
zdata = history(2:end,wishpos);