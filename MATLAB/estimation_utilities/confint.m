
function [confint_lb confint_ub] = confint(confint_perctl,cofb,const,errmat,y,varlag,nreps,isconstant,iscontemp,yw,h,y_data,xi10,P10,q,ntrain)

T = size(errmat,1);
neqs = size(errmat,2);

nperiods = size(y_data,1);
nim_mat = zeros(nreps,nperiods);


bad_draw=0;
for confindx=1:nreps
    issingular=-1;
    
    %stay in while loop until artificial data is generated that leads a nonsingular VAR    
    while (issingular<0) % keep drawing a new monte carlo series until one is found
        % that produces a covariance stationary VAR
        
        %%% Sample with replacement from the fitted residuals
        errpos = round((T-1)*rand(T,1)+ones(T,1));
%         for posindx=1:T
%             errmonte(posindx,:)=errmat(errpos(posindx),:);
%         end
        errmonte=errmat(errpos,:);
        
        %%% Using VAR structure and bootstrapped residuals, compute new y data
        %ymonte = mkymonteg(y,coefs,errmonte);
        ymonte = mkymonte(y,cofb,const,errmonte);
        if (yw == 0) 
            %[coefsmonte,coverr,errmatmonte]=estimateg(varlag,ymonte);
            varlagmat = varlag*ones(neqs);
            [coefsmonte,coverr,errmatmonte]=estimate(varlagmat,zeros(neqs),ones(neqs,1),ymonte);
            

            [cofbmonte,const_bmonte]=ols2ar(coefsmonte(1:end,:),isconstant,iscontemp);
            cofamonte = iscontemp*coefsmonte(1+isconstant:neqs+isconstant,:);
        else    
            [Amonte, a0monte, coverr] = ywestimate(ymonte,varlag);
            [cofbmonte,const_bmonte]=yw2ar(Amonte,a0monte);
            cofamonte = zeros(neqs);
        end
        
        cofainvmonte = (eye(neqs)-cofamonte)^(-1);
        cofcmonte=isconstant*cofainvmonte*const_bmonte; 
        
        
        [issingular] = singulartest(cofbmonte);
        if issingular < 0
            bad_draw = bad_draw + 1;
        end
        
    end  %end of while loop
     cofcompanion = companion(cofbmonte,const_bmonte);
    
    [logLikel,errcode,xi10History,...
     xi1tHistory,errHistory] = ...
     kalmanFilterSmoother(cofcompanion, h', y_data',...
                          xi10, P10, q, ntrain);

     nim_mat(confindx,:)=xi1tHistory(1,:);
    
    
end

nim_mat = sort(nim_mat);

confint_lb = nim_mat(floor((1-confint_perctl/100)*nreps),:);
confint_ub = nim_mat(ceil(confint_perctl/100*nreps),:)
pw_mean = mean(nim_mat);