/*******************************************************************
Author: Michelle Welch (m1mrh02); Updated by Valentin Bolotnyy (m1vxb00)
Date: March 28, 2012; Date Updated: November 20, 2012.
Purpose: Pull Merger adjusted Y-9C (May9C) data from Banking Analysis
Output: may9c_matchange.sas7bdat

NOTE: nonintinc_tr_tra == the return on trading assets. You might see this
labeled as return_tradingassets in other spreadsheets.
********************************************************************/
/* Old "Include" references;
*%include './Include/library';
*%include './Include/bcrmacros.sas';
*%include './Include/PDMACRO.sas';
*%include './Include/setmay9.sas';
*%include './Include/settiny.sas';
*/
* DO NOT CHANGE ANYTHING IN THIS SUBSECTION;
%include '/ofs/research2/ofs_templates/BA_MACROS/antiny.sas';
%include '/ofs/research2/ofs_templates/BA_MACROS/settiny.sas';
%include '/ofs/research2/ofs_templates/BA_MACROS/bcrmacros.sas';
%include '/ofs/research2/ofs_templates/BA_MACROS/MACRO.sas';
%include '/ofs/research2/ofs_templates/BA_MACROS/setmay9.sas';

libname nic           '/rsma/microdata/nicua/';
libname tiny          '/bks/proj/cbp/sas/data/tiny';
libname tiny80        '/bks/proj/cbp/sas/data/tiny/tiny80';
libname tiny90        '/bks/proj/cbp/sas/data/tiny/tiny90';
libname library       '/bks/proj/cbp/sas/data/library_64';

*This is the output directory*;
libname out '/ofs/prod1/CCAR/material_change/data';

options sasautos=('/bks/proj/cbp/sas/pgms/tiny/macros',
                  '/bks/proj/cbp/sas/pgms/uniform/macros',
                  '!SASROOT/sasautos',
                  '!SASROOT/frbmac');

* CHANGE THINGS BELOW AS NECESSARY;

%let fpath = /ofs/work_mpa/m1vxb00/nim_project/MATLAB/data/data_ranked_by_ie_assets/;
libname ccar2012 "&fpath";

%let sdate = 1997q1;
%let edate = 2013q1; *Change this as necessary*;
*retrieve MAY9 data;
%let mvars = bck0450 ack0450 bck0470 ack0470 ac00600
             bc01950 bcr0400 acr0400 bcr0410 bcr4175
             fi01150 fi02000 fi02400 fi01350
             ac00500 fi01200
             fia0500 fia0590
	     fi02250 fi02300 fi02600
	     fi02150 fi02200
             ac01100 ac01200
	     bcc1800 bck0140
             acc0850 acc0075 acc0400 acc0425 
             acc0250 acc0275 acc0300 acc0350 
             acc0975 acc1000 acc1025
             fib2210
             fib1345 fib0045 fib0725 fib0745
	     fib0425 fib0445 fib0525 fib0625
	     fib1540 fib1601 fib1607 fi00500
             ;

%let rmvars = assets assets_avg assets_ie assets_ie_avg assets_tr 
              equity tier1 tier1_avg tier1c rwa
              netintinc nonintinc nonintexp nonintinc_tr
              alll_lvl lllp_lvl
              tstock_prchs dividends
	      impair_gw impair_oint inc_extra
	      nonintexp_comp nonintexp_prop
              dep_dom dep_fgn 
              loans loans_avg 
              loans_ci loans_cld loans_mfam loans_nfnr 
              loans_heloc loans_sfam loans_sfam_l1 loans_sfam_l2
              loans_cons loans_cc loans_consxcc
              nchg
              nchg_ci nchg_cld nchg_mfam nchg_nfnr
	      nchg_heloc nchg_sfam nchg_sfam_l1 nchg_sfam_l2
	      nchg_cons nchg_cc nchg_consxcc inc_tr_assets   
              ;

*nchg = total net charge-offs;
*nchg_ci = charge-offs on commercial and industrial loans;
*nchg_cld = charge-offs on loan loans;
*nchg_mfam = on multi-family properties;
*nchg_nfnr = on non-farm nonresidential properties (commercial?);
*nchg_heloc = on single-family properties, revolving open-end loans;
*nchg_sfam = on single-family properties;
*nchg_sfam_l1 = on closed-end single-family properties secured by first lien;
*nchg_sfam_l2 = on closed-end single-family properties secured by junior liens;
*nchg_cons = on consumer loans;
*nchg_cc = on credit card loans;
*nchg_consxcc = on consumer loans, excluding credit card loans;

%setmay9(dates=%dateseq(&sdate,&edate),tsindex=date,kvars=&mvars,outds=may9_raw);
data may9; set may9_raw(rename=(%renamer1(&mvars,&rmvars))); run;
proc sort data=may9; by entity date; run;

 *keep only domestic banks;
data attr; 
     set nic.attr(keep=id_rssd d_dt_start d_dt_end domestic_ind nm_short); 
run;

proc sql;
  create table may9c_dm as
  select t.*, a.*
  from may9 t left join attr a on (t.entity=a.id_rssd)
  where (d_dt_start <= date <= d_dt_end and domestic_ind="Y");
quit;


