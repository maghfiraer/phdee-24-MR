*********************************************************************************
* AUTHOR		: MAGHFIRA RAMADHANI											*
* PROJECT		: HOMEWORK 6													*
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
	
	global export_log 0 // Set to 1 if you want to export log, 0 o/w

	* Set the location of project directory location
	
	global path "C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-6"
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
* Q1 Hourly Data
*********************************************************************************

	* Load Data
	use "$data_path\energy_staggered", clear
	
	* Q1.1
	* Generate time variable
	gen double time =clock(datetime,"MDYhms")
	format time %tc
	order time id treatment
	
	* Generate treatment cohort manual
	bysort id treatment: egen double first_treated=min(time) if treatment==1
	bysort id (first_treated): replace first_treated=first_treated[1] if missing(first_treated)
	format first_treated %tc
	
	* Generate treatment cohort variable using canned procedure from csdid
	egen double cohort=csgvar(treatment), ivar(id) tvar(time)
	format cohort %tc
	
	* Both of these cohort variable are similar
	count if cohort==first_treated
		
	* Generate hour
	sort time
	egen hour=seq(), by(id)
	
	* Save hourly data
	save "$data_path\energy_staggered_hr", replace

	* Q1.2
	* Estimate TWFE weights
	twowayfeweights energy cohort hour treatment, type(feTR)
	
	* Q1.4 TWFE DID
	
	use "$data_path\energy_staggered_hr", clear
	
	est clear
	eststo: reghdfe energy treatment temperature precipitation relativehumidity, absorb(time id) vce(cluster id)
	
	
	*** Using .tex
	esttab using "$table_path\hourly_twfe.tex", label replace ///
		b(4) se(4) ////
		collabels(none) star(* 0.10 ** 0.05 *** 0.01) nonum ///
		coeflabels(treatment "ATT" relativehumidity "Relative Humidity (\%)") ///
		ar2 sfmt(%8.2f)

