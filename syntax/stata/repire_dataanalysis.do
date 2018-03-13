// File: benefacts_das.do
// Creator: Diarmuid McDonnell
// Created: 27/02/2018
// Updated: recorded in Github file history
// Repository: https://github.com/DiarmuidM/benefacts_nonprofit_data_ireland

******* Republic of Ireland Charity Data - Data Analysis *******

/* 
	This do file performs the following tasks:
		- opens clean dataset from the most recent download from Benefacts
		- performs some basic analyses
		- saves these analyses as graphs
		
	The analyses should focus on:
		- number and types of charities operating in Ireland
		- latest financial profile of organisations
		- summary statistics for longitudinal data
*/

/* Define paths to the data and syntax */

global projpath "C:\Users\mcdonndz-local\Desktop\github\repire_charity_data"
global datapath "C:\Users\mcdonndz-local\Desktop\data\repire_charity_data"

global dofiles "$projpath\syntax\"
global figures "$projpath\figures\"
global findings "$projpath\findings\"

global rawdata "$datapath\data_raw\"
global cleandata "$datapath\data_clean\" 
global workingdata "$datapath\data_working\" 

di "$projpath"
di "$dofiles"
di "$rawdata"
di "$cleandata"
di "$workingdata"
di "$figures"
di "$findings"


// Take download date from 1st argument of 'dostata' function in repire_master.py, and use it to name files.

global ddate `1'
di "$ddate"


/* Open the clean datasets */

// Registered charities

use $cleandata\$ddate\registeredcharities_$ddate.dta, clear
desc, f
count
return list
di r(N) " registered charities on $ddate"

	// Summary statistics

	tab1 taxgifts governancecode ictr
	tab governancecode ictr, nofreq col all
	return list
	di "The association between governancecode and ictr is " r(CramersV) "***"

	catplot governancecode ictr, percent(ictr) asyvars ///
		ylab(, nogrid labsize(small)) scheme(s1color) ///
		var1opts(gap(*.5)) ///
		blabel(bar, position(inside) format(%9.0f) color(white)) ///
		legend(size(small)) ///
		ytitle("% of charities") ///
		title("Distribution of code compliance") ///
		note("Source: Benefacts Nonprofit Data API (31/12/2016); n=7867. Note: Cramers V=.3401*** Produced: $S_DATE", size(vsmall))
		/*
			I need to think about the best way to present changes in the distribution of icnpo over time.
		*/

	graph save $figures\benefacts_compliancecodes_$ddate.gph, replace
	graph export $figures\benefacts_compliancecodes_$ddate.png, width(4096) replace


// Annual Returns

use $cleandata\$ddate\annualreturns_$ddate.dta, clear	
desc, f
count
return list
di r(N) " annual returns on $ddate"
	
	// Summary statistics
	
	xtsum inc
	xtsum exp
	
	twoway (lfitci inc exp) (scatter inc exp) , ///
		title("Relationship between income and expenditure") ///
		subtitle("Line of best fit and 95% CI") ///
		scheme(s1color)
	
exit, STATA clear

