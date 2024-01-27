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

********************************************************************************
* Q2.1 Create a balance table

	* Generate estimates of mean and std dev, and p-value and t-stat for difference in mean
	eststo control: estpost summarize electricity sqft temp if retrofit == 0
	eststo treatment: estpost summarize electricity sqft temp if retrofit == 1
	eststo differences:  estpost ttest electricity sqft temp, by(retrofit) unequal

	*** Using .tex
	esttab control treatment differences using "$table_path\balance.tex", replace label ///
		cell( mean(pattern(1 1 0) fmt(2))     &  p(pattern(0 0 1) fmt(3)) ///
				sd(pattern(1 1 0) fmt(2) par) & t(pattern(0 0 1) fmt(3) par([ ]) ) ) ///
		mtitle("Control" "Treatment" "P-value")  collabels(none) nonum ///
	stats(N, fmt(%15.0fc) label("Observations"))
	
********************************************************************************
* Q2.2 Create a scatterlplot

	* Generate estimates of mean and std dev
	twoway  (scatter electricity sqft, mcolor(%60)), ///
		legend(off)
		//title("{bf}Scatterplot", pos(11) size(2.75)) ///
		//subtitle("Electricity consumption vs. Square feet of home", pos(11) size(2.5)) ///
		
	graph export "$figure_path\twoway.pdf", replace
	
********************************************************************************
* Q2.2 Run OLS regression

	* Generate OLS estimates
	eststo nonrobust: reg electricity retrofit sqft temp
	eststo robust: reg electricity retrofit sqft temp, robust
	
	*** Using .tex
	esttab nonrobust robust using "$table_path\ols_stata.tex", label replace ///
		cell( 	b(pattern(1 1) fmt(3))      ///
				se(pattern(1 1) fmt(3) par) ) ///
		mtitle("OLS" "OLS with robust s.e.") collabels(none) nostar nonum ///
	stats(rmse, fmt(%15.3fc) label("MSE"))
	