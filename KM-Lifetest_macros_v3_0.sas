**--------------------------------------------------------------------------------;
**||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
**--------------------------------------------------------------------------------;
**                                                                                ;
**Filename..........KM-Lifetest_macros_v3_0.sas                                   ;
**                                                                                ;
**Date created......13FEB2012                                                     ;
**                                                                                ;
**Last amended......                                                              ;
**                                                                                ;
**Trial............. Standard Program                                             ;
**                                                                                ;
**Analysis..........                                                              ;
**                                                                                ;
**Program purpose...Perform Kaplan-Meier survival analysis and produce survival 
						plot                                                      ;
**                                                                                ;
**Directory.........P:\CTRU\Stats\Programming\SAS\Programs\Graphics\KM-Lifetest   ;
**                                                                                ;
**Statistician......Colin Everett                                         		  ;
**                                                                                ;
**SAS version.......9.2 (NT)                                                      ;
**                                                                                ;
**Datasets created..                                                              ;
**                                                                                ;
**Output files......                                                              ;
**                                                                                ;
**Reviewed by.......                                                              ;
**                                                                                ;
**Date reviewed.....                                                              ;
**                                                                                ;
**--------------------------------------------------------------------------------;
**||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||;
**--------------------------------------------------------------------------------;
** MACRO: MAINLIFETEST
** Variable		Reqd (Default)	Description
** DSIN			Y				Input survival analysis dataset
** STRATUM		N (randtrt)		Stratifying variable, to produce separate curves
** ATRISKRANGE	N 				Values to compute the numbers of patients at risk
** TimeToEvent	Y				The variable that contains the Event Time values
** Censoring	Y				The variable that denotes a censored or event 
								observation.
								This must inlcude the value of a censored 
								observation.
								eg: censoring=EvtOcc(0),
** CITimes		N				Timepoints at which to produce confidence intervals
								for the survival function. This is the time at which
								the intervals are calculated. They can be staggered
								for plotting purposes in another macro.
** StopPlot		N				The time at which the survival graph is forcibly
								curtailed.
** test			N (LOGRANK)		The stratum homogeneity test. Can be one of LR, PETO
								MODPETO WILCOXON TARONE LOGRANK FLEMING(p,q). The
								default labeling can be replaced on the plot by
								using the following parameter structure:
								test = %str(logrank=Log-Rank Test),
								Which labels the output from a log-rank test with 
								the string "Log-Rank Test", rather than the SAS 
								default of "Logrank"
** UpsideDown	N (0)			If this equals Y or 1, then the plot and confidence
								intervals are of cumulative incidence or failure,
								obtained using the transformation 1 - S(t).;
** ---------------------------------------------------------------------------------
** MACRO: SPLIOT
** CISpacing	N (0)			The amount by which the confidence intervals can be
								split out, to avoid overlapping confidence
								intervals. The value is in terms of units of time 
								(On the X-Axis) rather than a percentage of the 
								plotting area.
** StopPlot		N				See MAINLIFETEST StopPlot
** CITimes		N				See MAINLIFETEST CITimes.;
** ---------------------------------------------------------------------------------
** MACRO: CREATEANNO
** CensPlot		N (0)			Whether to plot censored observations, and how to 
								plot them. If CensPlot=0, then no censored obs are 
								plotted.
								If CensPlot=1, then censored obs are plotted as 
								diagonal crosses. (X)
								If 0 < CensPlot < 1 then censored observations are 
								plotted as upward tick-marks, of the height 
								specified in CensPlot. So, CensPlot=0.02 will draw a 
								tick mark 0.02 units high at a censored observation. 
								If -1 < CensPlot < 0, then censored observations will 
								be plotted using DOWNWARD tick marks.
** CensOff		N (2)			If two or more censored observations occur at the
								same timepoint, then successive censored obs will be 
								plotted further into the future, by the value 
								specified in CensOff.
								The value used is in terms of time units on the 
								X-axis. It may be necessary to experiment with this 
								value, as large values may cause censored 
								observations to float in mid-air.
** StrCount		Y (2)			This the number of strata in your data, that need to 
								be accounted for in the Annotation dataset.
								When called from within KMLIFTESTV2 (See below) this
								value is based on the global macro variable 
								_kmlt_StratumCount.
** AtRiskSpace	Y (5)			This determines how spaced apart the rows in the 
								at-risk table are, and so (Indirectly) where the top 
								line will be.
** MedianLabels	N 				The X-axis value at which the stratum id numbers are 
								positioned when median = MEDCI.
** Inset1X		Y (100)			The X-axis value to which the left of the inset will 
								be aligned. The inset includes the results of the 
								homogeneity test, and the proportional hazards 
								modelling output, if requested.
** Inset1Y		Y (0.9)			The Y-axis value to which the top of the inset will 
								be aligned. HOWEVER: If the homogeneity test is not 
								performed, then the top edge of the Inset will be 
								higher than requested. ie the top edge may be at 0.9, 
								but the first line of test may be at y=0.7.
** AtRisk		Y (1)			Include the At-Risk table on the plot. (And so put 
								it in the annotation dataset)
** StopCens		N (1999)		The point which to stop drawing censored observations. 
								Any censored observations occurring after this point 
								are not drawn.
** Colourformat	Y (_kmlt_c.)	The format that contains the colour values to be 
								used on the plot. The default value refers to the 
								format set up in the quick-start program, to allow 
								you to quickly change the colour scheme of the graph, 
								using Colour-naming-scheme (CNS) references.;
** ---------------------------------------------------------------------------------
** MACRO: PLOTS
** DSinPlot		Y (_kmlt_graph)	The input dataset for producing the graph.
** XMin			Y (0)			The minimum value for the X-axis.
** XMax			Y (2000)		The maximum value for the X-axis. If this is greater 
								than the range of your data, then the graph will be 
								horizontally compressed.
** XInt			Y (250)			The interval between labelled tick-marks on the 
								X-axis.
								It is important not to go for too many tick marks, as
								the labels will be distorted.
** StrCount		Y (2)			See CREATEANNO StrCount.
** Title1 )						
** Title2 }		N				3 rows of titles for the plot.
** Title3 )
** XLab			Y (Time to Event) A label for the X-axis.
** YLab			Y (KM Estimate)	A label for the Y-axis.
** Device		Y (PNG)			The output format for the plot. This can be one of 
								the following:
								picture formats: (BMP GIF JPEG PNG TIFFP) 
								vector formats: (EMF SVG SASEMF)  
								ODS Destinations: (PDF RTF HTML)
								others (PSCOLOR PSL CGM)
