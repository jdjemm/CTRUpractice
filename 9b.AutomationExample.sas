dm 'log; clear; output; clear;'; /* clear log and output */

title;

%let progname = 9b_AutomationExample;
%let dir = P:\CTRU\Stats\Programming\Programming Working Group (2020 Onwards)\09 - Oct 2021 - Increasing automation\;

**--------------------------------------------------------------------------------;
**||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
**--------------------------------------------------------------------------------;
**                                                                                ;
**Filename.......... 9b.AutomationExample.sas                                     ;
**                                                                                ;
**Date created...... 12/10/2021 (Alex Pitchford)                                  ;
**                                                                                ;
**Last amended......                                                              ;
**                                                                                ;
**Trial............. N/A                                                          ;
**                                                                                ;
**Analysis.......... N/A                                                          ;
**                                                                                ;
**Program purpose... To give examples of automation of a safety report            ;
**                                                                                ;
**Directory......... As above        	                            			  ;
**                                                                                ;
**Statistician...... Alex Pitchford                                               ;
**                                                                                ;
**SAS version....... 9.4                                                          ;
**                                                                                ;
**Datasets created.. N/A             	                                          ;
**                                                                                ;
**Output files...... N/A                                                          ;
**                                                                                ;
**Reviewed by....... 12/10/2021                                                   ;
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

* Table macro;
%include "&dir.09_sasprogs\freqmacro_v3.sas";

* Macro to clear all titles and footnotes;
%macro clear1;
	title; 
	footnote; 
%mend;

**================================================================================;
**                  DATASETS                                                      ;
**================================================================================;

data ae;
	set x.ae;
run;

data treatment;
	set x.treatment;
run;

**================================================================================;
**                  PROGRAMMING                                                   ;
**================================================================================;

* 0. Prepare a table for output;
* First remove pt not in safety pop;
data treatment_final;
	set treatment (where = (safety=1));
run;

* Number of cycles of treatment received;
%freqany(dset=treatment_final,catvar=max,catall=n,trtvar=trt,trtall=n,tot=n, tabout=out1,header=y);

* 1. Example of ods text;
* Each p represents a new paragraph;
proc odstext;
p "1. Accrual";
p "1st participant registered into MUK nine B: 13th November 2017";
run;

* We can add more style if we do this using ods escapechar;
ods escapechar="^";
proc odstext;
p "^{style [textdecoration=underline fontweight=bold]1. Accrual}";
p "1^{super st} participant registered into MUK nine B: 13^{super th} November 2017";
run;

* 2. Add in macros;
* Macros- to update each time;
%let cutoff = 17^{super th} May 2021; * Update with cut-off date for data download;
%let report = tenth; * Update with safety report no. (lower case only);
%let dmecrep = three; * Update with no. of annual DMEC reports (lower case only);
%let prev_cutoff = "05MAY2019"d; * Update with date of previous data cut-off;
%let cutoff_d = "17MAY2021"d; * Update with cut-off date for data download;

* Macros that will update automatically;
proc sql noprint ;
/* Number of registered pts */
	select trim(put(count(distinct patno),2.)) 
		into: rega from treatment;
/* Number of registered pts to each treatment allocation */
	select trim(left(put(Trt,mytrt.))), compress(put(count(distinct patno),best.))
		into :pop1-:pop2,:tot1-:tot2 from treatment group by trt;
/* Number of new registrations between reports */
	select trim(put(count(distinct patno),1.)) 
		into: regb from treatment where regdate gt &prev_cutoff and regdate le &cutoff_d;
/* Number in safety pop */
	select trim(put(count(distinct patno),1.)) 
		into: safeo from treatment where safety = 1;
/* Number in safety pop by treatment */
	select trim(put(count(distinct patno),1.)) 
		into: safe1-:safe2 from treatment where safety = 1 group by trt;
/* Number of pts who received all 6 cycles of treatment */
	select trim(put(count(distinct patno),1.)) 
		into: six from treatment where safety = 1 and max = 6;
quit;

* Using odstext and macro variables;
proc odstext;
p "^{style [textdecoration=underline fontweight=bold]1. Accrual}"/style=[font=font('calibri')];
p "1^{super st} participant registered into MUK nine B: 13^{super th} November 2017
					^{newline 1}Cut-off date for report: &cutoff.
					^{newline 2}Number of MUK nine B registrations: &rega. (&pop1.: &tot1., &pop2.: &tot2.).
					^{newline 1}Number of MUK nine B registrations since last cut-off date: &regb..
					^{newline 2}This is the &report DMEC safety report for the MUK nine trial. The DMEC have also reviewed &dmecrep full annual reports.
					^{newline 2}^{style [textdecoration=underline font_weight = bold]Trial design}
					^{newline 2}MUK nine is a screening (MUK nine A) and single arm phase II (MUK nine B) trial, evaluating optimised combination of biological therapy in newly 
 diagnosed high risk multiple myeloma and plasma cell leukaemia. Participants are entered into MUK nine A to determine their risk status, and high risk 
 participants are entered into MUK nine B to receive treatment with Cyclophosphamide, Bortezomib, Lenalidomide, Daratumumab and Dexamethasone (CVRDd), 
 followed by autologous stem cell transplant, consolidation with VRDd -> VRD, and maintenance with RD.";
