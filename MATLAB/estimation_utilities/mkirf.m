function history=mkirf(shock,cofb,nperiods)

maxlag=size(cofb,3);

neqs=size(cofb,1);

history=zeros(neqs,maxlag+nperiods);

for periodindx=maxlag+1:maxlag+nperiods
    % in the first period of the IRFs add the shock
    if periodindx==maxlag+1
       newstate=shock;
    else
       newstate = zeros(neqs,1);
    end   
    for lagindx=1:maxlag
        newstate = newstate+cofb(:,:,lagindx)*history(:,periodindx-lagindx);
    end
    % update the history matrix
        history(:,periodindx) = newstate;
end

history=history(:,maxlag+1:end);
return