** FileDir		Y				The file path to save the output file in. Do NOT 
								include the \ at the end of the directory.
** FileName		Y				The name of the output file. Do NOT include the file 
								extension. This will be automatically added based on 
								the value chosen for DEVICE.
								So, to save an SVG output as P:\MyGraph\KMgraph1.svg, 
								the following parameter values are needed:
								Device = SVG,
								FileDir = P:\MyGraph,
								FileName = KMGraph1,
** ColourFormat	Y (_kmlt_c.)	See CREATEANNO ColourFormat;
** ---------------------------------------------------------------------------------
** MACRO: KMLIFETESTV2 (Package macro which calls all of the above)
** Dsin				Y			See MAINLIFETEST DSIn.
** TimeToEventVar	Y			See MAINLIFETEST TimeToEvent
** CensoringVar		Y			See MAINLIFETEST Censoring
** StratumVar		Y			See MAINLIFETEST Stratum
** AtRiskTimes		Y			See MAINLIFETEST AtRiskRange
** ConfIntTimes		Y			See MAINLIFETEST CITimes
** PlotUpsideDown	Y			See MAINLIFETEST UpsideDown
** StopPlotTime		Y			See MAINLIFETEST StopPlot. (Also SPLIOT and 
															CREATEANNO) 
** HomogTest		Y			See MAINLIFETEST test.
** ConfIntSpacing	N			See SPLIOT CISpacing.
** CensHeight		N			See CREATEANNO CensPlot
** CensOffset		N			See CREATEANNO CensOff
** AtRiskPosition	Y			See CREATEANNO AtRiskSpace
** MedianPosX		N			See CREATEANNO MedianLabels
** Inset1PosX		Y			See CREATEANNO Inset1X
** Inset1PosY		Y			See CREATEANNO Inset1Y
** AtRiskPos		Y			See CREATEANNO AtRiskSpace
** ColourFormat		Y			See CREATEANNO ColourFormat (Also PLOTS)
** PlotMedianSurv	N			See CREATEANNO Median
** PlotXMin			Y			See PLOTS XMin
** PlotXMax			Y			See PLOTS XMax
** PlotXInt			Y			See PLOTS XInt
** PlotTitle1-3		N			See PLOTS Title1-Title3
** PlotXAxisLabel	Y			See PLOTS XLab
** PlotYAxisLabel	Y			See PLOTS YLab
** PlotDevice		N (PNG)		See PLOTS Device
** PlotFilePath		Y			See PLOTS FileDir
** PlotFileName		Y			See PLOTS FileName
** DatasetTidyUp	N			If 1 or Y is passed, then intermediate datasets are
								deleted after each individual macro is run. If this
								is blank, then all intermediate datasets are kept.

;


/* 1. Get the plotting data (Step plot of S(t) and the censored obs) and
the at risk range 

When MAINLIFETEST is finished, the following datasets are produced, to be passed on
to other macros:
_kmlt_dataset
_kmlt_homog1
_kmlt_quartiles
_kmlt_AtRiskTable
_kmlt_CIPoints3
_kmlt_hazrat2
*/
%macro mainlifetest(dsin		=, 
					stratum		=randtrt, 
					atriskrange	=, 
					timetoevent	=, 
					censoring	=,
					citimes		=, 
					stopplot	=,
					test		=LOGRANK,
					hazratfmt	=6.2,
					upsidedown	=0
);

%local testtext testlabel;
/* Introduce the macro */
%put ***************************;
%put Now Running MAINLIFETEST. ;
%put Global Macro variables: ;
%put _GLOBAL_;
%put Local Macro variables: ;
%put _LOCAL_;
%put ***************************;

/* Parse the test text;
The gist of this is: if the test is passed with a label, then the parameter value 
looks like this:
XXXXXXXXX=xxxxxxxxxx
|-------|=|--------|
 Name of = Label
 test

So, if we search for the = sign in the parameter value, then can identify if a label
has been requested, and separate the test label from what we pass to PROC LIFETEST
*/

%if "&test" ne "" %then %do;

	%put %upcase(&test..);
	* Is there an = sign in the parameter?;
	%let equals=%index(&test,=);
	%put &equals. %length(&test);

	%if &equals gt 0 %then %do;
		* No label for the Test specified: equals = 0;
		* label specified: equals >= 1;

		* The label and the test are separated out. If its on the right of the =, it
		is the label. Whats on the left forms the name of the test passed to 
		LIFETEST;

		* Substring from one place after the equals to the end is the label.;
		* NB: Omitting the third paramter = go up to the end of the string;
		%let testlabel=%substr(&test, (&equals + 1));
		* Substring from the first place to the one before the equals is the test.;
		%let testtext=%substr(&test, 1, (&equals - 1));
		%put TEST LABEL: &testlabel;
		%put TEST TEXT: &testtext;

		%let test=&testtext;
	%end;
	%else %do;
		%put No Test label specified, default label will be used.;
		%let testlabel=;
	%end;
%end;

/***********************************************************************************
In order to correctly create the survival graph and at-risk table, use the ODS
GRAPHICS output to create the output for an ODS GRAPH but suppress it using 
an ODS LISTING EXCLUDE statement. Then, use an ODS OUTPUT statement to take the 
dataset used to make the ODS GRAPH and store it as a permanent datatset. This
dataset includes the step-plot for the KM Graph, and the At-risk table, which will
be correct.
***********************************************************************************/

* This line allows the creation of the ODS Graph dataset;
ods graphics on;
* This line captures the ODS Graph dataset and stores it in the work library. (Along
with the quartiles information) ;
ods output	survivalplot=_kmlt_dataset
			quartiles=_kmlt_quartiles;
* Also, if we want a homogeneity test, lets have that as well.;
%if &stratum ne and "&test" ne "" %then %do;
ods output	homtests=_kmlt_homog;
%end;

* Stop the ODS Graph from being produced when LIFETEST does its thing.;
ods listing exclude survivalplot;
proc lifetest data=&dsin plots=survival(
			%if &atriskrange ne %then %do;
				/* Only produce the atrisk table if AtRiskRange is not blank*/
				atrisk=&AtRiskRange
			%end;
			%else %do;
				atrisk=0
			%end;
			)
			;
	title 'Obtaining PL Ests, Homogeneity Tests and Quartiles';
	title2 'Calling PROC LIFETEST from macro mainlifetest';
	time &timetoevent * &censoring;
	%if &stratum ne %then %do;
		strata	&stratum  %if "&test" ne "" %then %do;
						/* Only perform the test if requested */
							/ test=&test;
							%end;
					;
	%end;
