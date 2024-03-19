*********************************************************************************
* AUTHOR		: MAGHFIRA RAMADHANI											*
* PROJECT		: HOMEWORK 8													*
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
	
	global path "C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-8"
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

	use "$data_path\electric_matching", clear
	
	* Generate log of outcome variable
	gen l_mw=log(mw)
	
	* Generate treatment dummy
	format date %td
	gen treatment=0
	replace treatment=1 if date>mdy(3,1,2020)
	
	* Save the processed data_path
	save "$data_path\electric_matching_use", replace
	
	* Q1.(a) Estimate treatment in equation (1)
	ivreghdfe l_mw treatment temp pcp, absorb(zone month dow hour) robust
	
	* Q1.(b) Estimate matching estimator
	encode zone, gen(zone_fac)
	drop if inrange(month,1,2)
	teffects nnmatch (l_mw temp pcp) (treatment), metric(maha) ematch(i.zone_fac i.month i.dow i.hour)
	teffects nnmatch (l_mw temp pcp) (treatment), metric(maha) ematch(i.zone_fac i.month i.dow i.hour) biasadj(temp pcp)
	
	* Q2.(a) Estimate treatment in equation (2)
	use "$data_path\electric_matching_use", clear
	ivreghdfe l_mw treatment temp pcp, absorb(zone month dow hour year) robust
	
	* Q3 Generate year2020
	gen year2020=0
	replace year2020=1 if year==2020
	drop if year<2019
	encode zone, gen(zone_fac)
	drop if inrange(month,1,2)
	teffects nnmatch (l_mw temp pcp) (treatment), metric(maha) ematch(i.zone_fac i.month i.dow i.hour) biasadj(temp pcp) generate(match)
	
	* Q3.(a) 
	predict l_mwhat, po tlevel(0)
	

*********************************************************************************
* End of code
if $export_log == 1{
	log close
	}
