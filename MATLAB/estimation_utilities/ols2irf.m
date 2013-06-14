function irf1hat = ols2irf(bhat,endogpp,nperiods)


irf1hat=bhat(1+endogpp+1:end);
if (length(irf1hat)<nperiods)
    irf1hat=[irf1hat; zeros(nperiods-length(irf1hat),1)];
else
    irf1hat=irf1hat(1:nperiods);
end

for i=1:length(irf1hat)-1
    for j=1:min(i,endogpp)
        irf1hat(i+1) = irf1hat(i+1)+bhat(1+j)*irf1hat(i+1-j);
    end
end
