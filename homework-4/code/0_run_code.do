*********************************************************************************
* AUTHOR		: MAGHFIRA RAMADHANI											*
* PROJECT		: HOMEWORK 4													*
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
	
	global path "C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-4"
	global data_path "$path\data"
	global temp_path "$path\temp"
	global code_path "$path\code" 
	global table_path "$path\output\table" 
	global figure_path "$path\output\figure"

	* ON IAC VLAB server, you will need to uncomment this line and run this:
	*sysdir set PERSONAL \\iac.nas.gatech.edu\mramadhani3

	* Set the location of Python and R executable
	
	global RSCRIPT_PATH "C:\Program Files\R\R-4.2.2\bin\x64\Rscript.exe"
	python set exec C:\Users\mramadhani3\AppData\Local\anaconda3\envs\economics\python.exe
	*python set userpath "C:\Users\mramadhani3\AppData\Local\anaconda3\Lib\site-packages" "C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-2\code"


	* Set machine profile
	
	do "$code_path\0_profile.do"

*********************************************************************************
* Q1 Run the given Python code
	
	*!python 1_python_estimates.py //Call from shell
	python script "$code_path\1_python_estimates.py" //Call from pystata
	
*********************************************************************************
* Q2 Run the Stata code

	import delimited "$data_path\fishbycatch.csv", clear
	reshape long shrimp salmon bycatch, i(firm) j(month)
	tsset firm month
	gen treatit=0
	replace treatit=1 if month>=13 & treated==1
	foreach m of num 1/24 {
		gen t_`m'=0
		replace t_`m'=1 if month==`m'
	}
	foreach f of num 1/50 {
		gen f_`f'=0
		replace f_`f'=1 if firm==`f'
	}
	
	foreach x of varlist bycatch treatit shrimp salmon firmsize {
	egen mean_`x'=mean(`x'), by(firm)
	gen demean_`x'=`x' - mean_`x'
	drop mean*
	}
	
	
	est clear
	eststo: reg bycatch t_* f_* treatit salmon shrimp firmsize, vce(cluster firm)
	estadd local method "Firm indicators"
	eststo: reg demean_bycatch demean_treatit demean_shrimp demean_salmon demean_firmsize
	estadd local method "Within-transformation"
	
	
	*** Using .tex
	esttab using "$table_path\estimates_stata.tex", rename(demean_treatit treatit) label replace ///
		keep(treatit) ///
		b(2) se(2) ////
		mtitle("(a)" "(b)") collabels(none) nostar nonum ///
		coeflabels(treatit "DID estimates") ///
		scalars("method Method") obslast

*********************************************************************************
* End of code
if $export_log == 1{
	log close
	}
