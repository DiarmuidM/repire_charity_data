// File: repire_datacleaning.do
// Creator: Diarmuid McDonnell
// Created: 02/03/2018
// Updated: recorded in Github file history
// Repository: https://github.com/DiarmuidM/repire_charity_data

******* Rep. of Ireland Charity Data - Data Management *******

/* 
	This do file performs the following tasks:
		- imports various csv and excel datasets downloaded from various sources
		- cleans these datasets
		- merges these datasets
		- saves files in Stata format ready for analysis
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


/* Import raw data */

// Charity Register - base dataset
import excel using $rawdata\$ddate\cr_charityregister_$ddate.xlsx, firstrow sheet("Charity Register") clear
count
di r(N) " charities in this Register"
desc, f
codebook *, problems

	// Duplicate records

	duplicates report
	duplicates drop

	duplicates report RegisteredCharityNumber
		duplicates tag RegisteredCharityNumber, gen(dupregnum)
		tab dupregnum
		list if dupregnum>0 // These seem to be genuine data entry errors: drop from data
		drop if dupregnum>0

	duplicates report Name // Plenty of duplicate names; tag and move on
		duplicates tag Name, gen(dupname)
		tab dupname
		
	duplicates report CHYNum
		duplicates tag CHYNum, gen(dupchy)
		tab dupchy
		list CHYNum Name Status if dupchy>0 // Lots of charities without CHY number (unique id from Irish Revenue era of charity regulation)
		
	duplicates report CRONum
		duplicates tag CRONum, gen(dupcro)
		tab dupcro

		
	// Leading and trailing
	
	foreach var in Name Status Asias PrimaryAddress CRONum countryestablished CharitablePurpose CharitableObjects {
		replace `var' = strtrim(`var')
		**replace `var' = subinstr(`var', " ", "", .)
	}
	
	
	// Variable values
	
	codebook *, compact
	
	codebook RegisteredCharityNumber
	list RegisteredCharityNumber, clean
	destring RegisteredCharityNumber, replace
	rename RegisteredCharityNumber charityid
	
	
	codebook Status
	encode Status, gen(charitystatus)
	tab Status charitystatus, nolab
	recode charitystatus 1 2=2 3=1 // Merge the 2 de-registered categories together
	label define charitystatus_lab 1 "Registered" 2 "De-registered"
	label values charitystatus charitystatus_lab
	tab charitystatus
	drop Status
	
	
	codebook CHYNum
	tab CHYNum if missing(real(CHYNum))
	replace CHYNum = "" if missing(real(CHYNum))
	destring CHYNum, replace
	rename CHYNum chynum
	
	
	codebook CRONum
	tab CRONum if missing(real(CRONum)), sort
	// This variable is a mess of numbers, strings and chy numbers. Do not use for analysis.
	/*
	replace CRONum = "" if missing(real(CRONum))
	destring CRONum, replace
	*/
	rename CRONum cronum
	
	
	codebook GoverningForm
	tab GoverningForm, sort
	rename GoverningForm legalform
	
	
	codebook countryestablished
	tab countryestablished
	encode countryestablished, gen(country)
	tab country, nolab
	drop countryestablished
	
	
	codebook CharitablePurpose // Mess of a string variable; keep but don't use for now
	rename CharitablePurpose charpurp
	
	
	codebook CharitableObjects
	rename CharitableObjects charobjects
		
		
	// Set the remaining variables to lower case
	
	foreach var in Name Asias PrimaryAddress {
		rename `var', lower
	}
	
	rename asias alias
		
	
	/* 	Sort data */
	
	sort charityid
	list charityid name , clean noobs
	
	
label variable charityid "Unique id of charity - assigned by Charities Regulator"
label variable name "Name of charity"
label variable alias "Other name of charity"
label variable chynum "Revenue (Charities Unit) number"
label variable cronum "Companies Registration Office number"
label variable legalform "Legal form of charity e.g. Company, Trust"
label variable charpurp "Charitable purpose(s)"
label variable charobjects "Charitable objects"
label variable primaryaddress "Primary address"
label variable dupregnum "Shares registered charity number with another charity"
label variable dupname "Shares name with another charity"
label variable dupchy "Shares CHY number with another charity"
label variable dupcro "Shares CRO number with another charity"

save $workingdata\registeredcharities_$ddate.dta, replace


// Annual returns

import excel using $rawdata\$ddate\cr_charityregister_$ddate.xlsx, firstrow sheet("Annual Reports") clear
count
di r(N) " charity annual returns"
desc, f
codebook *, problems

	// Duplicate records

	duplicates report
	duplicates report entityregnum // Up to four observations per charity seems plausible (i.e. four annual returns); why a charity with 8?
	duplicates tag entityregnum, gen(dupregnum)
	tab dupregnum
	list if dupregnum>3 // I can't make head nor tail of this case; drop
	drop if dupregnum>3
		
	
	// Leading and trailing blanks
	/*
	foreach var in entityregname ReportActivity Beneficiaries reportvolunteercounttypedesc {
		replace `var' = strtrim(`var')
		**replace `var' = subinstr(`var', " ", "", .)
	}
	*/
	
	// Variable values
	
	codebook *, compact
	
	codebook entityregnum
	list entityregnum, clean
	destring entityregnum, replace
	rename entityregnum charityid
	
	
	codebook entityregname
	rename entityregname name
	
	
	codebook reportsizetypedesc
	tab reportsizetypedesc
	encode reportsizetypedesc, gen(charitysize)
	tab reportsizetypedesc charitysize, nolab
	label define charitysize_lab 1 "Large" 2 "Medium" 3 "Small"
	label values charitysize charitysize_lab
	tab charitysize
	drop reportsizetypedesc

	
	codebook ReportActivity // String variable, no use for it at the moment.
	rename ReportActivity activities
	
	
	codebook activitydesc // String variable, no use for it at the moment
	
	
	codebook ReportBeneficiary
	rename ReportBeneficiary beneficiaries // String variable, no use for it at the moment.
	
	
	codebook financialgrossincome
	sum financialgrossincome, detail
	histogram financialgrossincome if financialgrossincome <= r(p90), fraction normal scheme(s1mono)
	rename financialgrossincome inc
	gen lninc = ln(inc + 1)
	histogram lninc, fraction normal scheme(s1mono)
	
	
	codebook financialtotalexpenditure
	sum financialtotalexpenditure, detail
	histogram financialtotalexpenditure if financialtotalexpenditure <= r(p90), fraction normal scheme(s1mono)
	rename financialtotalexpenditure exp
	gen lnexp = ln(exp + 1)
	histogram lnexp, fraction normal scheme(s1mono)
	
	
	codebook reportvolunteercounttypedesc
	tab reportvolunteercounttypedesc, miss
	encode reportvolunteercounttypedesc, gen(volunteers)
	tab reportvolunteercounttypedesc volunteers, nolab
	recode volunteers 1=1 2=7 3=2 4=3 5=4 7=5 6=6
	label define volunteers_lab 1 "1-9" 2 "10-19" 3 "20-49" 4 "250+" 5 "50-249" 6 "None"
	label values volunteers volunteers_lab
	tab volunteers
	drop reportvolunteercounttypedesc
	
	
	codebook periodstartdate
	list periodstartdate in 1/100
	gen tempd = dofc(periodstartdate)
	format tempd %td
	gen byear = year(tempd)
	tab byear
	rename tempd bdate
	
	
	codebook periodenddate
	list periodenddate in 1/100
	gen tempd = dofc(periodenddate)
	format tempd %td
	gen eyear = year(tempd)
	tab eyear
	rename tempd edate
	gen returnyear = eyear
	
		// Most recent annual return
	
		 capture drop latestyr maxyr
		 bysort charityid: egen maxyr = max(returnyear)
		 gen latestyr = .
		 replace latestyr = 1 if maxyr==returnyear
		 tab latestyr
		 list charityid latestyr maxyr returnyear
		
	list bdate edate, clean

	
	/* 	Sort data and set in panel format */
	
	sort charityid returnyear
		duplicates report charityid returnyear
		duplicates list charityid returnyear
		duplicates tag charityid returnyear, gen(dupretyear)
		list charityid returnyear inc bdate edate if dupretyear>0 // Duplicates seem genuine

	**xtset charityid returnyear
	**xtdes // What do I do about edates that fall within the same year for a given charity?
	
		
	// Create a variable to capture the number of returns per charity
	
	bysort charityid: gen numreturns=[_N]
	tab numreturns
	list charityid numreturns in 1/100
	
	
	/* Create a dataset for merging with the Register */
	
	preserve
		
		sort charityid
		keep if latestyr==1
		count
		keep charityid charitysize inc exp volunteers returnyear numreturns
		
		duplicates report charityid returnyear
		duplicates tag charityid, gen(dupcharid)
		duplicates drop charityid, force
		/*
			I need to sort this issue: duplicates of charityid and returnyear.
		*/
		
		sav $workingdata\annreturn_merge_$ddate.dta, replace
		
	restore	


