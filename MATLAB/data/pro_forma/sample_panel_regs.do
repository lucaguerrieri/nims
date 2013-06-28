/*****************************************************************************************************
* This file was written by Valentin Bolotnyy (OFS)
* to do basic panel regressions of 
* pro-forma NIMs (as constructed in Banking Analysis by Emre Yoldas and Michael Zhang)
* on yields (SVENY yields can be found in the 'yields' FAME db
* under the mnemonics SVENYXXXX where SVENY0025 is a 3-month yield and SVENY1000 is a 10-year yield).
*
* LAST UPDATED: June 28, 2013
******************************************************************************************************/

clear all
# delimit;

/* 
* NIM DATA FOR ALL FIRMS STARTS ON 1996Q3, EXCEPT FOR:
* American Express (firmnum = 2) data starts in 2009Q1;
* Ally Financial (firmnum = 1) data starts in 2009Q1;
* Morgan Stanley (firmnum = 19) data starts in 2009Q1;
* Goldman Sachs (firmnum = 13) data starts in 2009Q1;
* HSBC (firmnum = 14) data starts in 2004Q1;
* Discover (firmnum = 11) data starts in 2009Q1;
* Santander (firmnum = 24) data starts in 2012Q1;
*/

/*
* Variable definitions: 
* nim = 400*netintinc/(assets_ie_avg+assets_tr)
* nim_ta = 400*netintinc/assets_avg
* 
* netintinc = net interest income
* assets_ie_avg = interest-earning assets, quarterly average
* assets_tr = trading assets (quarterly average? endperiod?)
* assets_avg = total assets, quarterly average
*
* use the nim variable
*/

cd "/ofs/work_mpa/m1vxb00/nim_project/MATLAB/data/pro_forma/";
insheet using "/ofs/work_mpa/m1vxb00/nim_project/MATLAB/data/corporate_spread_quarterly_shadow_banking_share.csv";
gen idate = yq(year, quarter);
order idate, after(quarter);
save corporate_spread_quarterly_shadow_banking_share.dta, replace;
clear all;

insheet using "/ofs/work_mpa/m1vxb00/nim_project/MATLAB/data/pro_forma/may9_nim_emre_with_yields.csv";
gen idate = yq(year, quarter);
order idate, after(date);

merge m:1 idate using corporate_spread_quarterly_shadow_banking_share.dta;
drop _merge;
drop if idate<yq(1990,1);

xtset entity idate;
save may9_nim_emre_yields_corp_spread_shadow_bank_share.dta, replace;

/* Drop these firms if you want a balanced panel -- see comment at top */
drop if firmnum == 2 | firmnum == 1 | firmnum == 19 | firmnum == 13 | firmnum == 14 | firmnum == 11 | firmnum == 24;

/* This regression is a KEEPER. Balanced panel, with data starting in 1996Q3. 65 observations per series */
xtreg nim l1.nim l1.sveny0025 l1.sveny1000 l1.shadow_banking_share_assets, fe vce(robust);