run;
*Use ^{newline 1}For a new line within the same paragraph;
*Use ^{newline 2}For a new line and a new paragraph;

* 3. Title page;
/* Create a data set containing the desired title text */
data text1;
   obs =1;
	text="Safety report";
run;

data text2;
	obs = 2;
   text="Report prepared by: Alex Pitchford (Trial statistician) and Andrew Hall (supervising statistician)";
run;

* Combine;
data text_final;
length text $ 255.;
	set text1 text2;
run;

*=================================================================================;
* Report
*=================================================================================;

ods listing close;
options papersize=A4 orientation=portrait;

ods rtf file= "&dir.02_Output\&progname..rtf" headery=1 footery=1
bodytitle startpage = no notoc_data; /* Add notoc_data to prevent automatic TOC */
ods escapechar="^";
title; run;
%clear1; /* Macro to clear all titles and footnotes */

*title page;
/* insert a logo and blank lines (used to move the title text to the center of page) */
title " "; 
title10 j=c '^S={preimage="&dir.01_prog_notes/mukninelogo.png"}';
footnote1 j=c "Confidential";
ods rtf text="^20n";

/* output the title text */
proc report data=text_final noheader style(report)={rules=none frame=void} 
     style(column)={font_weight=bold font_size=14pt just=c};
	 column (text);
run;
%clear1;

*Table of contents;
ods rtf startpage=now; 
ods rtf text = "^S={font_size=12pt font_weight=bold just=c}Table of Contents";
ods rtf text = "^S={outputwidth=100% just=l}{\field{\*\fldinst {\\TOC \\f \\h}}}"; 

* 1. ACCURAL;
ods rtf startpage=now; /* Add a new page */
ods rtf text = "^S={outputwidth=100% just=l} {\f3\fs0\cf8\tc 1. Accrual}"; /* Reference for table of contents */

proc odstext;
p "^{style [textdecoration=underline fontweight=bold]1. Accrual}";
p "1^{super st} participant registered into MUK nine B: 13^{super th} November 2017
					^{newline 1}Cut-off date for report: &cutoff.
					^{newline 2}Number of MUK nine B registrations: &rega. (&pop1.: &tot1., &pop2.: &tot2.).
					^{newline 1}Number of MUK nine B registrations since last cut-off date: &regb..
					^{newline 2}This is the &report DMEC safety report for the MUK nine trial. The DMEC have also reviewed &dmecrep full annual reports.
					^{newline 2}^{style [textdecoration=underline font_weight = bold]Trial design}
					^{newline 2}MUK nine is a screening (MUK nine A) and single arm phase II (MUK nine B) trial, evaluating optimised combination of biological therapy in newly 
 diagnosed high risk multiple myeloma and plasma cell leukaemia. Participants are entered into MUK nine A to determine their risk status, and high risk 
 participants are entered into MUK nine B to receive treatment with Cyclophosphamide, Bortezomib, Lenalidomide, Daratumumab and Dexamethasone (CVRDd), 
 followed by autologous stem cell transplant, consolidation with VRDd -> VRD, and maintenance with RD.";
run;

* 2. TREATMENT RECEIVED;
ods rtf startpage=now;
ods rtf text = "^S={outputwidth=100% just=l} {\f3\fs0\cf8\tc 2. Treatment received}"; /* Reference for table of contents */
proc odstext;
p "^{style[textdecoration=underline fontweight=bold]2. Treatment received}";
p "A total of &safeo. received at least one dose of trial treatment; &safe1. allocated to &pop1., &safe2. allocated to
&pop2.. The following summaries will therefore be out of these &safeo. participants." /style=[font=font('calibri')];
p "";
p "Table 2.1 below shows the number of cycles of chemotherapy received by arm as of &cutoff.. A total of &six. participants have
received all 6 cycles of chemotherapy.";
run;

proc report data=Out1 headskip nowindows split="#"
style(report)=[cellspacing=1 borderwidth=4 bordercolor=black just=left rules=groups] 
style(column)=[fontsize=10pt] 
style(header)=[fontsize=10pt background=CXBFBFBF] 
style(lines)=[background=white];
column (label Var1 Var2 tot);
define label / left style(column)={cellwidth=6cm} "";
define Var1 / center style(column)={cellwidth=2.8cm} "&pop1. (n=&safe1.)";
define Var2 / center style(column)={cellwidth=2.8cm} "&pop2. (n=&safe2.)";
define tot / center style(column)={cellwidth=2.8cm} "Overall (n=&safeo.)";
*to highlight the total row in bold;
compute label;
if _c1_="Total" then call define(_row_,"STYLE","style={fontweight=bold}");
endcomp;
title3 height=2 bold justify=left
"Table 2.1: Number of cycles of chemotherapy received, by arm";
run;

ods rtf close;

**================================================================================;
** Save log                                                                       ;
**================================================================================;
dm 'output; file "&dir.07_sasout\&progname..lst" replace;';  
dm 'log; file "&dir.07_saslog\&progname..log" replace;';

**END-OF-FILE---------------------------------------------------------------------;