label variable charityid "Unique id of charity - assigned by Charities Regulator"
label variable name "Name of charity"
label variable inc "Annual gross income"
label variable exp "Annual gross expenditure"
label variable charitysize "Categorical bands of annual gross income"
label variable volunteers "Categorical bands of the number of volunteers"
label variable bdate "Beginning of financial year"
label variable edate "End of financial year"
label variable byear "Report start year"
label variable eyear "Report end year"
label variable returnyear "Year financial accounts refer to - FYE"
label variable latestyr "Indicates whether an annual return is a charity's most recent"
label variable maxyr "Most recent annual return"
label variable numreturns "Number of annual returns per charity"
label variable dupregnum "Shares registered charity number with another charity"


save $cleandata\annualreturns_$ddate.dta, replace


// Registered charities - Benefacts dataset

import delimited using $rawdata\$ddate\bene_charityregister_$ddate.csv, varnames(1) clear
count
di r(N) " charities in this Benefacts Register"
desc, f
codebook *, problems

	// Duplicate records

	duplicates report
		capture duplicates tag , gen(dupregnum)
		capture tab dupregnum
		capture list if dupregnum>0
		capture duplicates drop
		capture drop dupregnum

	duplicates report benefactsid
		capture duplicates tag RegisteredCharityNumber, gen(dupregnum)
		capture tab dupregnum
		capture list if dupregnum>0
		capture duplicates drop
		capture drop dupregnum

	duplicates report registeredname // Some duplicate names; tag and move on
		duplicates tag registeredname, gen(dupb_name)
		tab dupb_name
		
	foreach var in cro cra chy des rfs {
		duplicates report `var' if ~missing(`var')
		duplicates tag `var', gen(dupb_`var')
		tab dupb_`var'
	}	
		
		
	// Leading, trailing and embedded blanks
	
	foreach var in registeredname registeredaddress benefactsid rfs {
		replace `var' = strtrim(`var')
		replace `var' = subinstr(`var', " ", "", .)
	}
	
	
	// Unneccessary variables
	
	foreach var in othername1-v38 {
		drop `var'
	}	
	
	// Variable values
	
	codebook *, compact
	
	codebook benefactsid
	list benefactsid, clean
	tab benefactsid if missing(real(benefactsid))
	replace benefactsid = "" if missing(real(benefactsid))
	rename benefactsid beneregid
	
	
	codebook benefactsurl // Use this variable to extract the charityid (so we can link to Benefacts API datasets)
	gen beneid = benefactsurl
	replace beneid = subinstr(beneid, "https://benefacts.ie/org/", "", .)
	replace beneid = subinstr(beneid, "?src=open", "", .)
	list beneid if ~missing(beneid)
	duplicates report beneid
		duplicates tag beneid, gen(dupbeneid)
		tab dupbeneid
		list cra registeredname if dupbeneid>0
		list if dupbeneid>0 // List of blank rows; drop
		duplicates drop beneid, force
	sort beneid
	
	
	codebook subsectorcode
	tab subsectorcode
	tab subsectorname
	
		// Create a new variable to group subsectors
		
		** capture drop sector
		gen sector = subsectorcode
		recode sector 1/1.9=1 2/2.9=2 3/3.9=3 4/4.9=4 5/5.9=5 6/6.9=6 7/7.9=7 8/8.9=8 9/9.9=9 10/10.9=10 11/11.9=11 12/12.9=12
		tab sector
		tab subsectorcode if sector==1 | sector==4 | sector==7
		
		label define sector_label 1 "Arts, culture, media" 2 "Recreation, sports" 3 "Education, research" 4 "Health" 5 "Social services" 6 "Development, housing" ///
			7 "Environment" 8 "Advocacy, law, politics" 9 "Philanthropy, voluntarism" 10 "International" 11 "Religion" 12 "Professional, vocational"
		label values sector sector_label	
		tab sector
		
	
	codebook registeredaddress county // County could be useful.
	
	
	codebook eircode // Lots of missing data
	rename eircode postcode
	
	
	codebook cro
	tab cro // For this variable I'm going to assume that missing data represents charity is not subject to regulation by Companies Registration Office
		gen croreg = 1 if ~missing(cro)
		replace croreg = 0 if missing(cro)
	rename cro b_cronum
	
	
	codebook cra // Charities Regulator unique id
	list cra, clean
	rename cra cranum
	duplicates report cranum // No duplicates for cranum.
	rename cranum charityid
	/*
	gen charityid = cranum if cranum !=.
	duplicates report charityid // Suddenly there's a duplicate charityid!
	duplicates list charityid
		duplicates tag charityid, gen(dupcharid)
		tab dupcharid
		list if dupcharid > 0
	replace charityid = . if dupcharid > 0
	replace charityid = cranum if dupcharid > 0
	duplicates report charityid
	duplicates drop charityid, force
	*/	
	
	
	codebook chy
	tab chy // For this variable I'm going to assume that missing data represents charity is not subject to regulation by Revenue
		gen chyreg = 1 if ~missing(chy)
		replace chyreg = 0 if missing(chy)
	rename chy b_chynum
	
	
	codebook ahb
	tab ahb // For this variable I'm going to assume that missing data represents charity is not subject to regulation by Housing Agency
		gen ahbreg = 1 if ~missing(ahb)
		replace ahbreg = 0 if missing(ahb)
	rename ahb ahbstatus
	
	
	codebook des
	tab des // For this variable I'm going to assume that missing data represents charity is not subject to regulation by Department for Education and Skills
		gen desreg = 1 if ~missing(des)
		replace desreg = 0 if missing(des)
	rename des desstatus
	
	
	codebook rfs
	tab rfs // For this variable I'm going to assume that missing data represents charity not being a Registered Friendly Society
		gen rfsreg = 1 if ~missing(rfs)
		replace rfsreg = 0 if missing(rfs)
	rename rfs rfsnum
		
	
	/* 	Sort data */
	
	sort beneid
	list beneid registeredname , clean noobs
	
label variable charityid "Unique id of charity - assigned by Charities Regulator"	
label variable beneid "Unique id of charity - assigned by Benefacts"
label variable beneregid "Register id of charity - assigned by Benefacts"
label variable registeredname "Name of charity"
label variable sector "Classification of charity i.e. sector it operates in"
label variable b_chynum "Revenue (Charities Unit) number - Benefacts dataset"
label variable b_cronum "Companies Registration Office number - Benefacts dataset"
label variable dupb_name "Shares name with another charity - Benefacts dataset"
label variable dupb_chy "Shares CHY number with another charity - Benefacts dataset"
label variable dupb_cro "Shares CRO number with another charity - Benefacts dataset"
label variable dupb_cra "Shares CRA number with another charity - Benefacts dataset"
label variable dupb_des "Shares DES number with another charity - Benefacts dataset"
label variable dupb_rfs "Shares RFS number with another charity - Benefacts dataset"
/*
	More work to do on labelling variables.
*/

save $workingdata\registeredcharities_bene_$ddate.dta, replace

// Tax Efficient Gifts

import delimited using $rawdata\$ddate\taxefficientgifts_$ddate.csv, varnames(1) clear
count
desc, f
codebook *, problems
label data "List of organisations eligible to claim tax efficient gifts"

	// Duplicate records

	duplicates report // No duplicate records for all variables; try key variables like charity number, unique id etc.
	duplicates report charityid
	duplicates report name
	preserve
		duplicates tag name, gen(dupname)
		list charityid name if dupname==1
	restore	
	/*
		Lots of duplicates for name.
	*/

		
	/* 	Sort data */
	
	rename charityid beneid
	sort beneid // This is Benefacts id, not CR id.
	list beneid name, clean noobs

	
	/* Deal with issues identified by codebook, problems */
	
	// Trim leading, trailing and embedded blanks
	
	replace name = strtrim(name)
	replace name = subinstr(name, " ", "", .)
	list name
	
	// Create a variable to identify the voluntary code charities are complying with:
		
	gen taxgifts = 1
	
label variable beneid "Unique id of charity - assigned by Benefacts"
label variable name "Name of charity"
label variable taxgifts "Eligible for tax efficient gifts"

save $workingdata\taxefficientgifts_$ddate.dta, replace


// Voluntary code members

local volcodes = "GOVERNANCECODE ICTR" // Not including SORP at the moment as there are no observations in the dataset.

foreach volcode in `volcodes' {
	import delimited using $rawdata\$ddate\voluntarycodemembers_`volcode'_$ddate.csv, varnames(1) clear
	count
	desc, f
	codebook *, problems
	label data "List of organisations that comply with `volcode'"

		// Duplicate records

		duplicates report // No duplicate records for all variables; try key variables like charity number, unique id etc.
		duplicates report charityid
		duplicates report name
		preserve
			capture duplicates tag name, gen(dupname)
			capture list charityid name if dupname==1
		restore	
		/*
			One duplicate for name: METHODIST CENTENARY CHURCH.
		*/

			
		/* 	Sort data */
		
		rename charityid beneid
		sort beneid // This is Benefacts id, not CR id.
		list beneid name, clean noobs

		
		/* Deal with issues identified by codebook, problems */
		
		// Trim leading, trailing and embedded blanks
		
		replace name = strtrim(name)
		replace name = subinstr(name, " ", "", .)
		list name
		
		// Create a variable to identify the voluntary code charities are complying with:
		
		gen `volcode' = 1
		
		
	label variable beneid "Unique id of charity - assigned by Benefacts"
	label variable name "Name of charity"
	label variable `volcode' "Complies with `volcode'"
	
	rename `volcode', lower

	save $workingdata\voluntarycodemembers_`volcode'_$ddate.dta, replace
}