run;
quit;

/* Undo all the meddling in ODS options used to create the plot. */
ods graphics off;
ods listing select all;
ods output close;

/* Did we want to prduce an upside down (1-S(t)) plot? */
%if &upsidedown eq 1 or %upcase("&upsidedown") eq "Y" %then %do;
	data _kmlt_dataset_f;
		set _kmlt_dataset;

		* Transform the survival function by 1 - S(t);
		if survival ne . then failure = 1 - survival;
		else failure = .;
		* Transform the censored observations by 1 - S(t);
		if censored ne . then failcens = 1 - censored;
		else failcens = .;
	run;

	data _kmlt_dataset;
		set _kmlt_dataset_f;
		drop survival censored;
		rename	failure=survival failcens=censored;
	run;
%end;

%if &atriskrange ne %then %do;
	* Extract the at risk table;
	data _kmlt_AtRiskTable;
		set _kmlt_dataset;

		where tAtRisk ne .;

		keep tAtRisk AtRisk Stratum StratumNum;
	run;
%end;

%if &citimes ne %then %do;
	/* 2. Get confidence intervals at the required points and homogeneity tests*/
	proc lifetest data=&dsin timelist=(&CITimes) reduceout
		outsurv=_kmlt_dataset2;
		title 'Obtaining Confidence Intervals at specified timepoints';
		title2 'Calling PROC LIFETEST from macro mainlifetest';
		time &timetoevent * &censoring;
		%if &stratum ne %then %do;
			strata	&stratum;
		%end;
	run;

	%if &upsidedown eq 1 %then %do;
		data _kmlt_dataset2_f;
			set _kmlt_dataset2;

			failure = 1 - survival;
			fail_lcl = 1 - sdf_lcl;
			fail_ucl = 1 - sdf_ucl;

		run;

		data _kmlt_dataset2;
			set _kmlt_dataset2_f;
			drop sdf_lcl sdf_ucl survival;
			rename	failure=survival
					fail_lcl=sdf_lcl
					fail_ucl=sdf_ucl;;
		run;
	%end;

	* Extract the items needed for the CIPoints;
	data _kmlt_CIPoints;
		set _kmlt_dataset2;
		%if &stratum eq %then %do;
			stratum = 1;
		%end;

		keep &stratum stratum survival timelist sdf_lcl sdf_ucl;
	run; 

	proc sort data=_kmlt_CIPoints out=_kmlt_CIPoints2;
		by timelist stratum;
	run;

	/* Need to do a long to wide transpose, as the dataset is currently
	has three variables per interval, rather than three observations
	for each interval, as needed for plotting. */
	proc transpose data=_kmlt_CIPoints2 out=_kmlt_CIPoints3;
		var survival sdf_lcl sdf_ucl;
		by timelist stratum &stratum;
	run;
%end;


/* Count the number of strata. Count unique values of the stratifying variable
using PROC SORT NODUPKEY. Store this in the global macro variable 
_kmlt_strcount so that it is available to subsequent sections of the macro. */
proc sort data=_kmlt_dataset nodupkey out=_kmlt_strcount;
	by stratum;
run;

data _null_;
	set _kmlt_strcount;
	call symput('_kmlt_StratumCount',_N_);
run;

/* If we have more than one stratum, then get the hazard ratio and
format the homogeneity test inset*/
%if &stratum ne and &_kmlt_StratumCount gt 1 %then %do;
	* 4. Get Hazard Ratios;
	ods select hazardratios;
	ods output hazardratios=_kmlt_hazrat;
	proc phreg data=&dsin alpha=0.05 ;
		class &stratum (param=ref ref=LAST descending) ;
		model &timetoevent*&censoring= &stratum;
		hazardratio &stratum;

		title 'Obtaining Hazard Ratio';
		title2 'Calling PROC PHREG from macro mainlifetest';
		title3 'Remember: Hazard Ratios may not be appropriate if the survival 
curves cross';
	run;
	quit;
	ods output close;
	ods select all;

	* Format the hazard ratio to be in a HR. 95%CI (x.xx, x.xx) type label;
	data _kmlt_hazrat2;
		set _kmlt_hazrat;
		hazrat =	"HR: "|| strip(put(HazardRatio,&hazratfmt)) || " 95% CI (" || 
					trim(left(put(Waldlower,&hazratfmt))) || "-" 
					|| trim(left(put(WaldUpper,&hazratfmt))) || ")" ;
		
		if _N_ ge 2 then do;
			put "NOTE: Hazard Ratios requested when multiple comparisons possible.";
			put "All HRs will be produced and stored in HAZRAT, but none will be 
			displayed on the plot.";
		end;
	run;

	* Put the desired straum label on the homogeneity test, if requested. If
	one wasnt requested, then just use the label given by SAS;
	%if "&test" ne "" %then %do;
		%if "&testlabel" ne "" %then %do;	
			%put TESTLABEL = &testlabel;
			data _kmlt_homog1;
				set _kmlt_homog;
				textlabel	= "&testlabel";
			run;
		%end;
		%else %do;
			%put TESTLABEL = &testlabel;
			data _kmlt_homog1;
				set _kmlt_homog;
				rename Test = textlabel;
			run;
		%end;
	%end;
%end; * End of the hazard ratio / homogeneity block;


%mend;

/* When the macro SPLIOT has finished, we may have the following datasets to pass
to other macros
_kmlt_CITable
_kmlt_Stepplottable
*/

%macro spliot(	cispacing	=0, 
				stopplot	=450,
				citimes		=10 50,
				dsinCItimes	=_kmlt_CIPoints3,
				dsinSurvDat	=_kmlt_dataset
);

%put ***************************;
%put Now Running SPLIOT. ;
%put Global Macro variables: ;
%put _GLOBAL_;
%put Local Macro variables: ;
%put _LOCAL_;
%put ***************************;

* If no value of stopplot was supplied, then put in a ridiculously large
value in its place.;
%if &stopplot eq %then %let stopplot=9999999;

/***********************************************************************************
The gist of this macro is as follows:
At the moment, the dataset for our survival plot and the confidence intervals for it 
looks like this:
Stratum	Time	Event
1		t11		e11
1		t12		e12
.		.		.
.		.		.
.		.		.
1		t1n1	e1n1
2		t21		e21
2		t22		e22
.		.		.
.		.		.
.		.		.
2		t2n2	e2n2
3		t31		e31
.		.		.
.		.		.
.		.		.

Which is all very well when we use the new SGPLOT or SGRENDER type graphics
but for this macro, what we want is something like this:
Time(1)	Event(1)	Time(2)	Event(2)	Time(3)	Event(3)	...	...
t11		e11			t21		e21			t31		e31			
t12		e12			t22		e22			t32		e32
.		.			.		.			.		.
.		.			.		.			.		.
.		.			.		.			.		.
t1n1	e1n1		t2n2	e2n2		t3n3	e3n3		...	...

This macro splits out each stratum into a separate dataset, and then re-merges them
back together, so that each stratum now has its own time list variable, and its own
values for the stepplot and confidence intervals.;
***********************************************************************************/


