*********************************************************************************
* AUTHOR		: MAGHFIRA RAMADHANI											*
* PROJECT		: HOMEWORK 1													*
* COURSE		: ECON7103 Environmental Economics II							*
* DESCRIPTION	: Main Code														*
* INPUT			: NA	    													*
* OUTPUT		: .\output\table, .\output\figure, .\output\log					*
* STATA VERSION	: Stata/MP 18.0													*
*********************************************************************************

clear
macro drop _all
set linesize 255
set more off, permanently
capture log close
capture graph drop _all
matrix drop _all

*********************************************************************************
* Setup the profile of your machine

	* Select option to install Stata packages (list package in profile.do)
	global install_stata_packages 0 // Set to 1 for first time running

	* Set the location of project directory location
	global path "C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-1"
	*global data_path "$path\data"
	*global temp_path "$path\temp"
	global code_path "$path\code" 
	global table_path "$path\output\table" 
	global figure_path "$path\output\figure"

	* Set the location of Python and R executable
	global RSCRIPT_PATH "C:\Program Files\R\R-4.2.2\bin\x64\Rscript.exe"
	global py_path "C:\Users\mramadhani3\AppData\Local\anaconda3\python.exe"

	* Set machine profile
	do "$code_path\0_profile.do"

*********************************************************************************
* Run the given Stata code

	do "$code_path\1_sample_stata_code.do"

*********************************************************************************
* Run the given Python code

	python script "$code_path\2_sample_python_script.py"

*********************************************************************************

log close
clear
exit