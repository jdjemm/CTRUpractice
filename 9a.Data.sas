dm 'log; clear; output; clear;'; /* clear log and output */

title;

%let progname = 9a.Data;
%let dir = P:\CTRU\Stats\Programming\Programming Working Group (2020 Onwards)\09 - Oct 2021 - Increasing automation\;

ods pdf file="&dir.08_SASout\&progname..pdf";

**--------------------------------------------------------------------------------;
**||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
**--------------------------------------------------------------------------------;
**                                                                                ;
**Filename.......... 9a.Data.sas                                                  ;
**                                                                                ;
**Date created...... 11/10/2021 (Alex Pitchford)                                  ;
**                                                                                ;
**Last amended......                                                              ;
**                                                                                ;
**Trial............. N/A                                                          ;
**                                                                                ;
**Analysis.......... N/A                                                          ;
**                                                                                ;
**Program purpose... To create data to used to 9b.Automation                      ;
**                                                                                ;
**Directory......... As above        	                            			  ;
**                                                                                ;
**Statistician...... Alex Pitchford                                               ;
**                                                                                ;
**SAS version....... 9.4                                                          ;
**                                                                                ;
**Datasets created.. N/A             	                                          ;
**                                                                                ;
**Output files...... Treatment, AE                                                ;
**                                                                                ;
**Reviewed by....... 11/10/2021                                                   ;
**                                                                                ;
**Date reviewed..... Alex Pitchford                                               ;
**                                                                                ;
**--------------------------------------------------------------------------------;
**||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
**--------------------------------------------------------------------------------;

**================================================================================;
**                  LIBRARIES AND FILE REFERENCES                                 ;
**================================================================================;

options bottommargin="0.4200 CM" leftmargin="0.7900 CM" 
nocenter papersize=A4 orientation=landscape
rightmargin="0.2100 CM" topmargin="0.4200 CM";

* 'Managed' SAS datasets are saved here (i.e. the datasets used in analysis);
libname x "&dir.05_SASdata";

* Permanent SAS format library;
libname library "&dir.06_SASformats";
options fmtsearch=(library) formchar="|----|+|---+=|-/\<>*";

proc format library = library;
	value mytrt 1 = "Treatment A"
				2 = "Treatment B";
	value myac 1 = "> 65"
			   2 = "<= 65";
	value mycycles 1 = "1"
				   2 = "2"
				   3 = "3"
				   4 = "4"
				   5 = "5"
				   6 = "6";
	value myyn 1 = "Yes"
				2 = "No";
run;

**================================================================================;
**                  PROGRAMMING                                                   ;
**================================================================================;

* 1. Create treatment dataset;
data _treatment;
   	infile datalines delimiter=','; 
	informat PatNo best. Trt best. Safety best. regdate DDMMYY10. rsn $ 255.;
	input PatNo Trt Safety regdate max eot rsn;
	format Trt mytrt. regdate date9. max mycycles. eot myyn.;
	datalines;
	1,1,1,01/01/2019,6,1,Completed treatment
	2,1,1,02/02/2019,6,1,Completed treatment
	3,1,1,03/03/2019,5,1,Moved sites
	4,2,1,04/04/2019,4,1,Toxicity
	5,2,1,05/05/2019,6,1,Completed treatment
	6,2,0,01/01/2020,0,2, 
	7,1,1,02/02/2020,3,2, 
	8,2,1,03/03/2020,3,2, 
	9,1,1,04/04/2020,3,2, 
	10,1,1,26/06/2020,3,2, 
;
run;

* 2. Create AE dataset;
data _ae;
	informat AE $10. trt best. pat best. grade1 best. grade2 best. grade3 best. grade4 best. grade5 best.;
	input AE trt pat grade1 grade2 grade3 grade4 grade5 ;
	format trt mytrt.;
	datalines;
	Anxiety 1 6 5 1 0 0 0
	Anxiety 2 6 3 3 0 0 0
	Confusion 1 2 1 0 0 1 0
	Confusion 2 1 0 0 0 1 0
	Anemia 1 25 10 9 4 2 0
	Anemia 2 29 15 8 5 1 0
	;
run;

* 3. Add labels;
data treatment;
	set _treatment;
	label patno = "Patient ID" trt = "Treatment allocation" safety = "Safety population indicator"
		  regdate = "Registration date" max = "Maximum number of cycles received" eot = "Has participant stopped trial treatment?";
run;

data ae;
	set _ae;
	label trt = "Treatment received" pat = "Number of patients reporting 1+ AE";
run;

**================================================================================;
**                  OUTPUT                                                        ;
**================================================================================;

data x.treatment;
	set treatment;
run;

data x.ae;
	set ae;
run;

ods pdf close;

**================================================================================;
** Save log                                                                       ;
**================================================================================;

dm 'log; file "&dir.07_SASlog\&progname..log" replace;';

**END-OF-FILE---------------------------------------------------------------------;