/* Split out and then remerge the strata from the Confidence Intervals into
one single dataset, so that all of the strata can be overlaid in one plot. */
%if &citimes ne %then %do;
	%let i=1;
	%let dsetlist=;

	proc sort data=_kmlt_CIPoints3;
		by timelist stratum _name_;
	run;

	%do %while (&i le &_kmlt_StratumCount);

		data _kmlt_CiPointsout&i;
			set &dsinCItimes;

			where stratum eq &i;

			strcount = symget('_kmlt_StratumCount');

			if strcount eq 1 then do;
				CiTime&i = timelist;	
			end;
			* Stagger the confidence interval x-values;
			else do;
				* If there s an odd no of strata, then the middle one
				should coincide with the correct value
				If there s an even no of strata, then they all lie
				either side of the correct time value;;
				strcountleft=((strcount - 1) / 2);

				CiTime&i = timelist + (&i - strcountleft - 1) * &cispacing;		
			end;

			rename	Col1=CIValue&i;

		run;

		%let dsetlist=&dsetlist _kmlt_CiPointsout&i;
		%let i=%eval(&i+1);
	%end;

	data _kmlt_CITable;
		merge	&dsetlist;

		by timelist _name_;

		keep timelist _name_ CIValue: CiTime: ;
	run;
%end;

/* Along the same lines, split out and then remerge the strata from the KM Estimates
into one single dataset, so that all of the strata can be overlaid in one plot. */

	%let i=1;
	%let dsetlist2=;
	%do %while (&i le &_kmlt_StratumCount);

		%let stopped=0;
		%put STOPPLOT=&stopplot.;

		data _kmlt_StePlotout&i;
			* StopSurv is the variable that retains the last non-missing survival
			time, so that the survival curve can be drawn up to the STOPPLOT time;
			retain stopsurv;
			set &dsinSurvDat;

			by stratumnum;

			%if stopplot ne %then %do;

				if survival ne . then stopsurv = survival;
				stopped = symget('stopped');

				if time gt &stopplot and stopped eq 0 then do;
				* When we pass the value for stopping, add in a time entry,
				with survival equal to the last non-missing value;
					output;
					time = &stopplot;
					survival = stopsurv;
					atrisk=.;
					censored=.;
					event=.;
					tatrisk=.;
					output;
					call symput('stopped',1);
				end;
				else if time le &stopplot and stopped eq 0 and last.stratumnum then do;
					* If the survival curves run out before the stopping point
					extend them to the stopping point;
					output;
					time = &stopplot;
					survival = stopsurv;
					atrisk=.;
					censored=.;
					event=.;
					tatrisk=.;
					output;
					call symput('stopped',1);
				end;
				else output;
			%end;

			where stratumnum eq &i and survival ne .;

			rename survival=survival&i;
		run;

		proc sort data=_kmlt_StePlotout&i(where=(time le &stopplot));
			by time censored;
		run;

		%let dsetlist2=&dsetlist2 _kmlt_StePlotout&i;
		%let i=%eval(&i+1);
	%end;
	
	data _kmlt_Stepplottable;
		merge	&dsetlist2;

		by time;

		keep time survival:;
	run;

%mend;

/* When the CREATEANNO macro has finished, the following datasets are created to
be passed to other macros:
_kmlt_annotation
*/
%macro createanno(	DSInHomog	=	_kmlt_homog,
					DSInSurvDat	=	_kmlt_dataset,
					DSInQuartile=	_kmlt_quartiles2,
					DSInHazRat	=	_kmlt_hazrat,
					DSInAtRisk	=	_kmlt_AtRiskTable,
					hrfmt		=	,
					htest		= ,
					censplot	=0, 
					censoff		=2, 
					strcount	=2, 
					atriskspace	=5, 
					medianlabels=260, 
					inset1x		=1500, 
					inset1y		=0.9,
					atrisk		=1, 
					median		=1, 
					stopcens	=1999, 
					leglinelength=2,
					colourformat=_kmlt_c.
);

/***********************************************************************************
In order to put on most of the required bits, an annotation dataset must be used to:
1)	Add on censored observations
2)	Add in the At-risk table, derived from MAIN LIFETEST
3)	Put on the inset
4)	Add the Median survival indicator (In the style desired)
***********************************************************************************/

* First job, bring in the annotation macros from ANNOMAC;
%ANNOMAC;

* The macro variables LEFTMOST and RIGHTMOST are used to determine where
things relating to Median Survival are plotted to / from.;
%local	rightmost leftmost;
%let rightmost=-99999;
%let leftmost=99999;

%put ***************************;
%put Now Running CREATEANNO. ;
%put Global Macro variables: ;
%put _GLOBAL_;
%put Local Macro variables: ;
%put _LOCAL_;
%put ***************************;


* If there s no value of StopCens, then give it a ridiculously high value.;
%if &stopcens eq %then %let stopcens=9999999;

data anno_frame; *The Framing section of the annotate dataset;
	function = 'FRAME    ';
	xsys = '1';
	ysys = '1';
	hsys = '1';
	output;
run;


/************************************
MEDIAN SURVIVAL.
************************************/

