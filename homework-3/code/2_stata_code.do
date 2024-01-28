*********************************************************************************
* AUTHOR		: MAGHFIRA RAMADHANI											*
* PROJECT		: HOMEWORK 2													*
* COURSE		: ECON7103 Environmental Economics II							*
* DESCRIPTION	: Produce balance table, scatterplot, and regression			*
* INPUT			: NA	    													*
* OUTPUT		: .\output\table, .\output\figure								*
* STATA VERSION	: Stata/MP 18.0													*
*********************************************************************************
* Q2.0 Load data

	import delimited "$data_path\kwh.csv"
	label variable electricity "Monthly electricity consumption (kWh)" 
	label variable sqft "Square feet of home" 
	label variable retrofit "=1 if house received retrofit"
	label variable temp "Outdoor average temperature (\textdegree F)"
	gen ln_elec=ln(electricity)
	gen ln_sqft=ln(sqft)
	gen ln_temp=ln(temp)