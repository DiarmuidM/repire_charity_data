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

	preserve
	
		// Non-financial characteristics
		
		tab1 charitystatus legalform subsectorname
		mrtab croreg chyreg ahbreg desreg rfsreg, by(charitystatus) column nofreq
		
		gen freq=1
		collapse (count)freq, by(county)
		desc, f
		count
		list
		sum freq, detail
		table county if county!="" , c(sum freq)			
		
		drop if county==""
		
		graph hbar freq, over(county, sort(freq) descending label(labsize(vsmall))) ///
			legend(off)  ///
			ytitle("No. of Charities") ///
			title("Geographical Distribution of Charities", span)  ///
			subtitle("by counties of the Rep. of Ireland", span)  ///
			note("Source:  CR, Benefacts CR. Produced: $S_DATE") ///
			blabel(bar, position(outside) format(%9.0f) color(black) size(vsmall)) ///
			scheme(s1mono) ysize(5) ylabel(, nogrid) name(geod, replace)
			
		graph save $figures\repire_geogdistribution_$ddate.gph, replace
		graph export $figures\repire_geogdistribution_$ddate.png, replace width(4096)
				
	restore
	
	preserve
	
		
	
	restore


// Annual Returns

use $cleandata\$ddate\annualreturns_$ddate.dta, clear	
desc, f
count
return list
di r(N) " annual returns on $ddate"
	
	// Summary statistics
	
	tab charitysize volunteers if volunteers < 7, nofreq col all
	
	xtsum inc
	xtsum exp
	xtsum lninc
	xtsum lnexp
	sum inc exp lninc lnexp, detail
	
	twoway(scatter inc exp if inc<500000 & exp<500000) (lfitci inc exp if inc<500000 & exp<500000)  , ///
		title("Relationship between income and expenditure") ///
		subtitle("Line of best fit and 95% CI") ///
		scheme(s1color)
		
	graph save $figures\repire_incexp_$ddate.gph, replace
	graph export $figures\repire_incexp_$ddate.png, replace width(4096)
	
	
exit, STATA clear
