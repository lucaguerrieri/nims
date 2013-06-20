/*******************************************************************
Author: Katie Boiles(m1kpb01)/Olya Borichevska(m1oeb00)/Valentin Bolotnyy (m1vxb00)
Date: Apr. 29, 2013
Purpose: MAY9C data on Net Interest Margins for research with Rochelle and Luca.
********************************************************************/

*******************************************************************************;
*SECTION A: Set all libraries;
*******************************************************************************;
%include '/ofs/research2/ofs_templates/BA_MACROS/antiny.sas';
%include '/ofs/research2/ofs_templates/BA_MACROS/setmay9.sas';
%include '/ofs/research2/ofs_templates/BA_MACROS/bcrmacros.sas';
%include '/ofs/research2/ofs_templates/BA_MACROS/MACRO.sas';
libname nic           '/rsma/microdata/nicua/';
libname library       '/bks/proj/cbp/sas/data/library_64';


options sasautos=('/bks/proj/cbp/sas/pgms/tiny/macros',
                  '/bks/proj/cbp/sas/pgms/uniform/macros',
                  '!SASROOT/sasautos',
                  '!SASROOT/frbmac');

*Set program name;
%let program_name = pullmay9c_nim;

*Set the project path & wks temp folder;
*NOTE: You might need to create these directories;
%let project =  /ofs/research2/Guerrieri/valentin/term_structure;
libname output "&project/data/";
libname wks  "/ofs/work_mpa/m1vxb00/sas_temp/";

/*Specify the location of your log and lst files;
PROC PRINTTO PRINT="&project/&program_name..lst" LOG="&project/&program_name..log" NEW;
RUN;*/
*******************************************************************************;
*SECTION B: Pull may9c data & format variables;
*******************************************************************************;
*Specify MAY9C items;
%let rawvars = fi01150
bck0450 bck0470 ac00600;

*OPTIONAL: Here you can rename the variables identified above;
%let may9cvars = netintinc
assets_avg assets_ie_avg assets_tr;

 /*net interest income divided by interest earning assets and trading assets */
      nim_y9 = 100*netintinc/(assets_ie_avg+assets_tr);
 /*net interest income divided by total consolidated assets */
      nim_ta = 100*netintinc/assets_avg;

*Set the start and end dates for your data pull;
%let sdate = 1997Q1;
%let edate = 2012Q3;

*Macro to pull data (DO NOT NEED TO CHANGE);
%setmay9(dates=%dateseq(&sdate.,&edate.),
	tsindex=date,
	kvars=&rawvars,
	outds=may9c_raw);


*Select specific BHCs using RSSDs;
data may9c_cut (DROP = name rssd9002 a_ci_a a_ci_b);
     set may9c_raw(rename=(%renamer1(&rawvars,&may9cvars)));

     *List the specific RSSDs;
     if entity in("1562859","1275216","1073757","3587146",
		  "1074156","2277860","1951350",
		  "1070345","2380443","1039502","1068025",
		  "2945824","2162966","1069778","3242838",
		  "1111435","1131787","1119794",
		  "1120754");
     RENAME ENTITY = entity;
     *Consumer and industrial loans in consol. office;	
     a_ci = a_ci_a + a_ci_b;
      	 		  
run;

*Merge in NIC Attributes Data to obtain bhc names;
*Only keep certain variables and the most recent observations for each bhc;
data nic_attr; 
     set nic.attr(KEEP=id_rssd  d_dt_end nm_short); 
     *We only want the most recent bhc name--specified by 12/31/9999;
     if d_dt_end GE '31dec9999'd;
     RENAME nm_short = entity_name;
     run;
proc sql;
     create table may9c_chg_off_raw (KEEP = date entity: net_chg: a_: ) as
     select may9c.*, 
     	    attr.*
     from may9c_cut may9c left join nic_attr attr
     	  on (may9c.entity = attr.id_rssd);
quit;	 

*Reorder the variables for output;
DATA may9c_chg_off;
     RETAIN date entity entity_name;
     SET may9c_chg_off_raw;
RUN;
PROC SORT DATA = may9c_chg_off;
     BY entity date;
     RUN;


*B4. Output raw data into a csv file;
proc export data=may9c_chg_off
     	    outfile="&project/data/y9c_nims.csv" 
	    dbms=csv 
	    replace; 
run;  


ENDSAS;
