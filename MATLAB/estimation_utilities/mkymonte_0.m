function montey = mkymonte_0(y,coefs,errmonte)

errmonte=errmonte';

nvars = size(y,2);
nobs = size(errmonte,2);
montey = zeros(nvars,nobs);

[cofb,const_b]=ols2ar(coefs,1,0);

nlags = size(cofb,3);
for obs=nlags+1:nobs
        montey(:,obs) = errmonte(:,obs-nlags);
        for k=1:nlags
            montey(:,obs) = montey(:,obs)+cofb(:,:,k)*montey(:,obs-k);
        end 
end

montey=montey';