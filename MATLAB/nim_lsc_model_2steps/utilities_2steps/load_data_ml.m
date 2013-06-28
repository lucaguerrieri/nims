function [yobs, dates, yields, nims, nfactors, nothers, tau, factors,...
    shadow_bank_share_assets,...
    total_interest_earning_assets,...
    assets_depository_inst, assets_securities_notrade,...
    assets_fedfunds, assets_all_loans, assets_trading_accnts, ... 
    varargout] = load_data_ml(varargin)

% dataset_option can take the following values:
% 1  -- BHCs are selected by quarter-end period total assets
% 2  -- BHCs are selected by quarter-average total assets
% 3  -- BHCs are selected by quarter-end interest earning assets
% 4  -- BHCs are selected by quarter-average interest earning assets
if nargin == 0
    dataset_option = 1;
else
    dataset_option = varargin{1};
end

nim_dataset_titles = char('nims_assets_by_endperiod_total_assets.csv',...
    'nims_assets_by_quartavg_total_assets.csv',...
    'nims_assets_by_endperiod_ie_assets.csv',...
    'nims_assets_by_quartavg_ie_assets.csv');

if (dataset_option == 1 | dataset_option == 2)
    nim_dataset_path = ['../data/data_ranked_by_total_assets/',nim_dataset_titles(dataset_option,:)];
else
    nim_dataset_path = ['../data/data_ranked_by_ie_assets/',nim_dataset_titles(dataset_option,:)];
end

if ~isunix
    nim_dataset_path = strrep(nim_dataset_path,'/','\');
end



start_yobs = 1985.75;
end_yobs = 2008.25;
dates = start_yobs:.25:end_yobs;
%SVENY yields can be found in the 'yields' FAME db under the mnemonics in
%yields_varlist.
if isunix
    yields = csvread('../data/yields_sveny_only_1985quarterly.csv', 1, 2);
else
    yields = csvread('..\data\yields_sveny_only_1985quarterly.csv', 1, 2);
end
dates_yields = 1985.75:.25:2013.0;
start_pos = find(dates==start_yobs);
end_pos = find(dates==end_yobs);
yields = yields(start_pos:end_pos,:)';
yields_varlist = char('SVENY0025','SVENY0050','SVENY0075','SVENY0100',...
    'SVENY0200','SVENY0300','SVENY0500', 'SVENY0700',...
    'SVENY1000', 'SVENY1500', 'SVENY2000', 'SVENY3000');

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
    shadow_bank_share_assets_file = ...
        csvread('../data/measures_of_competitiveness/shadow_banking_share_assets.csv', 1, 1);
else
    shadow_bank_share_assets_file = ...
        csvread('..\data\shadow_banking_share_assets.csv', 1, 1);
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

nim_data = csvread(nim_dataset_path, 1, 1);
nim_varlist = char('nim_with_trading','nim_no_trading','total_interest_earning_assets',...
                   'assets_depository_inst','assets_securities_notrade','assets_fedfunds',...
                   'assets_all_loans','assets_trading_accnts');

dates_nim = 1985.0:.25:2013.0;
start_pos_nim = find(dates_nim==start_yobs);
end_pos_nim = find(dates_nim==end_yobs);
               
n_nim_varlist = size(nim_varlist,1);

for nim_indx = 1:n_nim_varlist
    eval([nim_varlist(nim_indx,:),'=transpose(nim_data(start_pos_nim:end_pos_nim,nim_indx));']);
end

%Multiply by 4 to annualize
nim_with_trading = nim_with_trading*4;
%nim_no_trading = nim_no_trading*4;

nims = nim_with_trading; 


if dataset_option == 1
    subcomponent_path = '..\data\data_ranked_by_total_assets\nims_subcomponents_by_endperiod_total_assets.csv';
    if ~isunix
        subcomponent_path = strrep(subcomponent_path,'/','\');
    end

    additional_data  = csvread(subcomponent_path, 1, 9);
    
    total_ie_assets = additional_data(:,1);
    interest_income = additional_data(:,2);
    interest_expense =additional_data(:,3);
    
    interest_income_to_ie_assets = interest_income*4./total_ie_assets*100;
    interest_expense_to_ie_assets = interest_expense*4./total_ie_assets*100;
    
    varargout{1} = transpose(interest_income_to_ie_assets(start_pos_nim:end_pos_nim));
    varargout{2} = transpose(interest_expense_to_ie_assets(start_pos_nim:end_pos_nim));

end

               



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


%Bring in different asset series. All are in thousands of dollars and have same dates as NIMs above.