%if "&median" ne "NONE" and &median ne 0 and &median ne %then %do;
	%if &median eq 1 or "&median" eq "MEDCI" %then %do;
	* MEDIAN SURVIVAL: Option 1: a Graphical summary of Median (and 95% CI) for 
	median survival next to the x-axis.;

	/* Create lines corresponding to median survival parallel to the x-axis*/
	data anno_quartiles2;		
		retain leftmost;
		length style function entrynote color c $100;
		set &DSInQuartile;
			* Evaluate the colour associated with the current stratum;
			c = strip(put(stratum,&colourformat));
			put c= ;

			entrynote = 'Median Survival: Med+CI';

			* If we use this style, LEFTMOST is used to determine the left-alignment
			of the label. So, if this is the first entry in this dataset, set this
			variable to have a ridculously high value.;
			if _N_ eq 1 then leftmost = 99999;

			ypos = ((&strcount + 1.5 - stratum) * 2);

			* Move the pen to the lower 95% Confidence limit;
			/*%SYSTEM (xsys='2', ysys='1', hsys='1'); */
			%SYSTEM (2, 1, 1); 
			/*%MOVE (x=lowerlimit, y=ypos); */
			%MOVE (lowerlimit, ypos); 

			* Draw a line from the lower to the upper 95% Confidence limit;
			/*%DRAW (x=upperlimit, y=ypos, color=strip(put(stratum,&colourformat)), 
					line=1, size=0.5);  */
			%DRAW (upperlimit, ypos, REPLACEMENTCOLOURHERE, 1, 0.5); 

			* Place a symbol on the point estimate;

			/*%LABEL (x=estimate, y=ypos, text-string='+', 
				color=REPLACEMENTCOLOURHERE, angle=0, rotate=0, size=3, 
				style='Verdana', position='1'); */
			%LABEL (estimate, ypos, '|', REPLACEMENTCOLOURHERE, 0, 0, 1.5, 
				Verdana, B); 
			%LABEL (estimate, ypos, '|', REPLACEMENTCOLOURHERE, 0, 0, 1.5, 
				Verdana, 5); 

			* Place a numeric index label for this indicator to the left of the 
			lower end;
			%SYSTEM (2, 1, 4); 
			%LABEL (&medianlabels, ypos, strip(vvalue(stratum)), BLACK, 0, 
				0, 0.75, Verdana, 6); 

			* If the lower end of this confidence interval is furthest to the left
			so far, then this is used as the new value of LEFTMOST.;
			if lowerlimit lt leftmost then leftmost = lowerlimit;
			call symput('leftmost',leftmost);

			keep function c x y xsys ysys hsys style color position size line text 
				entrynote;
	run;

	/* So, why have some of the annotation macros included the parameter value
	REPLACEMENTCOLORHERE? It s because the COLOR parameter to these macros cannot
	be a dataset or macro variable, and is interpreted literally as typed. Hence
	if you opened the intermediate dataset for anno_quartiles2, you d see that
	the colour value for these entries is REPLACEMENTCOLOURHERE, rather than trying
	to resolve that as a variable name. We use this string for the colour so that 
	we can then swap out this temporary value for the true colour we need. */
	data anno_quartiles;
		set anno_quartiles2;

		if color eq 'REPLACEMENTCOLOURHERE' then color = c;

		drop c;
	run;


	* Use the value of LEFTMOST to plot a label "Median Survival";
	data anno_quar_label;
		length style function entrynote color $100;
		entrynote = 'Median Survival: Label';
		%SYSTEM (2, 1, 4); 
		%LABEL (&leftmost, (2.5 + &strcount) * 2, 'Median Survival', BLACK, 0, 0, 1, 
			Verdana, 6); 
	run;

	%end;

	%else %if &median eq 2 or "&median" eq "DROP" %then %do;
	* MEDIAN SURVIVAL: Option 2: Drop lines corresponding to the point estimates of 
	median survival;
	data anno_quartiles2;
		retain rightmost;
		length style function entrynote c color $100;
		set &DSInQuartile;
		entrynote = 'Median Survival: Drop Lines';

		c = strip(put(stratum,&colourformat));
		put c= ;

		* If we use this style, RIGHTMOST is used to determine the maximum
		extent of the horizontal reference line at y=q/100. So, if this is the 
		first entry in this dataset, set this variable to have a ridculously 
		low value.;
		if _N_ eq 1 then rightmost = -99999;

		ypos = ((&strcount + 1.5 - stratum) * 2);

		* Move the pen to the Point on this curve corresponding to quartile of
		survival;
		%SYSTEM(2, 2, 1);
		%MOVE(estimate, percent/100);
		* Draw a vertical drop line (Dashed) to the x-axis to mark the quartile of 
		survival time;
		%SYSTEM(2, 1, 1);
		%DRAW(estimate, 0, REPLACEMENTCOLOURHERE, 2, percent/100);

		* If this survival quartile is furthest to the right so far, then this is 
		used as the new value of RIGHTMOST.;
		if Estimate gt rightmost then rightmost = Estimate;
		call symput('rightmost',rightmost);

		* Because we are generalising the quartile to allow 75, 50, 25 percentiles,
		we need to store the chosen value of PERCENT as a macro variable.;
		call symput('_klmt_percentage',percent);

		keep function c x y xsys ysys hsys style color size line entrynote;
	run;

	data anno_quartiles;
		set anno_quartiles2;

		if color eq 'REPLACEMENTCOLOURHERE' then color = c;

		drop c;
	run;

	data anno_quar_label;
		length function entrynote color $100;

		* Move the pen to the point corresponding to survival quartile on the rightmost 
		curve;
		entrynote = 'Survival Quartile: Horizontal t';
		percent = SYMGET('_klmt_percentage');
		%SYSTEM(2, 2, 1);
		%MOVE(&rightmost, percent / 100);

		* Draw a dashed horizontal reference line to the y-axis at the survival quartile
		point;
		percent = SYMGET('_klmt_percentage');
		entrynote = 'Survival Quartile: Horizontal t';
		%SYSTEM(1, 2, 1);
		%DRAW(0, percent / 100, BLACK, 2, 0.5);
	run;

	%end;
%end;

/************************************
/* CENSORED OBSERVATIONS
************************************/

/* Create dataset of censored obs. These will be used to make the censored
observations in the annotate dataset */

proc sort data=&DSInSurvDat.(where=(censored ne .)) out=_kmlt_DatasetCens;
	by stratumnum time;
run;

data _kmlt_CensoredObs;
	retain censx;
	set _kmlt_DatasetCens;

	by stratumnum time;
	/* We want to offset the censored observation marks if they occur at
	the same timepoint within a stratum. We achieve this as follows:
	1) If this is the first censored obs at this time, then plot it
	where it is on the x-axis.
	2) If not, add the offset amount to the x-value and plot the
	point there. RETAIN the new x value for the next obs, if it occurs here 
	as well.
	*/
	if first.stratumnum or first.time then do;
		censx = time;
	end;
	else do;
		censx = censx + &censoff;
	end; 
	censy = censored + &censplot;

	* ... but there s no point plotting a censoed value if it occurs after
	the point we ve cut off the data;
	where time le &stopcens;

	keep time censored stratum stratumnum censx censy;
run;

