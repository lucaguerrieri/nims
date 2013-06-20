/*******************************************************************
Author: Michelle Welch (m1mrh02)
Date: March 28, 2012
Purpose: Pull Merger adjusted Call Report (TINY) data from Banking Analysis
Output: tiny_matchange.sas7bdat
To run: in a command line, type sas pulltiny.sas
********************************************************************/

/*
%include './Include/library';
%include './Include/bcrmacros.sas';
%include './Include/PDMACRO.sas';
%include './Include/setmay9.sas';
%include './Include/settiny.sas';
*/

/* Keep these "include" statements and all libname statements below */

%include '/ofs/research2/ofs_templates/BA_MACROS/antiny.sas';
%include '/ofs/research2/ofs_templates/BA_MACROS/settiny.sas';
%include '/ofs/research2/ofs_templates/BA_MACROS/bcrmacros.sas';
%include '/ofs/research2/ofs_templates/BA_MACROS/MACRO.sas';

libname nic           '/rsma/microdata/nicua/';
libname tiny          '/bks/proj/cbp/sas/data/tiny';
libname tiny80        '/bks/proj/cbp/sas/data/tiny/tiny80';
libname tiny90        '/bks/proj/cbp/sas/data/tiny/tiny90';
libname library       '/bks/proj/cbp/sas/data/library_64';
/*libname out           '/ofs/prod1/CCAR/material_change/data'; */

options sasautos=('/bks/proj/cbp/sas/pgms/tiny/macros',
                  '/bks/proj/cbp/sas/pgms/uniform/macros',
                  '!SASROOT/sasautos',
                  '!SASROOT/frbmac');

%let fpath = /ofs/work_mpa/m1vxb00/nim_project/MATLAB/data/;
/* /ofs/research2/Guerrieri/valentin/term_structure/data; */
libname output "&fpath";

%let sdate = 1985q1;
%let edate = 2013q1;

*retrieve TINY data;
%let tvars = flo10300 flo10600 /*total interest income; interest income on loans and leases */
             flo10900 flo11100
             flo11200 flo11400
             flo11700 flo11900
             flo10600 flo12000
             flo12100 flo12500
             flo13400 flo12400
             flo13410 
             flo20100
             flo15700 flo15800
             flo16200 flo16300
             flo16500 flo15300
             cal90100 cal25000 /*interest-earning assets breakdown starts on this line */
             cal90200 cal90300
             cal90900 cal91000
             cal91900

		;

/* cal25000 cal90000 cal90100 /*assets_end_of_period assets assets_interest_earning*/
/*  flo20100  /*netintinc */


%settiny(dates=%dateseq(&sdate,&edate),tsindex=date,kvars=rssd9002 &tvars,outds=tiny_raw);
data tiny; set tiny_raw; if rssd9002=. then rssd9002=entity; run;

*keep only domestic banks;
data attr; set nic.attr(keep=id_rssd d_dt_start d_dt_end domestic_ind); run;
proc sql;
  create table tiny_dm as
  select t.*, a.*
  from tiny t left join attr a on (t.entity=a.id_rssd)
  where (d_dt_start <= date <= d_dt_end and domestic_ind="Y")
  ;
quit;

*rollup to BHC level;
proc sort data=tiny_dm; by date rssd9002; run;
proc univariate noprint data=tiny_dm;
  by date rssd9002;
  var &tvars;
  output out=tiny_bhc sum=&tvars;
run;

*keep only top 25 BHCs, by quarter;
proc sort data=tiny_bhc; by date descending cal25000; run;
data tiny_bhc25(where=(rank<=25));
  set tiny_bhc;
  by date;
  if first.date then rank=1; 
  else rank+1;
  retain rank;
run;

*aggregate TINY data;
proc univariate noprint data=tiny_bhc25;
  by date;
  var &tvars;
  output out=tiny_agg25 sum=&tvars;
run;

*eliminate erroneous data;
data tiny_agg25;
  set tiny_agg25;
  %replace_num(0,.);
run;
  
*calculate net interest margin ratio;
data tiny_agg25(drop=&tvars);
  set tiny_agg25;
  total_assets_top25 = cal25000;
  interest_earning_assets_top25 = cal90100;
  total_interest_expense_top25 = flo15300;
  total_interest_inc_top25 = flo10300;
  net_interest_income_top25 = flo20100;
  nim_top25 = 100*flo20100/cal90100;
  loans_real_estate_top25 = flo10900;
  loans_agr_top25 = flo11100;
  loans_ci_top25 = flo11200;
  loans_consumer_top25 = flo11400;
  loans_foreign_top25 = flo11700;
  loans_other_dom_top25 = flo11900;
  lease_financing_top25 = flo12000;
  inc_depository_inst_top25 = flo12100;
  inc_on_securities_top25 = flo12500;
  inc_trading_assets_top25 = flo13400;
  inc_fedfunds_top25 = flo12400;
  other_interest_inc_top25 = flo13410;
  expense_trans_accnts_top25 = flo15700;
  expense_nontrans_accnts_top25 = flo15800;
  expense_fedfunds_top25 = flo16200;
  expense_trade_liab_top25 = flo16300;
  expense_sub_debt_top25 = flo16500;
  assets_depository_inst_top25 = cal90200;
  assets_securities_notrade_top25 = cal90300;
  assets_fedfunds_top25 = cal90900;
  assets_all_loans_top25 = cal91000;
  assets_trading_accnts_top25 = cal91900;
run;

  *output;
  data output.tiny_nims; set tiny_agg25; run;
  proc export data=tiny_agg25 outfile="&fpath./nims_income_expenses_assets.csv" dbms=csv replace; run;  

endsas;
