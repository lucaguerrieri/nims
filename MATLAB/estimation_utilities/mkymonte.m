function montey = mkymonte(y,cofb,const,errmonte)

errmonte=errmonte';

nvars = size(y,2);
nobs = size(y,1);
montey = y';

nlags = size(cofb,3);
for obs=nlags+1:nobs
        montey(:,obs) = errmonte(:,obs-nlags)+const;
        for k=1:nlags
            montey(:,obs) = montey(:,obs)+cofb(:,:,k)*montey(:,obs-k);
        end 
end

montey=montey';