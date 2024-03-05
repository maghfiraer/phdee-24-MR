*********************************************************************************
* AUTHOR		: MAGHFIRA RAMADHANI											*
* PROJECT		: HOMEWORK 7													*
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
	
	global path "C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-7"
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
	*python script "$code_path\1_python_estimates.py" //Call from pystata
	
*********************************************************************************
* Q2 Run the Stata code

	import delimited "$data_path\instrumentalvehicles.csv", clear
	
	* First stage
	rdrobust mpg length, c(225) p(1) //covs(car)
	rdplot mpg length, /// if inrange(length,225-`e(h_l)',225+`e(h_r)'), ///
	c(225) kernel(triangular) covs(car) p(1) genvars ///
	graph_options(ytitle(Fuel efficiency (mpg)) ///
	xtitle(Vehicle length (in)) graphregion(color(white)) legend(off))
	
	* Export graph
	graph export "$figure_path\RD.pdf", replace
	
	rename rdplot_hat_y mpg_hat
	
	est clear
	eststo: reg price mpg_hat car, robust
	
	*** Using .tex
	esttab using "$table_path\estimates_stata.tex", label replace ///
		order(mpg_hat car) keep(mpg_hat car) ///
		star(* .1 ** .05 *** .01) ///
		b(2) se(2) ar2 obslast mtitles("Second-stage estimates") nonum ///
		coeflabels(mpg_hat "Miles per gallon" car "=1 if the vehicle is sedan")
		
	* Checking exclusion restriction
	* Plotting first stage residual vs car type
	gen fs_resid = mpg_hat - mpg
	twoway (hist fs_resid if car==1, frac lcolor(gs12) fcolor(gs12)) ///
		   (hist fs_resid if car==0, frac fcolor(none) lcolor(red)), xtitle("First-stage Residuals") ytitle("Density") legend(order(1 "Sedan" 2 "SUV" ) position(0) bplacement(neast))
	graph export "$figure_path\exclusion.pdf", replace

*********************************************************************************
* End of code
if $export_log == 1{
	log close
	}