*********************************************************************************
* Q2 Daily Data
*********************************************************************************		
	* Load data
	use "$data_path\energy_staggered_hr", clear
	
	* Collapse to daily
	gen date=dofc(time)
	format date %td
	collapse (max) treatment=treatment (sum) energy=energy (mean) temperature precipitation relativehumidity zip size occupants devicegroup, by(id date)
	
	* Generate day
	sort date
	egen day=seq(), by(id)
	
	* Generate cohort
	* Generate treatment cohort manual
	bysort id treatment: egen double first_treated=min(day) if treatment==1
	bysort id (first_treated): replace first_treated=first_treated[1] if missing(first_treated)
	
	* Generate treatment cohort variable using canned procedure from csdid
	egen double cohort=csgvar(treatment), ivar(id) tvar(day)
	
	* Both of these cohort variable are similar
	count if cohort==first_treated
	
	* Save daily data
	save "$data_path\energy_staggered_day", replace
	
	****************************************************************************
	* Q2.1 TWFE DID
	****************************************************************************
	
	use "$data_path\energy_staggered_day", clear
	est clear
	eststo: reghdfe energy treatment temperature precipitation relativehumidity, absorb(date id) vce(cluster id)
	
	
	*** Using .tex
	esttab using "$table_path\daily_twfe.tex", label replace ///
		b(4) se(4) ////
		mtitles("Energy consumption (kWh)") collabel(none) star(* 0.10 ** 0.05 *** 0.01) nonum ///
		coeflabels(treatment "ATT" relativehumidity "Relative Humidity (\%)" temperature "Temperature (F)" precipitation "Precipitation (in)" ) ///
		ar2 sfmt(%8.2f)
	
	****************************************************************************
	* Q2.2 Event Study Manual
	****************************************************************************
	
	use "$data_path\energy_staggered_day", clear
	
	* Create event_time variable
	gen event_time = day - first_treated
	
	* Make dummies for period and omit -1 period
	char event_time[omit] -1
	xi i.event_time, pref(_T)
	
	* Position of -2
	local pos_of_neg_2 = 28 

	* Position of 0
	local pos_of_zero = `pos_of_neg_2' + 2

	* Position of max
	local pos_of_max = `pos_of_zero' + 29

	* Event study
	reghdfe energy  _T* temperature precipitation relativehumidity, absorb(id) vce(cluster id)
	forvalues i = 1(1)`pos_of_neg_2'{
		scalar b_`i' = _b[_Tevent_tim_`i']
		scalar se_v2_`i' = _se[_Tevent_tim_`i']
	}
		

	forvalues i = `pos_of_zero'(1)`pos_of_max'{
		scalar b_`i' = _b[_Tevent_tim_`i']
		scalar se_v2_`i' = _se[_Tevent_tim_`i']
	}

	capture drop order
	capture drop b 
	capture drop high 
	capture drop low

	gen order = .
	gen b =. 
	gen high =. 
	gen low =.

	local i = 1
	local graph_start  = 1
	forvalues day = 1(1)`pos_of_neg_2'{
		local event_time = `day' - 2 - `pos_of_neg_2'
		replace order = `event_time' in `i'
		
		replace b    = b_`day' in `i'
		replace high = b_`day' + 1.96*se_v2_`day' in `i'
		replace low  = b_`day' - 1.96*se_v2_`day' in `i'
			
		local i = `i' + 1
	}

	replace order = -1 in `i'

	replace b    = 0  in `i'
	replace high = 0  in `i'
	replace low  = 0  in `i'

	local i = `i' + 1
	forvalues day = `pos_of_zero'(1)`pos_of_max'{
		local event_time = `day' - 2 - `pos_of_neg_2'

		replace order = `event_time' in `i'
		
		replace b    = b_`day' in `i'
		replace high = b_`day' + 1.96*se_v2_`day' in `i'
		replace low  = b_`day' - 1.96*se_v2_`day' in `i'
			
		local i = `i' + 1
	}


	return list

	twoway rarea low high order if order<=29 & order >= -29 , fcol(gs14) lcol(white) msize(1) /// estimates
		|| connected b order if order<=29 & order >= -29, lw(0.6) col(white) msize(1) msymbol(s) lp(solid) /// highlighting
		|| connected b order if order<=29 & order >= -29, lw(0.2) col("71 71 179") msize(1) msymbol(s) lp(solid) /// connect estimates
		|| scatteri 0 -29 0 29, recast(line) lcol(gs8) lp(longdash) lwidth(0.5) /// zero line 
			xlab(-30(10)30 ///
					, nogrid labsize(2) angle(0)) ///
			ylab(, nogrid labs(3)) ///
			legend(off) ///
			xtitle("Day since receiving treatment", size(5)) ///
			ytitle("Daily energy consumption (kWh)", size(5)) ///
			xline(-.5, lpattern(dash) lcolor(gs7) lwidth(0.6)) 	
			
	graph export "$figure_path\event_study.pdf", replace 
	
	
	****************************************************************************
	* Q2.3 Event Study using EventDD
	****************************************************************************
	eventdd energy temperature precipitation relativehumidity, hdfe absorb(id) timevar(event_time) cluster(id) graph_op(ytitle("Daily energy consumption (kWh)", size(5)) xlabel(-30(10)30) xtitle("Day since receiving treatment", size(5)))
	
	graph export "$figure_path\event_study_canned.pdf", replace 
	
	****************************************************************************
	* Q2.4 Callaway Sant'Anna DID
	****************************************************************************
	csdid energy temperature precipitation relativehumidity, ivar(id) time(day) gvar(first_treated) wboot reps(50)
	estat simple
	estat event
	csdid_plot, ytitle("Daily energy consumption (kWh)", size(5)) xlabel(-30(10)30) xtitle("Day since receiving treatment", size(5)) xline(-.5, lpattern(dash) lcolor(gs7) lwidth(0.3))
	
	graph export "$figure_path\event_study_csdid.pdf", replace
	
	
*********************************************************************************
* End of code
if $export_log == 1{
	log close
	}
