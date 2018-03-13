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

// Registered Charities - base dataset
import excel using $rawdata\$ddate\cr_charityregister_$ddate.xlsx, firstrow sheet("Charities") clear
count
di r(N) " charities in this Register"
desc, f
codebook *, problems

	// Duplicate records

	duplicates report // Some duplicate records for all variables:
		duplicates tag , gen(dupregnum)
		tab dupregnum
		list if dupregnum>0 // These seem to be genuine data entry errors: drop from data
		duplicates drop // 16 observations deleted
		drop dupregnum

	duplicates report RegisteredCharityNumber // 2 duplicate records
		duplicates tag RegisteredCharityNumber, gen(dupregnum)
		tab dupregnum
		list if dupregnum>0 // These seem to be genuine data entry errors: drop from data
		duplicates drop // 16 observations deleted
		drop dupregnum

	duplicates report Name // Plenty of duplicate names; tag and move on
		duplicates tag Name, gen(dupname)
		tab dupname
		
	duplicates report CHYNumber
		duplicates tag CHYNumber, gen(dupchy)
		tab dupchy
		
	duplicates report CRONumber
		duplicates tag CRONumber, gen(dupcro)
		tab dupcro

		
	// Leading, trailing and embedded blanks
	
	foreach var in Name Status Alias PrincipalAddress GoverningForm CRONumber CountryEstablished CharitablePurpose CharitableObjects {
		replace `var' = strtrim(`var')
		replace `var' = subinstr(`var', " ", "", .)
	}
	
	
	// Variable values
	
	codebook *, compact
	
	codebook RegisteredCharityNumber
	list RegisteredCharityNumber, clean
	rename RegisteredCharityNumber charityid
	
	
	codebook Status
	encode Status, gen(charitystatus)
	tab Status charitystatus, nolab
	recode charitystatus 1 2=2 3=1 // Merge the 2 de-registered categories together
	label define charitystatus_lab 1 "Registered" 2 "De-registered"
	label values charitystatus charitystatus_lab
	tab charitystatus
	drop Status
	
	
	codebook CHYNumber
	tab CHYNumber if missing(real(CHYNumber))
	replace CHYNumber = "" if missing(real(CHYNumber))
	destring CHYNumber, replace
	rename CHYNumber chynum
	
	
	codebook CRONumber
	tab CRONumber if missing(real(CRONumber)), sort
	// This variable is a mess of numbers, strings and chy numbers. Do not use for analysis.
	/*
	replace CRONumber = "" if missing(real(CRONumber))
	destring CRONumber, replace
	*/
	rename CRONumber cronum
	
	
	codebook GoverningForm
	tab GoverningForm, sort // Also a complete mess of a string variable. Keep but try not to use for analysis.
	rename GoverningForm legalform
	
	/*
	codebook CharitablePurpose
	split CharitablePurpose, p(";")
	tab1 CharitablePurpose1-CharitablePurpose16
	*list CharitablePurpose1-CharitablePurpose16
	*drop if CharitablePurpose1=="1.Maintainingleafletproduction(andotherinformation)forfamiliesofhomicidevictims,outliningallservicesavailabletothem.2.Maintenanceofwebsiteforfamiliesofhomicidevictims.3.Providingseminars/trainingforagencies/personsthatworkwithfamiliesofhomicidevictims.4.Organisingopenmeetingsandabi-annualmemorialserviceforfamiliesofhomicidevictims.5.Counselling:Provisionofcounsellingservices(freeofcharge)forfamilymembersofhomicidevictims.6.Makingrepresentationsandsubmissionsontheneedsoffamiliesofhomicidevictimstotherelevantstatutoryandnon-statutoryorganisations.7.Raisingfundstoprovidearangeofservicestothefamiliesofhomicidevictims.8.Liaisingwithotherserviceprovidersinthisareatoensurethatservicesarenotduplicated.9.Liaisinganddealingwithallmediaonarangeofmattersaffectigthefamiliesofhomicidevictims"

		// Now for some tidying up before I do a count of each charitable purpose mentioned
		
		foreach purp in CharitablePurpose1-CharitablePurpose16 {
			rename `purp', lower
		}
		
		local charpurplist = "Preventionorreliefofpovertyoreconomichardship Advancementofeducation Advancementofreligion Advancementofcommunitywelfareincludingthereliefofthoseinneedbyreasonofyouth,age,ill-healthordisability Advancementofcommunitydevelopment,includingurbanorruralregeneration Promotionofcivicresponsibilityorvoluntarywork Promotionofhealthincludingthepreventionorreliefofsickness,diseaseorhumansuffering Advancementofconflictresolutionorreconciliation Promotionofreligiousorracialharmonyandharmoniouscommunityrelations Protectionofthenaturalenvironment Advancementofenvironmentalsustainability Advancementoftheefficientandeffectiveuseofthepropertyofcharitableorganisations Preventionorreliefofsufferingofanimals Advancementofthearts,culture,heritageorsciences Integrationofthosewhoaredisadvantaged,andthepromotionoftheirfullparticipationinsociety"

		forvalues cpvarcounter = 1(1)16 {
			local counter=1
			gen cpresponse`cpvarcounter'=0
			foreach cpitem in `charpurplist' {
				replace cpresponse`cpvarcounter'=`counter' if charitablepurpose`cpvarcounter'=="`cpitem'"
				local counter = `counter' + 1
			 }
		}


		egen charpurp1=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==1 | cpresponse2==1 | cpresponse3==1 | cpresponse4==1 | cpresponse5==1 | cpresponse6==1 | cpresponse7==1 | cpresponse8==1 | cpresponse9==1 | cpresponse10==1 | cpresponse11==1 | cpresponse12==1 | cpresponse13==1 | cpresponse14==1 | cpresponse15==1 | cpresponse16==1
		egen charpurp2=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==2 | cpresponse2==2 | cpresponse3==2 | cpresponse4==2 | cpresponse5==2 | cpresponse6==2 | cpresponse7==2 | cpresponse8==2 | cpresponse9==2 | cpresponse10==2 | cpresponse11==2 | cpresponse12==2 | cpresponse13==2 | cpresponse14==2 | cpresponse15==2 | cpresponse16==2
		egen charpurp3=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==3 | cpresponse2==3 | cpresponse3==3 | cpresponse4==3 | cpresponse5==3 | cpresponse6==3 | cpresponse7==3 | cpresponse8==3 | cpresponse9==3 | cpresponse10==3 | cpresponse11==3 | cpresponse12==3 | cpresponse13==3 | cpresponse14==1 | cpresponse15==3 | cpresponse16==3
		egen charpurp4=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==4 | cpresponse2==4 | cpresponse3==4 | cpresponse4==4 | cpresponse5==4 | cpresponse6==4 | cpresponse7==4 | cpresponse8==4 | cpresponse9==4 | cpresponse10==4 | cpresponse11==4 | cpresponse12==4 | cpresponse13==4 | cpresponse14==1 | cpresponse15==4 | cpresponse16==4
		egen charpurp5=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==5 | cpresponse2==5 | cpresponse3==5 | cpresponse4==5 | cpresponse5==5 | cpresponse6==5 | cpresponse7==5 | cpresponse8==5 | cpresponse9==5 | cpresponse10==5 | cpresponse11==5 | cpresponse12==5 | cpresponse13==5 | cpresponse14==1 | cpresponse15==5 | cpresponse16==5
		egen charpurp6=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==6 | cpresponse2==6 | cpresponse3==6 | cpresponse4==6 | cpresponse5==6 | cpresponse6==6 | cpresponse7==6 | cpresponse8==6 | cpresponse9==6 | cpresponse10==6 | cpresponse11==6 | cpresponse12==6 | cpresponse13==6 | cpresponse14==1 | cpresponse15==6 | cpresponse16==6
		egen charpurp7=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==7 | cpresponse2==7 | cpresponse3==7 | cpresponse4==7 | cpresponse5==7 | cpresponse6==7 | cpresponse7==7 | cpresponse8==7 | cpresponse9==7 | cpresponse10==7 | cpresponse11==7 | cpresponse12==7 | cpresponse13==7 | cpresponse14==1 | cpresponse15==7 | cpresponse16==7
		egen charpurp8=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==8 | cpresponse2==8 | cpresponse3==8 | cpresponse4==8 | cpresponse5==8 | cpresponse6==8 | cpresponse7==8 | cpresponse8==8 | cpresponse9==8 | cpresponse10==8 | cpresponse11==8 | cpresponse12==8 | cpresponse13==8 | cpresponse14==1 | cpresponse15==8 | cpresponse16==8
		egen charpurp9=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==9 | cpresponse2==9 | cpresponse3==9 | cpresponse4==9 | cpresponse5==9 | cpresponse6==9 | cpresponse7==9 | cpresponse8==9 | cpresponse9==9 | cpresponse10==9 | cpresponse11==9 | cpresponse12==9 | cpresponse13==9 | cpresponse14==1 | cpresponse15==9 | cpresponse16==9
		egen charpurp10=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==10 | cpresponse2==10 | cpresponse3==10 | cpresponse4==10 | cpresponse5==10 | cpresponse6==10 | cpresponse7==10 | cpresponse8==10 | cpresponse9==10 | cpresponse10==10 | cpresponse11==10 | cpresponse12==10 | cpresponse13==10 | cpresponse14==1 | cpresponse15==10 | cpresponse16==10
		egen charpurp11=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==11 | cpresponse2==11 | cpresponse3==11 | cpresponse4==11 | cpresponse5==11 | cpresponse6==11 | cpresponse7==11 | cpresponse8==11 | cpresponse9==11 | cpresponse10==11 | cpresponse11==11 | cpresponse12==11 | cpresponse13==11 | cpresponse14==1 | cpresponse15==11 | cpresponse16==11
		egen charpurp12=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==12 | cpresponse2==12 | cpresponse3==12 | cpresponse4==12 | cpresponse5==12 | cpresponse6==12 | cpresponse7==12 | cpresponse8==12 | cpresponse9==12 | cpresponse10==12 | cpresponse11==12 | cpresponse12==12 | cpresponse13==12 | cpresponse14==1 | cpresponse15==12 | cpresponse16==12
		egen charpurp13=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==13 | cpresponse2==13 | cpresponse3==13 | cpresponse4==13 | cpresponse5==13 | cpresponse6==13 | cpresponse7==13 | cpresponse8==13 | cpresponse9==13 | cpresponse10==13 | cpresponse11==13 | cpresponse12==13 | cpresponse13==13 | cpresponse14==1 | cpresponse15==13 | cpresponse16==13
		egen charpurp14=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==14 | cpresponse2==14 | cpresponse3==14 | cpresponse4==14 | cpresponse5==14 | cpresponse6==14 | cpresponse7==14 | cpresponse8==14 | cpresponse9==14 | cpresponse10==14 | cpresponse11==14 | cpresponse12==14 | cpresponse13==14 | cpresponse14==1 | cpresponse15==14 | cpresponse16==14
		egen charpurp15=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==15 | cpresponse2==15 | cpresponse3==15 | cpresponse4==15 | cpresponse5==15 | cpresponse6==15 | cpresponse7==15 | cpresponse8==15 | cpresponse9==15 | cpresponse10==15 | cpresponse11==15 | cpresponse12==15 | cpresponse13==15 | cpresponse14==1 | cpresponse15==15 | cpresponse16==15
		egen charpurp16=count(cpresponse1 + cpresponse2 + cpresponse3 + cpresponse4 + cpresponse5 + cpresponse6 + cpresponse7 + cpresponse8 + cpresponse9 + cpresponse10 + cpresponse11 + cpresponse12 + cpresponse13 + cpresponse14 + cpresponse15 + cpresponse16) if cpresponse1==16 | cpresponse2==16 | cpresponse3==16 | cpresponse4==16 | cpresponse5==16 | cpresponse6==16 | cpresponse7==16 | cpresponse8==16 | cpresponse9==16 | cpresponse10==16 | cpresponse11==16 | cpresponse12==16 | cpresponse13==16 | cpresponse14==1 | cpresponse15==16 | cpresponse16==16

		sum charpurp1-charpurp16 // These variables are useful for descriptive purposes as I can report which purpose is most common etc.
		
		// Create a dummy variable indicating the presence of each purpose
			
		local counter = 1	
		foreach var in charpurp1-charpurp16 {
			sum `var'
			label variable `var' "Charitable Purpose `counter'"
			local counter = counter + 1
		}	
		
		tab1 charpurp1-charpurp16
		
	*/		
	// Set the remaining variables to lower case
	
	foreach var in Name Alias PrincipalAddress CharitableObjects CountryEstablished {
		rename `var', lower
	}
		
	
	/* 	Sort data */
	
	sort charityid
	list charityid name , clean noobs
	
	
label variable charityid "Unique id of charity - assigned by Charities Regulator"
label variable name "Name of charity"
label variable chynum "Revenue (Charities Unit) number"
label variable cronum "Companies Registration Office number"
label variable legalform "Legal form of charity e.g. Company, Trust"
label variable dupname "Shares name with another charity"
label variable dupchy "Shares CHY number with another charity"
label variable dupcro "Shares CRO number with another charity"

save $workingdata\$ddate\registeredcharities_$ddate.dta, replace


// Annual returns

import excel using $rawdata\$ddate\cr_charityregister_$ddate.xlsx, firstrow sheet("Annual Reports") clear
count
di r(N) " charity annual returns"
desc, f
codebook *, problems

	// Duplicate records

	duplicates report
		
	
	// Leading, trailing and embedded blanks
	
	foreach var in CharityName Activities ActivitiesDescription FinancialTotalExpenditure Beneficiaries VolunteerCount {
		replace `var' = strtrim(`var')
		replace `var' = subinstr(`var', " ", "", .)
	}
	
	
	// Variable values
	
	codebook *, compact
	
	codebook RegisteredCharityNumber
	list RegisteredCharityNumber, clean
	rename RegisteredCharityNumber charityid
	
	
	codebook CharityName
	rename CharityName name
	
	
	codebook ReportSize
	tab ReportSize
	encode ReportSize, gen(charitysize)
	tab ReportSize charitysize, nolab
	label define charitysize_lab 1 "Large" 2 "Medium" 3 "Small"
	label values charitysize charitysize_lab
	tab charitysize
	drop ReportSize

	
	codebook Activities // String variable, no use for it at the moment.
	rename Activities activities
	
	
	codebook ActivitiesDescription // String variable, no use for it at the moment.
	rename ActivitiesDescription activities_des
	
	
	codebook Beneficiaries
	rename Beneficiaries beneficiaries // String variable, no use for it at the moment.
	
	
	codebook FinancialGrossIncome
	sum FinancialGrossIncome, detail
	histogram FinancialGrossIncome if FinancialGrossIncome <= r(p90), fraction normal scheme(s1mono)
	rename FinancialGrossIncome inc
	gen lninc = ln(inc + 1)
	histogram lninc, fraction normal scheme(s1mono)
	
	
	codebook FinancialTotalExpenditure
		tab FinancialTotalExpenditure if missing(real(FinancialTotalExpenditure))
		replace FinancialTotalExpenditure = "" if missing(real(FinancialTotalExpenditure))
		destring FinancialTotalExpenditure, replace
	sum FinancialTotalExpenditure, detail
	histogram FinancialTotalExpenditure if FinancialTotalExpenditure <= r(p90), fraction normal scheme(s1mono)
	rename FinancialTotalExpenditure exp
	gen lnexp = ln(exp + 1)
	histogram lnexp, fraction normal scheme(s1mono)
	
	
	codebook VolunteerCount
	tab VolunteerCount, miss
	encode VolunteerCount, gen(volunteers)
	tab VolunteerCount volunteers, nolab
	recode volunteers 1=1 2=7 3=2 4=3 5=4 7=5 6=6
	label define volunteers_lab 1 "None" 2 "1-9" 3 "10-19" 4 "20-49" 5 "50-249" 6 "250+" 7 "Unspecified range"
	label values volunteers volunteers_lab
	tab volunteers
	drop VolunteerCount
	
	
	codebook ReportStartDate
	gen byear = year(ReportStartDate)
	tab byear
	rename ReportStartDate bdate
	
	
	codebook ReportEndDate
	gen eyear = year(ReportEndDate)
	tab eyear // Use this as Financial Year End measure
	rename ReportEndDate edate
	gen returnyear = eyear
	
	
	list bdate edate, clean

	
	/* 	Sort data and set in panel format */
	
	sort charityid edate
	xtset charityid edate
	xtdes // What do I do about edates that fall within the same year for a given charity?

