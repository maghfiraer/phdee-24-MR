*********************************************************************************
* AUTHOR		: MAGHFIRA RAMADHANI											*
* PROJECT		: HOMEWORK 3													*
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
	
	global path "C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-3"
	global data_path "$path\data"
	global temp_path "$path\temp"
	global code_path "$path\code" 
	global table_path "$path\output\table" 
	global figure_path "$path\output\figure"

	* ON IAC VLAB server, you will need to uncomment this line and run this:
	*sysdir set PERSONAL \\iac.nas.gatech.edu\mramadhani3

	* Set the location of Python and R executable
	
	global RSCRIPT_PATH "C:\Program Files\R\R-4.2.2\bin\x64\Rscript.exe"
	*python set exec C:\Users\mramadhani3\AppData\Local\anaconda3\python.exe
	*python set userpath "C:\Users\mramadhani3\AppData\Local\anaconda3\Lib\site-packages" "C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-2\code"


	* Set machine profile
	
	do "$code_path\0_profile.do"

*********************************************************************************
* Q1 Run the given Python code from Shell (make sure dependency are all installed)
	
	!python 1_python_estimates.py

*********************************************************************************
* Q2 Run the given Stata code

	import delimited "$data_path\kwh.csv", clear
	gen ln_elec=ln(electricity)
	gen ln_sqft=ln(sqft)
	gen ln_temp=ln(temp)
	
	eststo parameter: bootstrap cons=_b[_cons] delta=exp(_b[retrofit]) gamma_sqft=_b[ln_sqft] gamma_temp=_b[ln_temp], reps(1000) seed(1): reg ln_elec retrofit ln_sqft ln_temp, robust
	capture program drop ameboot
	program define ameboot, rclass
	 preserve 
	  bsample
		regress ln_elec retrofit ln_sqft ln_temp, robust
		scalar delta=exp(_b[retrofit])
		scalar gamma_sqft=(_b[ln_sqft])
		scalar gamma_temp=(_b[ln_temp])
		gen dydd=(delta-1)*electricity/(delta^retrofit)
		sum dydd
		scalar mean1 = r(mean)
		gen dyds=gamma_sqft*electricity/sqft
		sum dyds
		scalar mean2 = r(mean)
		gen dydt=gamma_temp*electricity/temp
		sum dydt
		scalar mean3 = r(mean)
		return scalar delta = mean1
		return scalar gamma_sqft = mean2
		return scalar gamma_temp = mean3
	 restore
	end
	
	eststo ame: bootstrap delta = r(delta) gamma_sqft = r(gamma_sqft) gamma_temp = r(gamma_temp), reps(1000) seed(1): ameboot
	
	
	*** Using .tex
	esttab parameter ame using "$table_path\estimates_stata.tex", label replace ///
		cell( 	b(pattern(1 1) fmt(3))      ///
				ci(pattern(1 1) fmt(3) par([ ,  ])) ) ///
		mtitle("Parameter Estimates" "AME Estimates") collabels(none) nostar nonum ///
		coeflabels(cons "Constant" delta "=1 if home received retrofit" gamma_sqft "Square feet of home" gamma_temp "Outdoor average temperature (\textdegree F)") ///
	stats(N, fmt(%15.0fc) label("Observations"))

*********************************************************************************
* End of code
if $export_log == 1{
	log close
	}