*keep only top 25 BHCs;
proc sort data=may9c_dm; by date descending assets_ie_avg; run;
data may9c_bhc25(where=(rank<=25));
  set may9c_dm;
  by date;
  if first.date then rank=1; 
  else rank+1;
  retain rank;
run;

*aggregate May9c data;
proc univariate noprint data=may9c_bhc25;
  by date;
  var &rmvars;
  output out=may9c_agg25 sum=&rmvars;
run;

*eliminate erroneous charge-off rates;
data may9c_agg25;
  set may9c_agg25;
  %replace_num(0,.);
run;
/*construct financial variables*/
data may9c_vars;
      set may9c_agg25;
*      nonintinc_xtr = sum(nonintinc,-nonintinc_tr);
*      nonintexp_xgw = sum(nonintexp,-impair_gw);
*      nonintexp_oth = sum(nonintexp,-nonintexp_comp,-nonintexp_prop,-impair_gw,-impair_oint);
*      ppnr_y9 = 100*sum(netintinc,nonintinc,-nonintexp)/assets_avg;
*      ppnr_base = 100*sum(netintinc,nonintinc,-nonintexp,impair_gw,impair_oint,-inc_extra)/assets_avg;
*      ppnr_xtr = 100*sum(netintinc,nonintinc_xtr,-nonintexp)/assets_avg;  
*      nonintinc_xtr_ta = 100*nonintinc_xtr/assets_avg;
*      nonintinc_tr_ta = 100*nonintinc_tr/assets_avg;
*      nonintinc_tr_tra = 100*nonintinc_tr/assets_tr;

      nim_with_tr_assets_y9 = 100*netintinc/(assets_ie_avg+assets_tr);

      nim_ta = 100*netintinc/assets_avg;
*      nonintexp_comp_ta = 100*nonintexp_comp/assets_avg;
*      nonintexp_prop_ta = 100*nonintexp_prop/assets_avg;
*      nonintexp_oth_ta = 100*nonintexp_oth/assets_avg;
*      deps = 100*sum(dep_dom,dep_fgn)/assets_avg;
*      payout = sum(dividends,tstock_prchs);
*      alll = 100*alll_lvl/loans_avg;
*      lllp_y9 = 100*lllp_lvl/loans_avg;
*      tier1cr = tier1c/rwa;
*      chgoff_y9 = 100*nchg/loans_avg;
*      chgoff_ci_y9 = 100*nchg_ci/loans_ci;
*      chgoff_cre_y9 = 100*(sum(nchg_cld,nchg_mfam,nchg_nfnr)/sum(loans_cld,loans_mfam,loans_nfnr));
*      chgoff_cld_y9 = 100*nchg_cld/loans_cld;
*      chgoff_mfam_y9 = 100*nchg_mfam/loans_mfam;
*      chgoff_nfnr_y9 = 100*nchg_nfnr/loans_nfnr;
*      chgoff_heloc_y9 = 100*nchg_heloc/loans_heloc;
*      chgoff_sfam_y9 = 100*nchg_sfam/loans_sfam;
*      chgoff_sfam_l1_y9 = 100*nchg_sfam_l1/loans_sfam_l1;
*      chgoff_sfam_l2_y9 = 100*nchg_sfam_l2/loans_sfam_l2;
*      chgoff_cons_y9 = 100*nchg_cons/loans_cons;
*      chgoff_cc_y9 = 100*nchg_cc/loans_cc;
*      chgoff_consxcc_y9 = 100*nchg_consxcc/loans_consxcc;
*      exposure_ci_y9 = 100*loans_ci/assets_ie_avg;
*      exposure_cre_y9 = 100*sum(loans_cld,loans_mfam,loans_nfnr)/assets_ie_avg;
*      exposure_rre_y9 = 100*sum(loans_heloc,loans_sfam_l1,loans_sfam_l2)/assets_ie_avg;
*      exposure_cc_y9 = 100*loans_cc/assets_ie_avg;
*      exposure_othcons_y9 = 100*sum(loans_cons,-loans_cc)/assets_ie_avg;
*      exposure_tr_y9 = 100*assets_tr/assets_ie_avg;

run;

  

/*seasonally adjust series;
%let svars = ppnr nim netinc_ptax nonintinc_net nonintinc nonintexp 
             nonintinc_xtr nonintinc_tr nonintexp_comp nonintexp_prop nonintexp_oth
             tier1r lllp chgoff
             chgoff_ci chgoff_cre chgoff_cld chgoff_mfam chgoff_nfnr 
             chgoff_rre chgoff_heloc chgoff_sfam chgoff_cc chgoff_othcons chgoff_oth;
proc x12 noprint data=tiny_agg25 date=date interval=qtr;
  var &svars;
  x11 mode=add;
  output out=seasonal d11;
run;

%let svars_nsa = %varsfx(&svars,_nsa);
data tiny_agg25_sa;
  merge seasonal(rename=(%renamer1(%varsfx(&svars,_D11),&svars)))
        tiny_agg25(rename=(%renamer1(&svars,&svars_nsa)));
  by date;
run;
*/

  *output;
  data ccar2012.may9c_nims; set may9c_vars; run;
  proc export data=may9c_vars outfile="&fpath./may9c_nims_by_quartavg_ie_assets.csv" dbms=csv replace; run;  

endsas;
