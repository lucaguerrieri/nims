function vargout=load_pro_forma_data(vargin)


if nargin == 0
    bank_ids = [         1027004    1037003       1039502               1068025   1068191            1069778              1070345          1073757             1074156     1078529          1111435             1119794  1120754            1131787       1132449                 1199611           1199844    1245415         1378434            1951350      2277860        3242838       3587146]';
    bank_names = char('ZIONS BC','M\&T BK CORP','JPMORGAN CHASE \& CO','KEYCORP','HUNTINGTON BSHRS','PNC FNCL SVC GROUP','FIFTH THIRD BC','BANK OF AMER CORP','BB\&T CORP','BBVA USA BSHRS','STATE STREET CORP','U S BC','WELLS FARGO \& CO','SUNTRUST BK','RBS CITIZENS FNCL GRP','NORTHERN TR CORP','COMERICA','BMO FNCL CORP','UNIONBANCAL CORP','CITIGROUP','CAPITAL ONE FC','REGIONS FC','BANK OF NY MELLON CORP');
    
    if isunix
        pro_forma = csvread('../data/pro_forma/may9_nim_emre_luca.csv', 1, 2);
    else
        pro_forma = csvread('..\data\pro_forma\may9_nim_emre_luca.csv', 1, 2);
    end
    
    
    bank_dates = 1990:.25:2013;
    nobs = length(bank_dates);
    nbanks = length(bank_ids);
    bank_assets=pro_forma(nobs:nobs:nobs*nbanks,6);
    [tmp pos_sort]=sort(-bank_assets);
    
    bank_ids=bank_ids(pos_sort);
    bank_names = bank_names(pos_sort,:);
    
    vargout{1} = bank_ids;
    vargout{2} = bank_names;
elseif nargin == 1
    bankid = vargin;
    if isunix
        pro_forma = csvread('../data/pro_forma/may9_nim_emre_luca.csv', 1, 2);
    else
        pro_forma = csvread('..\data\pro_forma\may9_nim_emre_luca.csv', 1, 2);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %entity	nim	nim_ta roa roe assets_avg
    bank_dates = 1990:.25:2013;
    bank_nim=pro_forma(find(pro_forma(:,1)==bankid),2);
    bank_assets=pro_forma(find(pro_forma(:,1)==bankid),6);
    
    bank_dates_short = 1996:.25:2013;
    bank_nim=bank_nim(find(bank_dates==bank_dates_short(1)):end)';
    
    vargout{1} = bank_nim;
    vargout{2} = bank_dates_short;
    
else
    error('Too many inputs')
end