%if &censplot lt 1 and &censplot gt -1 %then %do;
	/* If we are producing upward tick marks, then use this step. 
	NOTE: If a value of 0 is passed for the value of CENSPLOT, then this
	section of code still runs, but the output plot has no censored obs included on
	it. */
	data anno_cens2;
		length function entrynote c color $100;
		set _kmlt_CensoredObs;

		entrynote = 'Censored Obs: Upward tick';

		c = strip(put(stratumnum,&colourformat));
		
		* MOVE the pen to the base of the censored tick mark, and DRAW a line
		to the top of it.;
		%SYSTEM(2, 2, 1);
		%MOVE(censx, censored);
		%SYSTEM(2, 2, 1);
		%DRAW(censx, censy, REPLACEMENTCOLOURHERE, 1, 1);

		keep function c x y xsys ysys hsys color size line entrynote;
	run;

	data anno_cens;
		set anno_cens2;

		if color eq 'REPLACEMENTCOLOURHERE' then color = c;

		drop c;
	run;

%end;
%else %if &censplot eq 1 %then %do;
	/* If we are producing Crosses (X) then use this step*/
	data anno_cens2;
		length style function entrynote c color $100;
		set _kmlt_CensoredObs;
		entrynote = 'Censored Obs: Cross';

		c = strip(put(stratumnum,&colourformat));
		
		%SYSTEM (2, 2, 1); 
		%LABEL (censx, censored, 'X', REPLACEMENTCOLOURHERE, 0, 0, 1.5, verdana, +); 

		keep c function x y xsys ysys hsys style color size entrynote text 
			rotate angle;
	run;
%end;

	data anno_cens;
		set anno_cens2;

		if color eq 'REPLACEMENTCOLOURHERE' then color = c;

		drop c;
	run;


/************************************
/* AT RISK TABLE
************************************/

%if &atrisk ne %then %do;
	/* Only do this if we wanted the at-risk table */

	* Turn into entries for an annotation dataset;
	data anno_AtRisk;
		length function entrynote $40;
		set &DSInAtRisk;
		entrynote = 'At Risk Table Entry';

		%SYSTEM (2, 3, 1); 
		%LABEL (tAtRisk, (1 + (&strcount - stratumnum)) * &atriskspace, 
			put(atrisk, 4.0), BLACK, 0, 0, 1, verdana, +); 

		keep x y xsys ysys function size text color entrynote;
	run;

	* Put the Number at risk label under the plot;
	data anno_AR_label;
		length function entrynote $40;
		entrynote = 'At Risk Table Label';
		%SYSTEM (5, 3, 4); 
		%LABEL (0, (1 + &strcount) * &atriskspace, 'Number at Risk', 
			BLACK, 0, 0, 1, verdana, 6); 
	run;

	proc sort data=&DSInAtRisk out=anno_atriskleg(keep=stratumnum stratum) nodupkey;
		by stratumnum;
	run;

	* Create row labels for the at risk table;
	data anno_atriskleg2;
		set anno_atriskleg;
		length function entrynote $40;
		entrynote = 'At Risk Table Stratum Id';		
		%SYSTEM (5, 3, 4); 
		%LABEL (0, (1 + (&strcount - stratumnum)) * &atriskspace, strip(stratum), 
			BLACK, 0, 0, 1, verdana, 6); 
	run;		

	* Set the row labels opnto the at risk table;
	data anno_AtRisk;
		set anno_atriskleg2
			anno_AtRisk;
	run;
%end;

%if &strcount gt 1 %then %do;

/************************************
/* Hazard Ratio Inset
************************************/

	%if &hrfmt ne %then %do;
		* Even if we have more than 1 hazard ratio, we still process the
		annotation hr dataset in case you want to pick one out and add
		to the plot;
		data anno_hr;
			length style function entrynote text $100;
			set &DSInHazRat;

			entrynote = 'Hazard Ratio Inset Entry';	
			%SYSTEM (2, 2, 4); 
			%LABEL (&inset1x, &inset1y - 0.1, strip(hazrat), BLACK, 0, 0, 1, 
				verdana, 9); 

			keep entrynote function x y xsys ysys hsys style color position text size ;
		run;
	%end;

/************************************
/* Legend Inset
************************************/
	proc sort data=&DSInSurvDat out=_anno_strata(keep=stratum stratumnum) nodupkey;
		by stratum;
	run;

	data anno_leg2;
		length style function entrynote text $100;
		set _anno_strata;

		entrynote = 'Legend Line';	

		c = strip(put(stratumnum,&colourformat));

		%SYSTEM(2, 2, 1);
		%MOVE(&inset1x, &inset1y - (0.15 + stratumnum*0.05));
		%SYSTEM(2, 2, 1);
		%DRAW(&inset1x+&leglinelength, &inset1y - (0.15 + stratumnum*0.05), 
			REPLACEMENTCOLOURHERE, 1, 1);
		%SYSTEM (2, 2, 4); 
		%LABEL (&inset1x+&leglinelength, &inset1y - (0.15 + stratumnum*0.05), 
			strip(stratum), BLACK, 0, 0, 1, verdana, 6); 
		keep entrynote function x y xsys ysys hsys style color position text size c;
	run;

	data anno_leg;
		set anno_leg2;

		if color eq 'REPLACEMENTCOLOURHERE' then color = c;

		drop c;
	run;

/************************************
/* Homogeneity Test Inset
************************************/

	%if "&htest" ne "" %then %do;
		data anno_homog; * The Homogeneity Test Section of the annotate dataset;
			retain function style color xsys ysys hsys;
			set &DSInHomog;
			length style function entrynote $40 text $100;
			function = 'LABEL';
			xsys = '2';
			ysys = '2';
			hsys = '1';
			color='BLACK';
			entrynote = 'Homogeneity Test Inset';	

			* Label at the top; 
			%SYSTEM (2, 2, 4); 
			%LABEL (&inset1x, &inset1y, strip(textlabel), BLACK, 0, 0, 1, verdana, 6); 

			* Greek ChiSquared;
			%SYSTEM (2, 2, 4); 
			%LABEL (&inset1x, &inset1y-0.055, 'x', BLACK, 0, 0, 1, GREEK, 0); 

			* Continued (Superscript 2); 
			%SYSTEM (2, 2, 4); 
			%LABEL (., &inset1y-0.05, '2', BLACK, 0, 0, 0.75, verdana, 0); 

			* Continued (Subscript df); 
			%SYSTEM (2, 2, 4); 
			%LABEL (., &inset1y-0.07, strip(put(df,2.0)), BLACK, 0, 0, 0.75, verdana, 0); 

			* Continued = x.xxx; 
			%SYSTEM (2, 2, 4); 
			%LABEL (., &inset1y-0.06, " = " || put(Chisq,7.4), BLACK, 0, 0, 1, 
				Verdana, 0); 

			* P-Value; 
			if ProbChiSq < 0.0001 then text = "P < 0.0001";
			else text = "P=" || put(ProbChiSq,7.4);
			%SYSTEM (2, 2, 4); 
			%LABEL (&inset1x, &inset1y-0.05, text, BLACK, 0, 0, 1, Verdana, 9); 

			keep function entrynote x y xsys ysys hsys style color position size text;
		run;
	%end;
