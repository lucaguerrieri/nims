clc; clear all; close all

[rawdata series] = xlsread('Data.xls','replicate' );
[t n] = size(rawdata);
country = 'SZ';
P = 200;

if (strcmp(country,'SZ'))
    yindex = 1;
    xindex = [2 3 4 5 26];
    sindex = series(1,2);
elseif (strcmp(country,'UK'))
    yindex = 6;
    xindex = [7 8 9 10 26];
    sindex = series(1,7);
elseif (strcmp(country,'CA'))
    yindex = 11;
    xindex = [12 27]% 13 14 15 26];
    sindex = series(1,12);
elseif (strcmp(country,'JP'))
    yindex = 16;
    xindex = [17 18 19 20 26];
    sindex = series(1,17);
elseif (strcmp(country,'DE'))
    yindex = 21;
    xindex = [22 23 24 25 26];
    sindex = series(1,22);
elseif (strcmp(country,'CP'))
    yindex = 11;
    xindex = 27;
    sindex = series(1,28);
end

y = rawdata(:,yindex)*100;
x = rawdata(:,xindex)*100;

time = calendar(1975,10,t,'m'); 
tds = calendar_plot(1975,10,t,'m');

l = 1;
for L = 40:1:196
    j = 1;
    while j <= (t - L)
        %betalarge(:,j) = regress(y(j:j+L-1,:), [ones(L,1) x(j:j+L-1,:)]); 
        betalarge(:,j) = regress(y(j:j+L-1,:), [x(j:j+L-1,:)]); 
        
        ferrorsmall(:,j) = y(j+L,:);
        
        %ferrorlarge(:,j) = y(j+L,:)- [ones(size(x(j+L),1)) x(j+L,:)]*betalarge(:,j);
        ferrorlarge(:,j) = y(j+L,:)- [x(j+L,:)]*betalarge(:,j);
        
        j = j+1;
    end
    
    % the following line is for figure 1
    msfe(:,l) = mean(ferrorlarge(:,1:P).^2)/mean(ferrorsmall(:,1:P).^2);
    
    % the following line is for figure 2 
    %msfe(:,l) = mean(ferrorlarge(:,end-P+1:end).^2)/mean(ferrorsmall(:,end-P+1:end).^2);
    l = l + 1;
    clear betasmall betalarge ferrorsmall ferrorlarge
end

plot(40:1:196, msfe, '-r', 'Linewidth',2)
hold on
plot(40:1:196, ones(size(msfe)),'Linewidth',2)
ylim([0.9 1.3])
title(sindex)