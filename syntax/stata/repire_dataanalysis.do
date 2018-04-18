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
set scheme s1mono


	// Create a variable that groups charities by province

	gen province = .
	replace province = 1 if county=="CORK" | county=="WATERFORD" | county=="LIMERICK" | county=="KERRY" | county=="CLARE" | county=="TIPPERARY"
	replace province = 2 if county=="MAYO" | county=="GALWAY" | county=="LEITRIM" | county=="ROSCOMMON" | county=="SLIGO"
	replace province = 3 if county=="CARLOW" | county=="DUBLIN" | county=="LAOIS" | county=="MEATH" | county=="WESTMEATH" | county=="OFFALY" | county=="LOUTH" | county=="LONGFORD" | county=="KILDARE" | county=="WICKLOW" | county=="WEXFORD" | county=="KILKENNY"
	replace province = 4 if county=="TYRONE" | county=="ANTRIM" | county=="DONEGAL" | county=="DERRY" | county=="MONAGHAN" | county=="FERMANAGH" | county=="DOWN" | county=="ARMAGH" | county=="CAVAN"
		
	label define prov_label 1 "Munster" 2 "Connacht" 3 "Leinster" 4 "Ulster"
	label values province prov_label
	tab province
	
	
	// Financial characteristics
	
	gen linc = log10(inc + 1)
	gen lexp = log10(exp + 1)
	
	codebook inc exp
	sum inc exp linc lexp , detail
	
	local acol = "gs6"
	local dcol = "erose"
	
	keep if inc>0 & exp>0
	twoway (scatter linc lexp if inc<=5093058 & exp<=4694494) /// 
	(lfit linc lexp if inc<=5093058 & exp<=4694494) ///
	, ///
	xtitle("Gross Expenditure (€,000s)", size(small) color(`acol')) ///
	xlabel(, nogrid labsize(small) labcolor(`acol')) ///
	ytitle("Gross Income (€,000s)", size(small) color(`acol')) ///
	ylabel(, format(%-9.0gc) nogrid labsize(small) labcolor(`acol')) ///
	legend(color(`acol') region(lcolor(white))) ///
	title("Annual Gross Income and Expenditure")  ///
	note("Source: Carthanas Rialalai, Benefacts; n=7775. Produced: $S_DATE", size(small) color(`acol'))	///
	graphregion(fcolor(white)) 
	 
	
	// Non-financial characteristics
		
	tab1 charitystatus legalform subsectorname
	mrtab croreg chyreg ahbreg desreg rfsreg, by(charitystatus) column
	
	// Summary stats - maybe collapse dataset to one observation?
	
	count
		gen regchar_total = r(N)
	count if charitystatus==1
		gen charactive_total = r(N)	
	count if benemerge==3
		gen benechar_total = r(N)
	**count if taxgifts==1
		**gen tax_total = r(N)
	count if governancecode==1
		gen gov_total = r(N)
	count if ictr==1
		gen ictr_total = r(N)
		
	
	// Geographical distribution of charities
		
	preserve
	
		count if county!=""
		
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
			subtitle("By counties of the Rep. of Ireland", span)  ///
			note("Source: Carthanas Rialalai, Benefacts; n=7775. Produced: $S_DATE", size(small)) ///
			blabel(bar, position(outside) format(%9.0f) color(black) size(vsmall)) ///
			ysize(5) ylabel(0(400)2800, nogrid labsize(small)) name(geod, replace)
		
		graph save $figures\repire_countydistribution_$ddate.gph, replace
		graph export $figures\repire_countydistribution_$ddate.png, replace width(4096)
				
	restore
	
		// By province
		
		preserve
			
			count if province!=.
		
			gen freq=1
			collapse (count)freq, by(province)
			desc, f
			count
			list
			sum freq, detail
			table province if province!=. , c(sum freq)			
			
			drop if province==.
			
			graph hbar freq, over(province, sort(freq) descending label(labsize(small))) ///
				legend(off)  ///
				ytitle("No. of Charities") ///
				title("Geographical Distribution of Charities", span)  ///
				subtitle("By provinces of the Rep. of Ireland", span)  ///
				note("Source: Carthanas Rialalai, Benefacts; n=7775. Produced: $S_DATE") ///
				blabel(bar, position(outside) format(%9.0f) color(black) size(vsmall)) ///
				ysize(5) ylabel(0(800)5400, nogrid labsize(small)) name(prov, replace)
			
			graph save $figures\repire_provdistribution_$ddate.gph, replace
			graph export $figures\repire_provydistribution_$ddate.png, replace width(4096)
			
		restore
			
		
	// Sectoral distribution of charities
		
	preserve
		
		gen freq=1
		collapse (count)freq, by(sector)
		desc, f
		count
		list
		sum freq, detail
		table sector if sector!=. , c(sum freq)			
		
		drop if sector==.
		
		graph hbar freq, over(sector, sort(freq) descending label(labsize(vsmall))) ///
			legend(off)  ///
			ytitle("No. of Charities") ///
			title("Sectoral Distribution of Charities", span)  ///
			subtitle("By Benefacts charity classification", span)  ///
			note("Source: Charities Regulator, Benefacts. Produced: $S_DATE") ///
			blabel(bar, position(outside) format(%9.0f) color(black) size(vsmall)) ///
			ysize(5) ylabel(0(300)1800, nogrid labsize(small)) name(sect, replace)
		/*
			Fix overspilling of blabel with graph area.
			
			How do I include sample size in note?
		*/
			
		graph save $figures\repire_sectdistribution_$ddate.gph, replace
		graph export $figures\repire_sectdistribution_$ddate.png, replace width(4096)
				
	restore
	
	
	// Size distribution of charities
		
	preserve
				
		gen freq=1
		collapse (count)freq, by(charitysize)
		desc, f
		count
		list
		sum freq, detail
		table charitysize if charitysize!=. , c(sum freq)			
		
		drop if charitysize==.
		
		graph hbar freq, over(charitysize, sort(freq) descending label(labsize(vsmall))) ///
			legend(off)  ///
			ytitle("No. of Charities") ///
			title("Size Distribution of Charities", span)  ///
			subtitle("By latest gross income", span)  ///
			note("Source: Charities Regulator. Produced: $S_DATE") ///
			blabel(bar, position(outside) format(%9.0f) color(black) size(vsmall)) ///
			ysize(5) ylabel(0(600)3600, nogrid labsize(small)) name(size, replace)
		/*
			Fix overspilling of blabel with graph area.
			
			How do I include sample size in note?
		*/
			
		graph save $figures\repire_sizedistribution_$ddate.gph, replace
		graph export $figures\repire_sizedistribution_$ddate.png, replace width(4096)
				
	restore
	
	
	// Association between size and sector, and sector and province
	
	tab sector charitysize , row all nofreq
	tab sector charitysize , col all nofreq
	tab sector charitysize	
	/*
		Slight association.
		
		Large charities are most likely to be working in Social services (23 per cent) and Development, housing (21 per cent) fields.
		Medium charities are most likely to be the same in reverse order.
		Small charities are most likley to be Social services, philanthropy and religion.
		
		n = 5417
		
		Try a catplot or graph bar.
	*/

	tab sector province , row all nofreq
	tab sector province , col all nofreq
	tab sector province
	/*
	
	*/
	
	tab province charitysize , row all nofreq
	tab province charitysize , col all nofreq
	tab province charitysize
	
	// Regulator statistics
	/*
		Does the Irish Revenue have an API I could access?
	*/
	
	


// Annual Returns

use $cleandata\$ddate\annualreturns_$ddate.dta, clear	
desc, f
count
return list
di r(N) " annual returns on $ddate"	

	// Number of annual returns per charity
		
	preserve
				
		gen freq=1
		collapse (count)freq, by(numreturns)
		desc, f
		count
		list
		sum freq, detail
		table numreturns if numreturns!=. , c(sum freq)			
		
		drop if numreturns==.
		
		graph hbar freq, over(numreturns, sort(freq) descending label(labsize(vsmall))) ///
			legend(off)  ///
			ytitle("No. of Charities") ///
			title("Annual Returns Submitted", span)  ///
			subtitle("Per charity", span)  ///
			note("Source: Charities Regulator. Produced: $S_DATE") ///
			blabel(bar, position(outside) format(%9.0f) color(black) size(vsmall)) ///
			ysize(5) ylabel(0(600)3600, nogrid labsize(small)) name(size, replace)
		/*
			Fix overspilling of blabel with graph area.
			
			How do I include sample size in note?
		*/
			
		graph save $figures\repire_numannreturns_$ddate.gph, replace
		graph export $figures\repire_numannreturns_$ddate.png, replace width(4096)
				
	restore
	
	// Summary statistics
	
	tab charitysize volunteers if volunteers < 7, nofreq col all
	
	xtsum inc
	xtsum exp
	xtsum lninc
	xtsum lnexp
	sum inc exp lninc lnexp, detail
	
exit, STATA clear
