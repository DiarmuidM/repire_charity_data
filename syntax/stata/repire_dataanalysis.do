// File: benefacts_das.do
// Creator: Diarmuid McDonnell
// Created: 27/02/2018
// Updated: recorded in Github file history
// Repository: https://github.com/DiarmuidM/benefacts_nonprofit_data_ireland

******* Benefacts Charity Data - Data Analysis *******

/* 
	This do file performs the following tasks:
		- opens clean dataset from the most recent download from Benefacts
		- performs some basic analyses
		- saves these analyses as graphs
*/


/* Define paths to the data and syntax */

global projpath "C:\Users\mcdonndz-local\Desktop\github\benefacts_nonprofit_data_ireland\"
global dofiles "$projpath\syntax\"
global rawdata "$projpath\data\data_raw\"
global cleandata "$projpath\data\data_clean\" 
global workingdata "$projpath\data\data_working\" 
global figures "$projpath\figures\"
global findings "$projpath\findings\"

di "$projpath"
di "$dofiles"
di "$rawdata"
di "$cleandata"
di "$workingdata"
di "$figures"
di "$findings"

global ddate `1'
di "$ddate"


/* Open the clean datasets */

// Registered charities

use $cleandata\benefacts_registeredcharities_$ddate.dta, clear
desc, f
count
return list
di r(N) " registered charities on $ddate"

	// Summary statistics and graphs

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

exit, STATA clear
