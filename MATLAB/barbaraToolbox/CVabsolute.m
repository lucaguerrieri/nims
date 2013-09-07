delete CVabsolute.out;
diary CVabsolute.out;
clear; 
randn('seed',13); 
muv=[0.1:0.05:0.9]; [ae,nq]=size(muv); 
nperc=4;  
tableA=zeros(length(muv),nperc+1);
P=3600; 
MC=20000;  
Av=zeros(MC,1); 

indexmu=1; 
for mu=muv; 

   for rep=1:MC;  
     
     m=round(mu*P); 
     eps=randn(P,1);
     At=[]; 
        for tau=m:P; 
            At=[At; sum(eps(tau-m+1:tau))/m]; 
        end;
        At=At-sum(eps)/P; 
     Av(rep,1)=max(abs(sqrt(P)*At));
    end; %end for mc

Avsort=sort(Av); 
tableA(indexmu,:)=[mu,Avsort(0.9*MC),Avsort(0.95*MC),Avsort(round(0.975*MC)),Avsort(0.99*MC)],
indexmu=indexmu+1;    
end; 


display('tablecv.m');
display('10%,5%,2.5%,1% c.v.');
tableA,

diary off;