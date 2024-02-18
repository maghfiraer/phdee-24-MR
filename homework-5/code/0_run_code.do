*********************************************************************************
* AUTHOR		: MAGHFIRA RAMADHANI											*
* PROJECT		: HOMEWORK 5													*
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
	
	global path "C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-5"
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
* Q1 Run the given Python code
	
	*!python 1_python_estimates.py //Call from shell
	python script "$code_path\1_python_estimates.py" //Call from pystata
	
*********************************************************************************
* Q2 Run the Stata code

	import delimited "$data_path\instrumentalvehicles.csv", clear
	
	est clear
	eststo: ivregress liml price car (mpg=weight), robust
	weakivtest
	estadd scalar f_stat=r(F_eff)	
	estadd scalar t_crit=r(c_LIML_5) 
	
	*** Using .tex
	esttab using "$table_path\estimates_stata.tex", label replace ///
		order(mpg car) keep(mpg car) ///
		b(2) se(2) ////
		mtitle("IV LIML") collabels(none) nostar nonote nonum ///
		coeflabels(mpg "Miles per gallon" car "=1 if the vehicle is sedan") ///
		scalars("f_stat Montiel-Pflueger F-statistics" "t_crit LIML critical value for $\tau=5\%$") obslast

*********************************************************************************
* End of code
if $export_log == 1{
	log close
	}