%end;

/* Build the annotation dataset from the required components */
data _kmlt_annotation;
	retain entrynote;
	length entrynote text style color function $255 ;
	set anno_frame
		anno_cens
		%if &strcount gt 1 and "&htest" ne "" %then %do;
			anno_homog
		%end;
		%if &strcount eq 2 and &hrfmt ne %then %do;
			anno_hr
		%end;
		%if &atrisk ne %then %do;
			anno_AR_label
			anno_atrisk
		%end;
		%if "&median" ne "NONE" and &median ne 0 and &median ne %then %do;
			anno_quar_label
			anno_quartiles
		%end;
		%if &strcount gt 1 %then %do;
			anno_leg
		%end;

		;
run;
%mend;

%macro plots(dsinplot=_kmlt_graph, dsinanno=_kmlt_annotation, xmin=0, xmax=2000, 
	xint=250, strcount=2, title1=, title2=, title3=, xlab=Time to event, 
	ylab=Event-free Survival, device=PNG, filedir=, filename=, 
	colourformat=_kmlt_c.);

%local	_kmlt_civalue _kmlt_citime;

%put ***************************;
%put Now Running PLOTS. ;
%put Global Macro variables: ;
%put _GLOBAL_;
%put Local Macro variables: ;
%put _LOCAL_;
%put ***************************;


%put %qcmpres(&device)..;
%let _kmplot_devicelist=BMP CGM EMF GIF JPEG PDF PNG PSCOLOR PSL SASEMF SVG TIFFP RTF HTML;
%let _kmplot_validdevice=0;
%let word=;

%do i=1 %to 14;
	%let word = %scan(&_kmplot_devicelist,&i);

	%if &word = &device %then %let _kmplot_validdevice=1;
%end;

%if &_kmplot_validdevice eq 0  %then %do;
	%put NOTE: Expected DEVICE to be one of BMP CGM EMF GIF JPEG PDF PSCOLOR PSL 
	SASEMF SVG TIFFP RTF or HTML but instead DEVICE=&device;
	%put DEVICE will be set to PNG;
	%let device=PNG;
%end;


/************************************
/* Declare Y and X Axis setups
************************************/

* Y Axis;
axis1	value = (h=1.1 c=black f=verdana)
		label = (h=1.25 c=black a=90 r=0 f=verdana "&ylab")
		c     = black
		order = 0 to 1 by 0.1
		origin=(15 pct, 22 pct) /* 15pct from the left edge, 20pct from the bottom 
								edge*/
		offset=(1 pct,1 pct) /* 1pct offset at y=0 and at y=1 */
		minor = none;

* X Axis;
axis2	value = (h=1.1 c=black f=verdana)
		label = (h=1.25 c=black f=verdana "&xlab")
		c     = black
		order = &xmin to &xmax by &xint
		minor = none;

/************************************
/* Declare Titles, and clear footnotes to make
** room for the At-Risk Table.
************************************/

title1 &title1;
title2 &title2;
title3 &title3;
footnote1 ' ';

/************************************
/* SYMBOL Statements for the lines and 
** Confidence Intervals.
************************************/

* Extract the colours for the plotting lines and symbols;
data _null_;
	length	aargh $100 strs $30;
	strcount = symget('strcount');
	do i = 1 to strcount;
		strs = strip(put(i,3.0));
		aargh	=	strip(put(i,&colourformat));
		put strs;
		put aargh;
		call symput('colour'||strs,aargh);
	end;
run;

