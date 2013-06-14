
function [irfs1, irfs2] = confint(coefs,errmat,y,varlag,nreps,nperiods,isconstant,iscontemp,yw,)

T = size(errmat,1);
neqs = size(errmat,2);

irfs1 = zeros(nreps,neqs,nperiods);
irfs2 = irfs1;

bad_draw=0;
for confindx=1:nreps
    confindx
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
        ymonte = mkymonte(y,coefs,errmonte);
        if (yw == 0) 
            %[coefsmonte,coverr,errmatmonte]=estimateg(varlag,ymonte);
            varlagmat = varlag*ones(neqs);
            startpos =1;
            endpos = size(ymonte,1);
            [coefsmonte,coverr,errmatmonte]=estimate(varlagmat,zeros(neqs),ones(neqs,1),ymonte,startpos,endpos);

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
    
    coverr = errmatmonte'*errmatmonte/size(errmatmonte,1);
    Vmat = zeros(neqs);
    for i = 1:varlag
        Vmat = Vmat - cofbmonte(:,:,i);
    end
    Vmat = Vmat+eye(neqs);
    Vmatinv = eye(neqs)/Vmat;

    [cholmat,pchol] = chol(Vmatinv*coverr*Vmatinv');
    A0inv = Vmat*cholmat';

    
    %generating impulse response functions
    history1=mkirf(A0inv*shock1,cofbmonte,nperiods);
    history2=mkirf(A0inv*shock2,cofbmonte,nperiods);
    
    % assign the IRFs and the residuals
    for i=1:neqs
       irfs1(confindx,i,:) = history1(i,:);
       irfs2(confindx,i,:) = history2(i,:);
    
    end
    
    
end


