*********************************************************************************
* AUTHOR		: MAGHFIRA RAMADHANI											*
* PROJECT		: HOMEWORK 9													*
* COURSE		: ECON7103 Environmental Economics II							*
* DESCRIPTION	: Main Code														*
* INPUT			: NA	    													*
* OUTPUT		: .\output\table, .\output\figure, .\output\log					*
* STATA VERSION	: Stata/MP 18.0													*
*********************************************************************************

clear
version 18.0
macro drop _all
set linesize 255
set more off, permanently
capture log close
capture graph drop _all
matrix drop _all

*********************************************************************************
* Setup the profile of your machine

	* Select option to install Stata packages (list package in profile.do)
	
	global install_stata_packages 0 // Set to 1 for first time running, 0 o/w
	
	* Select option to export log
	
	global export_log 1 // Set to 1 if you want to export log, 0 o/w

	* Set the location of project directory location
	
	global path "C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-9"
	global data_path "$path\data"
	global temp_path "$path\temp"
	global code_path "$path\code" 
	global table_path "$path\output\table" 
	global figure_path "$path\output\figure"

	* ON IAC VLAB server, you will need to uncomment this line and run this:
	*sysdir set PERSONAL \\iac.nas.gatech.edu\mramadhani3

	* Set the location of Python and R executable
	
	* global RSCRIPT_PATH "C:\Program Files\R\R-4.2.2\bin\x64\Rscript.exe"
	
	*Change line 48 to your Conda env, and uncomment the following line for first time run
	*python set exec C:\Users\mramadhani3\AppData\Local\anaconda3\envs\economics\python.exe
	
	*python set userpath "C:\Users\mramadhani3\AppData\Local\anaconda3\Lib\site-packages" "C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-2\code"


	* Set machine profile
	
	do "$code_path\0_profile.do"

