function [yobs, dates, yields, nims, nfactors, nothers, tau, factors, shadow_bank_share_assets] = load_data_ml 

start_yobs = 1985.75;
end_yobs = 2008.25;
dates = start_yobs:.25:end_yobs;
%SVENY yields can be found in the 'yields' FAME db under the mnemonics in
%yields_varlist.
yields = csvread('..\data\yields_sveny_only_1985quarterly.csv', 1, 2);
dates_yields = 1985.75:.25:2013.0;
start_pos = find(dates==start_yobs);
end_pos = find(dates==end_yobs);
yields = yields(start_pos:end_pos,:)';
yields_varlist = char('SVENY0025','SVENY0050','SVENY0075','SVENY0100','SVENY0200','SVENY0300','SVENY0500', 'SVENY0700', 'SVENY1000', 'SVENY1500', 'SVENY2000', 'SVENY3000');

%Bring in Net Interest Margins from Call Report (TINY); calculated as nim_top25 =
%100*netintinc/interest earning assets (where each component in the ratio
%is calculated at each quarter based on the top 25 firms, by assets).
%nims = csvread('..\data\tiny_nims.csv', 1, 1);
%dates_nim = 1985.0:.25:2013.0;
%start_pos_nim = find(dates_nim==start_yobs);
%end_pos_nim = find(dates_nim==end_yobs);
%nims = 4*nims(start_pos_nim:end_pos_nim,1)'; %Multiply by 4 to annualize
%nims_varlist = char('nim_top25');

%Bring in shadow banking share of financial sector assets. We use it as 
%a measure of competitiveness in the banking sector.
%Shadow banking share calculated as:
%1-((FL704090005.Q+ FL734090005.Q)/((FL413065005.Q+FL674090005.Q+FL614090005.Q+FL664090005.Q+FL504090005.Q)+(FL704090005.Q+ FL734090005.Q)))
%Data comes from Flow of Funds FAME db fof.

if isunix
shadow_bank_share_assets_file = csvread('/ofs/research2/Guerrieri/valentin/data/measures_of_competitiveness/shadow_banking_share_assets.csv', 1, 1);
else
shadow_bank_share_assets_file = csvread('..\data\shadow_banking_share_assets.csv', 1, 1);
end

%This data has same dates as yields
shadow_bank_share_assets = shadow_bank_share_assets_file(start_pos:end_pos,1)';

%Bring in NIMs and subcategories of interest-earning assets. SEE pulltiny_nims.sas FILE TO SEE EXACTLY 
%WHICH CALL REPORT SERIES WERE USED TO CONSTRUCT THESE DIFFERENT SERIES. 
%Eight (8) variants of NIM are possible:
% 1. With trading assets and based on end-of-period total assets rankings
% 2. Without trading assets and based on end-of-period total assets rankings
% 3. With trading assets and based on quarterly average of total assets
% rankings (quarterly average constructed from daily data on assets)
% 4. Without trading assets and based on quarterly average of total assets
% rankings (quarterly average constructed from daily data on assets)
% 5-8. Same as above, but based on interest-earning (ie) asset rankings (rather
% than total asset rankings).

if isunix
nim_option = ['/ofs/work_mpa/m1vxb00/nim_project/MATLAB/data/data_ranked_by_total_assets/nims_assets_by_endperiod_total_assets.csv';
               '/ofs/work_mpa/m1vxb00/nim_project/MATLAB/data/data_ranked_by_total_assets/nims_assets_by_quartavg_total_assets.csv';
               '/ofs/work_mpa/m1vxb00/nim_project/MATLAB/data/data_ranked_by_ie_assets/nims_assets_by_endperiod_ie_assets.csv';
               '/ofs/work_mpa/m1vxb00/nim_project/MATLAB/data/data_ranked_by_ie_assets/nims_assets_by_quartavg_ie_assets.csv'];
else
nim_option = ['..\data\nims_assets_by_endperiod_total_assets.csv';
               '..\data\nims_assets_by_quartavg_total_assets.csv';
               '..\data\nims_assets_by_endperiod_ie_assets.csv';
               '..\data\nims_assets_by_quartavg_ie_assets.csv'];
end           
    
%Use in the nim_option field to select the series
%desired.
by_end_period_total_assets = 1;
by_quartavg_total_assets = 2;
by_endperiod_ie_assets = 3;
by_quartavg_ie_assets = 4;           
           
nim_with_trading = csvread(nim_option(by_endperiod_total_assets), 1, 1);           
nim_no_trading = csvread(nim_option(by_endperiod_total_assets), 1, 2);

%nim possibilities = [nim_with_trading_by_endperiod_total_assets;
%                     nim_no_trading_by_endperiod_total_assets;
%                     nim_with_trading_by_quartavg_total_assets;
%                     nim_no_trading_by_quartavg_total_assets;
%                     nim_with_trading_by_endperiod_ie_assets;
%                     nim_no_trading_by_endperiod_ie_assets;
%                     nim_with_trading_by_quartavg_ie_assets;
%                     nim_no_trading_by_quartavg_ie_assets];

dates_nim = 1985.0:.25:2013.0;
start_pos_nim = find(dates_nim==start_yobs);
end_pos_nim = find(dates_nim==end_yobs);
nims = 4*nim_with_trading(start_pos_nim:end_pos_nim,1)'; %Multiply by 4 to annualize
nims_varlist = char('nim_top25');

%Bring in different asset series. All are in thousands of dollars and have same dates as NIMs above.%
total_interest_earning_assets = csvread(nim_option(by_end_period_total_assets), 1, 3);
assets_depository_inst = csvread(nim_option(by_end_period_total_assets), 1, 4);
assets_securities_notrade = csvread(nim_option(by_end_period_total_assets), 1, 5);
assets_fedfunds = csvread(nim_option(by_end_period_total_assets), 1, 6);
assets_all_loans = csvread(nim_option(by_end_period_total_assets), 1, 7);
assets_trading_accnts = csvread(nim_option(by_end_period_total_assets), 1, 8);



yobs = yields; %before also had nims
nfactors = 3;
nothers = 0;
tau = [3 6 9 12 24 36 60 84 120 180 240 360];

factor1 = (yields(find(tau == 3),:)... 
           +  yields(find(tau == 24),:)...
           +  yields(find(tau == 120),:) )/3;
       
%factor1 = (yields(find(tau == 60),:));       
       
factor2 = (yields(find(tau == 3),:) - yields(find(tau == 120),:));

factor3 = ( 2*yields(find(tau == 24),:) ...
             - yields(find(tau == 120),:) ...
             - yields(find(tau == 3),:)  )*5; 

factors = [factor1; factor2; factor3];