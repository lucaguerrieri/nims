function DeltaLgr = LossDiff_gr(forec1,forec2,true);
%addpath C:\brossi\research\library\hac;

%This file calculates Clark and West, JoE, test for martingale difference
%hypothesis with the bias correction.

% INPUT: forec1 is the forecast of the smaller model; 
%        forec2 is that of the largest model; 
%        qn is bandwidth in NW
% OUTPUT: pval, the p-value of the test
% This is valid with NaN values
% Test is to distinguish: y(t)=x*beta+e(t) vs y(t)=x*beta+z*gamma+e(t) where e(t) is mds

a=mean(isfinite(forec1),2); c=isfinite(forec2); b=isfinite(ones(size(true,1),1)); 
abc=a+b+c; abc=find(abc==3);
forec1=forec1(abc,:); true=true(abc); forec2=forec2(abc,:);

%n = length(forec1(:,i1));
DeltaLgr=(true-forec1).^2-(true-forec2).^2;
%teststat = sqrt(n)*mean(y)/sqrt(nw(y,qn)); 
%pval = 1-cdf('norm',teststat,0,1); 