%let i=1;
%let j=1;
%let legendorder=;
%let apos=%str(%');

/* In the block below add in an l= or change the w= to change the
line style and width for the step-plot. */

%do i = 1 %to &strcount;
	symbol&i interpol=stepjl w=1 c="&&colour&i"; /* <- Change this w= or add an l= here*/
	symbol%eval(&i+&strcount) interpol=hiloctj w=1 l=35 c="&&colour&i" ci="WHITE" 
			value=NONE;
	%let legendorder=&legendorder &apos.survival&i.&apos;
%end;

%let i=1;
%let j=1;
%let k=%eval(&strcount + 1);

%put &legendorder;
legend1	ORDER=(1 2);

/************************************
/* Produce the plot, using PROC GPLOT
************************************/

%put Saving output file to &filedir.\&filename..&device;


/* If we wanted an RTF or HTML output, then produce those. */
%if &device = HTML %then %do;

	ods listing	gpath="&filedir.\";

	ods html	gpath="&filedir.\"
				body ="&filedir.\&filename..&device";

%end;
%else %if &device = RTF %then %do;

	ods listing	gpath="&filedir.\";

	ods rtf		path ="&filedir.\"
				file ="&FileName..&device"
			    /*style = &ODSstyle
        		image_dpi = &figRes	*/;

%end;
%else %do;

	/* If we did not specify an RTF or HTML destination, then 
	produce the plot file as normal.*/
	filename gsfname "&filedir.\&filename..&device";
	%put Saving output file to &filedir.\&filename..&device;

	goptions device="&device" gsfname=gsfname;

%end;

/* In order to detect whether or not confidence intervals are included
in the graphing dataset, call proc contents, and count how many
variables contain the string CIValue or CITime */
proc contents	data=&dsinplot noprint
				out=_kmlt_graphvarchk;
run;

* Count instances of CIVALUE and CITIME;
%let _kmlt_civalue=0;
%let _kmlt_citime=0;
data _null_;
	retain civalue citime 0;
	set _kmlt_graphvarchk(keep=name);

	if find(strip(upcase(name)),'CIVALUE') gt 0 then civalue = civalue + 1;
	else if find(strip(upcase(name)),'CITIME') gt 0 then citime = citime + 1;
	put civalue= citime=;

	call symput('_kmlt_civalue',civalue);
	call symput('_kmlt_citime',citime);
run;

proc gplot data=&dsinplot;
	plot
	%do %while (&j le &strcount);
		/* Confidence Intervals come first, if we wanted them*/
		%if &_kmlt_civalue gt 0 and &_kmlt_citime gt 0 %then %do;
		civalue&j * citime&j = &k
		%end;

		%let j=%eval(&j+1);
		%let k=%eval(&k+1);
	%end;
	%do %while (&i le &strcount);
		/* Now the KM Estimates*/
		survival&i * time = &i

		%let i=%eval(&i+1);
	%end;
	
	/ overlay
	 annotate=&dsinanno
		haxis=axis2
		vaxis=axis1
		nolegend;
run;
quit;

/* If we opened an ODS destination, then close it. */

%if &device eq HTML or &device eq RTF %then %do;
	ods &device close;
%end;
%else %do;
	goptions reset=all;
%end;


%mend;




%macro kmlifetestv3(	/* Passed to MAINLIFETEST */
						dsin			=	,
						TimeToEventVar	=	,
						CensoringVar	=	,
						StratumVar		=	,
						AtRiskTimes		=	,
						ConfIntTime		=	,
						PlotUpsideDown	=	0,
						HomogTest		=	,
						HRformat		=	,
						/* Passed to both MAINLIFETEST and CREATEANNO */
						StopPlotTime	=	,
						/* Passed to SPLIOT */
						ConfIntSpacing	=	0,
						/* Passed to CREATEANNO */
						CensHeight		=	0,
						CensOffset		=	2,
						AtRiskPosition	=	2,
						MedianPosX		=	300,
						Inset1PosX		=	1800,
						Inset1PosY		=	0.9,
						AtRiskPos		=	1,
						PlotMedianSurv	=	0, /* 0,1,2 or NONE,MEDCI,DROP */
						/* Passed to both CREATEANNO and PLOTS */
						colourformat	=	_kmlt_c.,
						/* Passed to PLOTS */
						PlotXMin		=	0,
						PlotXMax		=	2500,
						PlotXInt		=	250,
						PlotTitle1		=, 
						PlotTitle2		=, 
						PlotTitle3		=, 
						PlotXAxisLabel	=Time to event,
						PlotYAxisLabel	=Event-free Survival,
						PlotDevice		=	,	/* EMF, SVG, PNG, JPEG, GIF PDF or LISTING RTF HTML*/
						PlotFilePath	=	,
						PlotFileName	=	,
						/* Tidying up (Or keeping intermediate datasets for debugging) */
						DatasetTidyUp	=	1
);


%global _kmlt_StratumCount;
%let _kmlt_StratumCount=1;

%let PlotMedianSurv=%upcase(%cmpres(&PlotMedianSurv));

%put ***************************;
%put Now Running KMLIFETESTV2. ;
%put Local Macro variables: ;
%put _LOCAL_;
%put ***************************;

%mainlifetest(	dsin		=	&dsin,
				stratum		=	&StratumVar, 
				atriskrange	=	&AtRiskTimes, 
				timetoevent	=	&TimeToEventVar,
				censoring	=	&CensoringVar,
				citimes		=	&ConfIntTime,
				upsidedown	=	&PlotUpsideDown,
				stopplot	=	&StopPlotTime,
				hazratfmt	=	&HRformat,
				test		=	&HomogTest
);

%if &DatasetTidyUp eq 1 %then %do;
	proc datasets lib=work memtype=data;
		delete _kmlt_dataset_f _kmlt_dataset2_f _kmlt_CIPoints _kmlt_CIPoints2;
	run;
	quit;
%end;

%spliot(		cispacing	=	&ConfIntSpacing, 
				citimes		=	&ConfIntTime,
				stopplot	=	&StopPlotTime
);
%if &DatasetTidyUp eq 1 %then %do;
	proc datasets lib=work memtype=data;
		delete _kmlt_steplotout: _kmlt_cipointsout: _kmlt_strcount;
	run;
	quit;
%end;

/* Before we begin creating the annotation dataset, we only want the
50th percentile of survival, but our quartiles dataset contains the
values for 25, 50 and 75. Use this step to filter out the quartile
we want. 

WARNING! Do not try to request multiple quartiles on this plot by
skipping over this data step. The output plot is not designed to handle
multiple quartiles.*/
data _kmlt_quartiles2;
	set _kmlt_quartiles;

	where percent=50;
run;

%createanno(	DSInHomog	=	_kmlt_homog1,
				DSInSurvDat	=	_kmlt_dataset,
				DSInQuartile=	_kmlt_quartiles2,
				DSInHazRat	=	_kmlt_hazrat2,
				DSInAtRisk	=	_kmlt_atrisktable,
				hrfmt		=	&HRformat,
				htest		= 	&HomogTest,
				censplot	=	&CensHeight,
				censoff		=	&CensOffset, 
				strcount	=	&_kmlt_StratumCount, 
				atriskspace	=	&AtRiskPosition, 
				medianlabels=	&MedianPosX, 
				inset1x		=	&Inset1PosX, 
				inset1y		=	&Inset1PosY,
				atrisk		=	&AtRiskPos, 
				leglinelength=	%sysevalf((&PlotXMax - &PlotXMin)/25),
				colourformat=	&colourformat,
				median		=	&PlotMedianSurv, 
				stopcens	=	&StopPlotTime
);

%if &DatasetTidyUp eq 1 %then %do;
	proc datasets lib=work memtype=data;
		delete anno_: ;
	run;
	quit;
%end;

/* Merge together the CI Table and Survival Dataset, if we requested
Confidence Intervals. If not, just rename the dataset.*/
%if &ConfIntTime ne %then %do;
	data _kmlt_graph;
		merge	_kmlt_stepplottable
				_kmlt_citable;
	run;
%end;
%else %do;
	data _kmlt_graph;
		merge	_kmlt_stepplottable
				;
	run;
%end;



%plots(			dsinplot	=	_kmlt_graph,
				dsinanno	=	_kmlt_annotation, 
				xmin		=	&PlotXMin,
				xmax		=	&PlotXMax,
				xint		=	&PlotXInt,
				strcount	=	&_kmlt_StratumCount,
				colourformat=	&colourformat,
				title1		=	&PlotTitle1, 
				title2		=	&PlotTitle2, 
				title3		=	&PlotTitle3, 
				xlab		=	&PlotXAxisLabel,
				ylab		=	&PlotYAxisLabel, 
				device		=	&PlotDevice,
				filedir		=	&PlotFilePath, 
				filename	=	&PlotFileName
);

%if &DatasetTidyUp eq 1 %then %do;
	proc datasets lib=work memtype=data;
		delete	_kmlt_homog: _kmlt_hazrat _kmlt_CiPoints: _kmlt_dataset2 
				_kmlt_datasetcens _kmlt_quartiles
				_kmlt_citable _kmlt_stepplottable _kmlt_censoredobs _kmlt_atrisktable;
	run;
	quit;
%end;

%mend kmlifetestv3;




