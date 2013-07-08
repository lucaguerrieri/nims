function [beta_pc V xreg] = pc_regress(y,x,npc,ylag)

nobs = size(y,1);
nx = size(x,2);

[V,D] = eig(x(ylag:end-1,:)'*x(ylag:end-1,:));
V = V(:,nx-npc+1:end);

ylagreg = [];
for i=1:ylag
    ylagreg = y(ylag+1-i:end-i,:);
end

xreg = [ones(nobs-ylag,1) ylagreg x(ylag:end-1,:)*V];

yreg = y(ylag+1:end);

beta_pc = mldivide(xreg'*xreg,xreg'*yreg);