/*	
label variable charityid "Unique id of charity - assigned by Charities Regulator"
label variable name "Name of charity"
label variable chynum "Revenue (Charities Unit) number"
label variable cronum "Companies Registration Office number"
label variable legalform "Legal form of charity e.g. Company, Trust"
label variable dupname "Shares name with another charity"
label variable dupchy "Shares CHY number with another charity"
label variable dupcro "Shares CRO number with another charity"
*/

save $cleandata\$ddate\annualreturns_$ddate.dta, replace


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

save $workingdata\$ddate\registeredcharities_bene_$ddate.dta, replace

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

save $workingdata\$ddate\taxefficientgifts_$ddate.dta, replace


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

	save $workingdata\$ddate\voluntarycodemembers_`volcode'_$ddate.dta, replace
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

	save $cleandata\$ddate\benefacts_registeredcharities_$ddate.dta, replace


	// Merge Benefacts with CR dataset
	
	use $workingdata\$ddate\registeredcharities_$ddate.dta, clear
	
	duplicates report charityid
	duplicates list charityid
	duplicates drop charityid, force
	
	merge 1:1 charityid using $cleandata\$ddate\benefacts_registeredcharities_$ddate.dta, keep(match master using)
	tab _merge
	keep if _merge!=2
	rename _merge benemerge
	
	desc, f
	count

	compress
	
	save $cleandata\$ddate\registeredcharities_$ddate.dta, replace

/* Clear working data folder */

pwd
	
local workdir "$workingdata"
cd `workdir'
	
local datafiles: dir "`workdir'" files "*.dta"

foreach datafile of local datafiles {
	rm `datafile'
}

