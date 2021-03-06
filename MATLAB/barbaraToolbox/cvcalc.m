function cvalue=cvcalc(osser);
%Calculates p-values of TVP and Optimal tests -- requires tables in the same directory
%Inputs: osser=osserved value of the statistic
%Output: critical value at 5% level (scalar)
%Note: the critical value table is generated by cvREC.m

numero=[0.1000   10.4960   
    0.1500    8.0866    
    0.2000    6.6086    
    0.2500    5.5939    
    0.3000    4.8424    
    0.3500    4.2124    
    0.4000    3.7380    
    0.4500    3.3333    
    0.5000    2.9842    
    0.5500    2.7003    
    0.6000    2.4125    
    0.6500    2.1531    
    0.7000    1.9000    
    0.7500    1.6555    
    0.8000    1.4458    
    0.8500    1.1919    
    0.9000    0.9516];    


tavola=numero; 
uno=0; 
if osser<=tavola(1,1) cv=numero(1,2); uno=uno+1; end;
if osser>=tavola(end,1) cv=numero(end,2); uno=uno+1; end;
if uno==0;
   rigal=find(numero(:,1)<=osser);
   riga=[max(rigal);max(rigal)+1]; sel=tavola(riga,[1,2]);
   cv=sel(2,2)+(sel(2,1)-osser)*(sel(1,2)-sel(2,2))/(sel(2,1)-sel(1,1));
end;
cvalue=cv;
