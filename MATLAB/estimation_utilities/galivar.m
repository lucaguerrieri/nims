function [IRF,shock1,cofb,A0,IRFunscale] = galivar(yw,vardata,rescalemat,nperiods,varlag,scalefactor) 
%%%Imposes long run restrictions to identify technology shock using Gali's long run restrictions.
%%%ydata must be TxN with the first element productivity in differences.


y = vardata;
startdt = 1;
enddt = size(y,1);

varlags = varlag*ones(size(y,2));
varmaxlag = varlag;

neqs = size(varlags,1);
contemp = zeros(neqs);
iscontemp = 0;

%%%%%% Check structure of the VAR
nvars = size(varlags,2);

constant = ones(neqs,1);  % if the nth entry of constant is 1 
% a constant is included in the nth equation of the VAR
if max(constant)==1
    isconstant=1;
else
    isconstant=0;
end

if (yw==0) 
    %%%%% Estimate the VAR using OLS
    % coefs will store the regression coefficients
    % each equation is on a different column
    % if there is a constant, the first entry is the intercept term
    % then variables entering contemporaneously,
    % then the firt lags, and so on.
    %[coefs,coverr]=estimate(varlags,contemp,constant,y,startdt,enddt);
    [coefs,coverr,errmat,icode]=estimateg(varlag,y);
    [cofb,const_b]=ols2ar(coefs(1:end,:),isconstant,iscontemp);
else
    % estimate VAR by solving YW equations
    [A,a0,coverr] = ywestimate(y,varlag);
    [cofb,const_b] = yw2ar(A,a0);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate IRFs
% follow Hamilton page 318
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%cofa=iscontemp*coefs(1+isconstant:neqs+isconstant,:);
%cofainv=(eye(neqs))^(-1);
cofc=isconstant*const_b; 


Vmat = zeros(neqs);
for i = 1:varmaxlag
    Vmat = Vmat - cofb(:,:,i);
end
Vmat = Vmat+eye(neqs);
Vmatinv = eye(neqs)/Vmat;

%Identify home shock using standard restriction that only home technology shocks
%affect home productivity.  

shock=zeros(neqs,1);
[cholmat,pchol] = chol(Vmatinv*coverr*Vmatinv');
if (pchol > 0 | icode~=0)
    %bad_draw happened - not positive semi definite matrix
    IRF = [];
    shock1 = [];
    cofb = [];
    A0=[];
    IRFunscale = [];
else
    A0 = Vmat*cholmat';
    shockpos = 1; 
    
    if isempty(scalefactor) == 1
        shock(shockpos) = 1;
    else
        shock(shockpos) = 1/scalefactor;
    end;   
    
    %compute IRFs
    history=mkirf(A0*shock,cofb,nperiods);
    IRFunscale = history(:,varlags:nperiods+varlags-1)';
    [var_level] = growth2level(history([rescalemat],:),100);
    history([rescalemat],:) = var_level;
    IRF = history(:,varlags:nperiods+varlags-1)';
    
    %compute technology shock series
    [shock1] = getshock1(cofb,const_b,A0,y,varmaxlag);
end;