/* Merge datasets together */

	// Merge Benefacts datasets

	use $workingdata\$ddate\registeredcharities_bene_$ddate.dta, clear

	merge 1:1 beneid using $workingdata\$ddate\taxefficientgifts_$ddate.dta, keep(match master using)
	tab _merge
	return list
	keep if _merge!=2
	rename _merge taxmerge
	/*
		3,686 organisations registered for tax efficient gifts not matched with registered charities; assume this is because these orgs
		are not charities.
	*/

	merge 1:1 beneid using $workingdata\$ddate\voluntarycodemembers_GOVERNANCECODE_$ddate.dta, keep(match master using)
	tab _merge
	keep if _merge!=2
	rename _merge govmerge
	/*
		14 organisations complying with Governance code not matched with registered charities; assume this is because these orgs
		are not charities.
	*/

	merge 1:1 beneid using $workingdata\$ddate\voluntarycodemembers_ICTR_$ddate.dta, keep(match master using)
	tab _merge
	keep if _merge!=2
	rename _merge ictrmerge
	/*
		39 organisations omplying with ICTR code not matched with registered charities; assume this is because these orgs
		are not charities.
	*/

	replace taxgifts = 0 if taxgifts==.
	replace governancecode = 0 if governancecode==.
	replace ictr = 0 if ictr==.
	tab1 taxgifts governancecode ictr
	desc, f
	count
	sort charityid 

	compress

	save $cleandata\benefacts_registeredcharities_$ddate.dta, replace


	// Merge Benefacts with Charity Register
	
	use $workingdata\registeredcharities_$ddate.dta, clear
	
	duplicates report charityid
	duplicates list charityid
	duplicates drop charityid, force
	
	merge 1:1 charityid using $cleandata\$ddate\benefacts_registeredcharities_$ddate.dta, keep(match master using)
	tab _merge
	keep if _merge!=2
	rename _merge benemerge
	notes: Some registered charities fall outside the definition of nonprofit Benefacts uses to compile its Database of Irish Nonprofits.
	/*
		There is not perfect overlap between the CRA and Benefacts registers for the following reason: 
		Some registered charities fall outside the definition of nonprofit Benefacts uses to compile its Database of Irish Nonprofits
	*/
	
	
	// Merge annual returns with Charity Register
		
	merge 1:1 charityid using $workingdata\$ddate\annreturn_merge_$ddate.dta, keep(match master using)
	tab _merge
	keep if _merge!=2
	rename _merge annretmerge
	/*
		Why so few matches? I guess because these charities haven't had to submit a return yet.
	*/
	
	desc, f
	count

	compress
	
	save $cleandata\registeredcharities_$ddate.dta, replace


	/* Clear working data folder */

pwd
	
local workdir "$workingdata"
cd `workdir'
	
local datafiles: dir "`workdir'" files "*.dta"

foreach datafile of local datafiles {
	rm `datafile'
}

