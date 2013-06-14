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
nims = csvread('..\data\tiny_nims.csv', 1, 1);
dates_nim = 1985.0:.25:2013.0;
start_pos_nim = find(dates_nim==start_yobs);
end_pos_nim = find(dates_nim==end_yobs);
nims = 4*nims(start_pos_nim:end_pos_nim,1)'; %Multiply by 4 to annualize
nims_varlist = char('nim_top25');

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