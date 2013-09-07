function results = abc(DeltaL_oos,DeltaL_in,m,qn)


P=size(DeltaL_oos,1);


B = olsbeta(DeltaL_oos,DeltaL_in)*DeltaL_in;  
C = olsres(DeltaL_oos,DeltaL_in);
betahat = olsbeta(DeltaL_oos,DeltaL_in);

%Construct CI
%varbetahat = nw(DeltaL_in.*C,qn)/ (mean(DeltaL_in.^2)^2);
%varyhat = (mean(DeltaL_in)^2)*varbetahat; 
varyhat = nw(B,qn);
rejB = mean(B)-1.96*sqrt(varyhat)/sqrt(P) >0  |  mean(B)+1.96*sqrt(varyhat)/sqrt(P) <0; 

varC = nw(DeltaL_oos,qn)-varyhat; 
rejC = mean(C)-1.96*sqrt(varC)/sqrt(P) >0  |  mean(C)+1.96*sqrt(varC)/sqrt(P) <0;  

A=[];  
for tau=m:P; 
    A=[A; sum(DeltaL_oos(tau-m+1:tau))/m]; 
end; 
A = A - mean(DeltaL_oos);

cv=cvcalcABS(m/P);
[nA,kA]=size(A); 
cvlow=-cv*ones(nA,1); cvup=cv*ones(nA,1); 
rejA=max(sqrt(P)*abs(A)/sqrt(nw(DeltaL_oos,qn))-cvlow <0  |  sqrt(P)*abs(A)/sqrt(nw(DeltaL_oos,qn))-cvup >0); 

%rejA=max(sqrt(P)*abs(A)/sqrt(varA)-cvlow <0  |  sqrt(P)*abs(A)/sqrt(varA)-cvup >0); 
        
stats=[max(sqrt(P)*abs(A)/sqrt(nw(DeltaL_oos,qn))), mean(B)/(sqrt(varyhat)/sqrt(P)),  mean(C)/(sqrt(varC)/sqrt(P))];  
rej=[rejA, rejB, rejC];   
results.A = A;
results.B = B; 
results.C = C;
results.cb = [cvlow*sqrt(nw(DeltaL_oos,qn))/sqrt(P) cvup*sqrt(nw(DeltaL_oos,qn))/sqrt(P)]; 
results.stats = stats;
results.rej = rej;
results.beta = olsbeta(DeltaL_oos,DeltaL_in);
results.varyhat=varyhat; 
