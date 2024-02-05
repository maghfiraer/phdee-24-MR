*********************************************************************************
* AUTHOR		: MAGHFIRA RAMADHANI											*
* PROJECT		: HOMEWORK 3													*
* COURSE		: ECON7103 Environmental Economics II				    		*
* DESCRIPTION	: Setup the profile of the machine running  					*
* INPUT			: NA	    													*
* OUTPUT		: NA                                        					*
* STATA VERSION	: Stata/MP 18.0													*
*********************************************************************************
 
*********************************************************************************
* Installing package
// Install Packages if needed, if not, make a note of this. This should be a comprehensive list of all additional packages needed to run the code.
	if $install_stata_packages == 1 {
		ssc install blindschemes, replace
		ssc install gtools, replace
		ssc install carryforward, replace
		ssc install estout, replace
		net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/")
		net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/")
		ssc install moremata
		ftools, compile
		reghdfe, compile

		ssc install blindschemes, replace
		ssc install coefplot, replace
		ssc install statastates, replace
		ssc install shp2dta, replace
		ssc install sumup, replace

		ssc install distinct, replace
		ssc install unique, replace
		*ssc install statastates, replace
		*net get statastates.dta, replace
		ssc install binscatter, replace
		ssc install palettes, replace
		ssc install colrspace, replace
		ssc install eret2, replace
		*install pbalchk from https://personalpages.manchester.ac.uk/staff/mark.lunt/propensity.html

		ssc install Rscript
		
	}
	else  {
		di "All packages up-to-date"
	}

*********************************************************************************
* Setting graphic scheme

	*graph set window fontface "Times New Roman"
	set scheme plotplainblind, permanently

*********************************************************************************
* Create log file
	
	if $export_log == 1{
		local c_time_date = "`c(current_date)'"+"_" +"`c(current_time)'"
		local time_string = subinstr("`c_time_date'", ":", "_", .)
		local time_string = subinstr("`time_string'", " ", "_", .)
		log using "$path\output\log\homework_3_`time_string'.log", replace
		}

*********************************************************************************
