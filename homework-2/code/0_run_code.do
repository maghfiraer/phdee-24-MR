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
	
	global install_stata_packages 0 // Set to 1 for first time running, 0 o/w
	
	* Select option to export log
	
	global export_log 0 // Set to 1 if you want to export log, 0 o/w

	* Set the location of project directory location
	
	global path "C:\Users\mramadhani3\OneDrive - Georgia Institute of Technology\Documents\Spring-24\environmental-econ-ii\phdee-24-MR\homework-1"
	*global data_path "$path\data"
	*global temp_path "$path\temp"
	global code_path "$path\code" 
	global table_path "$path\output\table" 
	global figure_path "$path\output\figure"

	* ON IAC VLAB server, you will need to uncomment this line and run this:
	*sysdir set PERSONAL \\iac.nas.gatech.edu\mramadhani3

	* Set the location of Python and R executable
	
	global RSCRIPT_PATH "C:\Program Files\R\R-4.2.2\bin\x64\Rscript.exe"
	global py_path "C:\Users\mramadhani3\AppData\Local\anaconda3\python.exe"
	global py_user_path "c:\Users\mramadhani3\AppData\Local\anaconda3\Lib\site-packages"

	* Set machine profile
	
	do "$code_path\0_profile.do"

*********************************************************************************
* Run the given Stata code

	do "$code_path\1_sample_stata_code.do"

*********************************************************************************
* Run the given Python code
	
	* You can run the python code externally or directly from inside this do file
	* If you want to run the python from Stata directly, you will need to:
	* 1. Comment some lines in .py (line 6,7,74, and 139), otherwise uncomment
	* 2. Uncomment line 64 below, otherwise comment
	
	*python script "$code_path\2_sample_python_script.py"

*********************************************************************************
* End of code
if $export_log == 1{
	log close
	}
