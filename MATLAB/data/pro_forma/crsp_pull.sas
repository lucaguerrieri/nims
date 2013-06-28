**********************************************************;
* SECTION A: Set libraries and file paths;
**********************************************************;
/*NOTE: BE SURE TO CHANGE ALL MACROS AND LIBNAMES TO YOUR FILE SYSTEM (IF NOT IN FRS). ALSO, ONCE YOU UNDERSTAND WHAT EACH STEP DOES, FEEL FREE TO DELETE THE COMMENTS THROUGHOUT THE PROGRAM. THESE ARE INTENDED FOR EASY OF USE BETWEEN MULTIPLE CREATORS.*/
%LET project = /ofs/work_mpa/m1vxb00/nim_project/MATLAB/data/pro_forma/;
%LET program = crsp_pull;


LIBNAME wks '/ofs/work_mpa/m1vxb00/nim_project/MATLAB/data/pro_forma/';
LIBNAME data '/ofs/data/crsp/';
LIBNAME output '/ofs/work_mpa/m1vxb00/nim_project/MATLAB/data/pro_forma/';
LIBNAME data2 '/ofs/work_mpa/m1vxb00/nim_project/MATLAB/data/pro_forma/';

*Specify the location of  log and lst files;
PROC PRINTTO PRINT="&project./&program..lst" LOG="&project./&program..log" NEW;
RUN;


*********************************************************;
* SECTION B: Load & clean data;
*********************************************************;
*In this step we drop unnecessary variables and observations from the CRSP dataset*;

DATA output.crsp_pull;
     SET data.crsp_raw(KEEP = COMNAM DATE PERMNO SICCD TICKER RET);
     	 FORMAT DATE MMDDYY10.;
    	    IF PERMNO<25081 THEN DELETE;
    	    IF PERMNO>25081 & PERMNO<34746 THEN DELETE;
    	    IF PERMNO>34746 & PERMNO<35044 THEN DELETE;
     	    IF PERMNO>35044 & PERMNO<35048 THEN DELETE;
     	    IF PERMNO>35048 & PERMNO<35554 THEN DELETE;
     	    IF PERMNO>35554 & PERMNO<38703 THEN DELETE;
     	    IF PERMNO>38703 & PERMNO<42906 THEN DELETE;
     	    IF PERMNO>42906 & PERMNO<47896 THEN DELETE;
     	    IF PERMNO>47896 & PERMNO<50024 THEN DELETE;
     	    IF PERMNO>50024 & PERMNO<58246 THEN DELETE;
     	    IF PERMNO>58246 & PERMNO<58827 THEN DELETE;
     	    IF PERMNO>58827 & PERMNO<59176 THEN DELETE;
     	    IF PERMNO>59176 & PERMNO<59379 THEN DELETE;
     	    IF PERMNO>59379 & PERMNO<60442 THEN DELETE;
     	    IF PERMNO>60442 & PERMNO<64995 THEN DELETE;
     	    IF PERMNO>64995 & PERMNO<66157 THEN DELETE;
     	    IF PERMNO>66157 & PERMNO<68144 THEN DELETE;
   	    IF PERMNO>68144 & PERMNO<69032 THEN DELETE;
  	    IF PERMNO>69032 & PERMNO<70519 THEN DELETE;
 	    IF PERMNO>70519 & PERMNO<71563 THEN DELETE;
	    IF PERMNO>71563 & PERMNO<72726 THEN DELETE;
  	    IF PERMNO>72726 & PERMNO<75152 THEN DELETE;
            IF PERMNO>75152 & PERMNO<81055 THEN DELETE;
   	    IF PERMNO>81055 & PERMNO<81284 THEN DELETE;
  	    IF PERMNO>81284 & PERMNO<83590 THEN DELETE;
   	    IF PERMNO>83590 & PERMNO<84129 THEN DELETE;
    	    IF PERMNO>84129 & PERMNO<87033 THEN DELETE;
    	    IF PERMNO>87033 & PERMNO<89279 THEN DELETE;
	    IF PERMNO>89279 & PERMNO<92121 THEN DELETE;
    	    IF PERMNO>92121 & PERMNO<92355 THEN DELETE;
    	    IF PERMNO>92355 THEN DELETE;
RUN;


ENDSAS;
QUIT;
