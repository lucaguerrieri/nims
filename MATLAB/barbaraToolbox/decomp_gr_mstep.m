clc; clear all; close all

[rawdata series] = xlsread('Data.xls','multistep');

[t n] = size(rawdata);

m = 100;
R = 100;
P = t-R;
table = [];
for country = {'SZ', 'UK', 'CA', 'JP', 'DE', 'CP'}
    clear y x

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
        xindex = [12 13 14 15 26];
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

    y = rawdata(:,yindex)*100/12;
    x = rawdata(:,xindex)*100;

    time = calendar(1976,8,t,'m'); 
    tds  = calendar_plot(1976,8,t,'m');

    f_in_roll1=[];   f_oos_roll1=[];
    f_in_roll2=[];   f_oos_roll2=[];

    f_in_roll1=[];   f_oos_roll1=[];
    f_in_roll2=[];   f_oos_roll2=[];
    j = 1;

    while j <= (t - R)
        p = mbic(y(j:j+R-1,:), x(j:j+R-1,:), 12);
        rgr = [];
        start = j + p;

 
        for i = 1:p
            rgr = [rgr x(start-i:R+j-i,:)];
        end
        

        [betalarge betaintlarge rlarge] = regress(y(start-1:R+j-1), rgr);
        
               
        predrgr = [x(R+j,:) rgr(end,1:end-size(x,2))];

        f_in_roll1    = [f_in_roll1;  rlarge(end,:)^2 ]; 
        f_in_roll2    = [f_in_roll2;  y(j+R-1,:).^2 ];
        f_oos_roll1   = [f_oos_roll1 ;  predrgr*betalarge];
        f_oos_roll2   = [f_oos_roll2 ; 0];
      
        j = j+1;
    end

    DeltaL_oos = LossDiff_gr(f_oos_roll1, f_oos_roll2, y(1+R:end,:));  
    DeltaL_in  = f_in_roll1 - f_in_roll2; 

    qn = floor(size(DeltaL_oos,1)^(1/4));
    sigma = sqrt(nw(DeltaL_oos,qn));

    dates = time(2*m:end,1);

    DMW  = sqrt(size(DeltaL_oos,1))*mean( DeltaL_oos)/sigma;
    GWp = 1-cdf('chi2',DMW^2,1);
    if (GWp>0.05)
        GWp = 0;
    else
        GWp = 1;
    end


    results = abc(DeltaL_oos, DeltaL_in, m, qn);
    stats = results.stats;
    rej = results.rej;

    cv = results.cb;

    x1 = [1 1 length(results.A) length(results.A)];
    y1 = [cv(1,1) cv(1,2) cv(1,2) cv(1,1)];

    h = figure;
    ylbl = country;
    plot(results.A,'LineWidth',2)
    hold on
    plot(mean(results.B)*ones(size(results.A)), '--r', 'LineWidth',2)
    hold on
    plot(mean(results.C)*ones(size(results.A)), '-.k', 'LineWidth',2)
    hold on
    fill(x1,y1,[0.9 0.9 0.9], 'EdgeAlpha', 0)
    axis normal
    legend('A_{\tau, p}','B_p', 'U_p','bands','Location','best')
    title(ylbl,'FontSize',12);
    set(gca, 'XTick', 1:2*12:size(dates,1))
    set(gca, 'XTickLabel', dates(1:2*12:size(dates,1)))
    xlabel('Time', 'FontSize', 12);
    xlim([1 size(dates,1)])
    print(h, '-dpsc', strcat(char(ylbl),'decomp_gr1.eps'))
    hold off    
    
    table = [table; DMW  GWp; stats(1,1) rej(1,1); stats(1,2) rej(1,2); stats(1,3) rej(1,3)];
end

display(country)
table

disp('Program Complete')