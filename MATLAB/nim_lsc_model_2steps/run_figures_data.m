
clear;

setpath;

dataset_option = 1;

[yobs, dates, yields, nims, nfactors, nothers, tau, factors,...
    shadow_bank_share_assets,...
    total_interest_earning_assets,...
    assets_depository_inst, assets_securities_notrade,...
    assets_fedfunds, assets_all_loans, assets_trading_accnts, ... 
    interest_income_to_ie_assets, interest_expense_to_ie_assets] = load_data_ml_long(dataset_option);


figure
subplot(2,1,1)
thistitle='Nims (solid) and 3-Month Yields (dashed)';
doubleplot(nims,yields(1,:),dates,thistitle)

subplot(2,1,2)
thistitle='Nims (solid) and 10-Year Yields (dashed)';
doubleplot(nims,yields(9,:),dates,thistitle)


figure
subplot(3,1,1)
thistitle='Nims (solid) and Observed Level Factor (dashed)';
doubleplot(nims,factors(1,:),dates,thistitle)


subplot(3,1,2)
thistitle='Nims (solid) and Observed Slope Factor (dashed)';
doubleplot(nims,-factors(2,:),dates,thistitle)

subplot(3,1,3)
thistitle='Nims (solid) and Observed Curvature Factor (dashed)';
doubleplot(nims,-factors(3,:),dates,thistitle)


figure
thistitle='Nims (solid) and Asset Share of Shadow Banking Sector (dashed)';
doubleplot(nims,1-shadow_bank_share_assets,dates,thistitle)
xlim([dates(1) dates(end)])

figure
thistitle = 'Interest Income (% of i.e. assets), Interest Expenses (% of i.e. assets) and the 3-month Treasury yield (RHS scale)'; 
tripleplot(interest_income_to_ie_assets, interest_expense_to_ie_assets, yields(1,:),dates,thistitle)