*********************************************************************************
* Q1 Run the Stata code
*********************************************************************************

	use "$data_path\recycling_hw", clear
	
	* Q1.1 Yearly plot of recycling rate for NYC, NJ, and MA for 1997-2008
	
	collapse (mean) recyclingrate, by(nyc year)
	twoway 	(connected recyclingrate year if nyc, lwidth(medthick)) ///
			(connected recyclingrate year if !nyc, lwidth(medthick) ///
			legend(ring(0) pos(11) order(1 "NYC" 2 "NJ+MA") region(style(none)) rows(2) ) ylabels(0(0.1)0.7, nogrid) xlabels( 1997(1)2008, nogrid) xline(2001.5 2004.5) xtitle(Year) ytitle("") name(recyclingrate, replace) title("Recycling rate") scale(1.5)) 

	graph export "$figure_path\recyclingrate.pdf", name (recyclingrate) replace 
	
	* Q1.2 Effect of pause on NYC using TWFE from 1997-2004, cluster at region level
	
	use "$data_path\recycling_hw", clear
	keep if inrange(year,1997,2004)
	gen treatment=0
	replace treatment=1 if nyc & year>2001
	ivreghdfe recyclingrate treatment, absorb(region year) vce(cluster region)
	
	* Q1.3 SDID version of the TWFE regression 
	sdid recyclingrate region year treatment, vce(bootstrap) seed(1) reps(100) graph ///
			g2_opt(legend(ring(0) pos(11) order(1 "NYC" 2 "NJ+MA") region(style(none)) rows(2)) ///
			xtitle(Year) ytitle("") xlabel(1997(1)2004,nogrid) scale(1.5))
		
	graph export "$figure_path\sdid.pdf", replace
	
	* Q1.4 Event Study
	use "$data_path\recycling_hw", clear
	
	ivreghdfe recyclingrate b2001.year##1.nyc incomepercapita nonwhite munipop2000 collegedegree2000 democratvoteshare2000 democratvoteshare2004, absorb(region year) vce(cluster region)
	coefplot, baselevels omitted xline(5.5) yline(0) ytitle(Coefficient) keep(*.year#1.nyc) scale(1.5) ///
			coeflabels( 1997.year#1.nyc="1997" 1998.year#1.nyc="1998" 1999.year#1.nyc="1999" ///
						2000.year#1.nyc="2000" 2001.year#1.nyc="2001" 2002.year#1.nyc="2002" ///
						2003.year#1.nyc="2003" 2004.year#1.nyc="2004" 2005.year#1.nyc="2005" ///
						2006.year#1.nyc="2000" 2007.year#1.nyc="2007" 2008.year#1.nyc="2008") vertical
	
	graph export "$figure_path\eventstudy.pdf", replace

	* Q1.5 Synthetic Control 
	use "$data_path\recycling_hw", clear
	
	* Collapse data
	collapse (mean) recyclingrate incomepercapita collegedegree2000 democratvoteshare2000 democratvoteshare2004 nonwhite (first) nj ma munipop2000, by(id nyc year)
	save "$data_path\recycling_hw_sc", replace
	collapse (mean) recyclingrate incomepercapita collegedegree2000 democratvoteshare2000 democratvoteshare2004 nonwhite (first) nj ma id munipop2000, by(nyc year)
	drop if !nyc
	save "$data_path\recycling_hw_sc_nyc", replace
	
	use "$data_path\recycling_hw_sc", clear
	drop if nyc
	append using "$data_path\recycling_hw_sc_nyc"
	save "$data_path\recycling_hw_sc", replace
	
	* Synthetic Control
	use "$data_path\recycling_hw_sc", clear
	la var recyclingrate "Recycling Rate"
	xtset id year
	synth recyclingrate recyclingrate(1997) recyclingrate(1998) recyclingrate(1999) ///
			recyclingrate(2000) recyclingrate(2001) democratvoteshare2000(2000) collegedegree2000(2000) ///
			nonwhite incomepercapita, trunit(27) trperiod(2002) fig keep(scresult) replace
			
	synth_runner recyclingrate recyclingrate(1997) recyclingrate(1998) recyclingrate(1999) ///
			recyclingrate(2000) recyclingrate(2001) democratvoteshare2000(2000) collegedegree2000(2000) ///
			nonwhite incomepercapita, trunit(27) trperiod(2002) mspeperiod(1998(1)2001) gen_vars

	single_treatment_graphs, treated_name(NYC) trlinediff(-0.5) effects_ylabels(-.4(.1).5) do_color(gs13) raw_options(scale(1.4) xlabel(1997(2)2008, nogrid) xmtick(1997(1)2008) xtitle(Year) legend(pos(7) ring(0) region(style(none))) xline(2004.5) title("Synthetic control raw outcomes:") subtitle("Recycling rate")) effects_options(scale(1.6) xlabel(1997(2)2008, nogrid) xmtick(1997(1)2008) xtitle(Year) ytitle("") legend(pos(7) ring(0) region(style(none))) xline(2004.5) title(Synthetic control effects and placebos) subtitle("Coefficient estimates"))

	effect_graphs, treated_name(NYC) trlinediff(-0.5) tc_options(scale(1.4) xlabel(1997(2)2008, nogrid) xmtick(1997(1)2008) ylabel(,nogrid) xtitle(Year) legend(pos(7) ring(0) region(style(none))) xline(2004.5) title(NYC and synthetic control) subtitle(Recycling rate)) effect_options(xlabel(1997(2)2008, nogrid) xmtick(1997(1)2008) ylabel(, nogrid) xtitle(Year) legend(pos(7) ring(0) region(style(none))) xline(2004.5) title(Synthetic control) subtitle("Coefficient estimates") yline(0) scale(1.6))
	
	graph export "$figure_path\raw.pdf", name(raw) replace
	graph export "$figure_path\placebo.pdf", name(effects) replace
	graph export "$figure_path\effect.pdf", name(effect) replace
	graph export "$figure_path\treatmentcontrol.pdf", name(tc) replace

*********************************************************************************
* End of code
if $export_log == 1{
	log close
	}
