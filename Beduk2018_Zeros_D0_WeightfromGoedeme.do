
/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2018). Understanding material deprivation for 25 EU countries: risk and level perspectives, and distinctiveness of zeros. European Sociological Review, 34(2), 121-137.

Author: Selçuk Bedük 

Date of code: 4 December 2017

Purpose: Creating EU-SILC weights using the code provided by Tim Goedeme (see details below) 

Inputs: EU SILC 2009; household, register and individual core modules including deprivation module  

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.
See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview
See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896
See for data availability table: https://ec.europa.eu/eurostat/documents/203647/771732/Datasets-availability-table.pdf 

Outputs: 2009d_Goedeme_surveydesign
*/





*Re-construction EU-SILC sample design variables
*EU-SILC UDB 2009, version 4
*Tim Goedeme

*contact details:

// Herman Deleeck Centre for Social Policy
// University of Antwerp
// St. Jacobstraat 2
// 2000 Antwerp (Belgium)

// e-mail: tim.goedeme at ua.ac.be
// T.: +32 3 265 55 55

// http://www.ua.ac.be/tim.goedeme
// http://www.centreforsocialpolicy.eu



*As EU-SILC is based on a sample, all estimates should be accompanied by standard errors and confidence intervals.
 // The sample design may strongly affect estimated standard errors and confidence intervals and, as a result, cannot be ignored.
 // This do-file prepares the EU-SILC sample design variables, which can be used to take as much as possible account of the sample design.
 // More precisely, the do-file creates two new variables psu1 (Primary sampling units) and strata1 (primary strata).
 // The sample design variables included in the UDB display some inaccuracies.
 // This do-file tries to correct some of these inaccuracies, but is not perfect. 
 // In general, due to the limited information available, the effect of implicit stratification and calibration is ignored.
 // Please note that the psu1 and strata1 are constructed such that they allow for estimates in relation to aggregates of countries.
 // This do-file should be run on the D-file of the EU-SILC UDB, before merging this file with any of the other (H, R, P) EU-SILC UDB data files.
 // When using this do-file, you take the sole responsibility for the results obtained.
 // However, if you have any question or encounter a problem, do not hesitate to contact me (see details above).
 // More information the EU-SILC sample design variables and the importance of using them in any EU-SILC analysis can be found in the article quoted below.
 // Please be so kind to cite the article below when using this do-file:

*Goedeme, T. (2013), "How much confidence can we have in EU-SILC?", Social Indicators Research, 110(1):89-110; http://dx.doi.org/doi:10.1007/s11205-011-9918-2.

* The creation of this do-file has been partially funded by Net-SILC2, the Second Network for the Analysis of EU-SILC. Eurostat has no responsibility for this do-file.

clear
set more off


*Indicate the place where the D-file of the EU-SILC data is stored
// the do-file will save the D-file with the two new variables in exactly the same location
// Please check whether the naming of the data files is correct and corresponds to your whishes.


*Note that the variables in this do-file are in uppercase. To ensure that your dataset contains variable names in uppercase:

use "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files\2009-4d.dta", clear

foreach var of varlist _all {
	local newname = upper("`var'")
	cap rename `var' `newname'
}


*0. Preparation
***************

*generate country and hid variable

cap rename DB020 country
cap rename COUNTRY country

cap drop countryNR
encode country, gen(countryNR)

cap rename DB030 hid
cap rename HID hid

****************************************
* store all country labels in a global *
****************************************
 //a similar command, with somewhat different output, is provided by "levelsof"
 
local varlist country
sort `varlist'
tempvar tesje
qui: gen `tesje'=1 if `varlist'[_n]!=`varlist'[_n-1]
sort `tesje' `varlist'
qui: count if `tesje'==1
local nrvalues=r(N)
global countries
local counter=1
while `counter'<=`nrvalues' {
	local value1=`varlist'[`counter']
	local value2=`varlist'[`counter'-1]
	if "`value1'"!="`value2'" {
		global countries ${countries} `value1'
	}
	local counter=`counter'+1
}
global ncountries=wordcount("${countries}")
display "${countries}"
display "number of countries in datafile: " $ncountries


***************************************************
*Special cases that have to be handled before rest*
***************************************************
cap drop psutest
gen psutest=DB060

*1. Austria
************

*In the case of AT, DB060 is partially missing, but this corresponds to sample design:
*AT: DB060 when available, otherwise hid
*DB060 is unique across strata, but currently no re-grouping is required, as it is the first wave a two-stage sample design has been implemented

*2. Belgium
************
*DB060 is missing, but DB070 contains the order of selection of PSUs and can be used as a PSU variable instead.
*replace psutest=DB070 if country=="BE"
*-> does not apply to version 4 of 2009 UDB, only to earlier versions of the data


*3. Czech Republic: DB060 not uniqe across panels
*************************************************
replace psutest=DB060*10+DB075 if country=="CZ"

*4. France: self-representing PSUs
***********************************
*In France 53 PSUs are self-representing and for them DB062 should be filled
*In principle they refer to urban regions of more than 100,000 inhabitants.
*Also urban regions with between 20,000 and 100,000 inhabitants are sampled in several stages, with DB062 filled.

*As a result, the 53 self-representing PSUs should be the biggest ones (weighted number of households)

cap drop poppsu
cap drop groups

bysort country DB060: egen poppsu=sum(DB090)

replace poppsu=. if country!="FR" | (country=="FR" & DB062==.)
gsort -poppsu, gen(groups)

*tab DB060 if groups<=53
*Be careful: some DB062 have same code as some DB060!

replace psutest=DB062+0.1 if groups<=53 & country=="FR"

*5. Italy
*********

*Two stage sample design, rotation at PSU level. Large municipalities are self-representing and remain always in the sample.
*-> detect DB060 appearing in at least three out of four panels DB075, assume these are self-representing
*-> DB062 is filled, but if made unique by DB060, simply acts as a household identifier (as many hid as unique DB062)


cap drop constant
cap drop npanels
gen constant=1
sort country DB060 DB075
replace constant=. if DB060[_n]==DB060[_n-1] & DB075[_n]==DB075[_n-1]
bysort country DB060: egen npanels=sum(constant)
sort country DB060
ta npanels if country=="IT" & DB060[_n]!=DB060[_n-1]

replace psutest=DB062+0.1 if npanels==4 & country=="IT"

cap drop tester
gen tester=DB060 if npanels==4 & country=="IT"
cap drop groupsit
gsort tester, gen(groupsit)



*6. Latvia
***********


*1. make DB060 unique across DB075
*PSUs are drawn separately for each rotational panel, but PSU codes are not unique across DB075 in the case of multiple hits, 
***so they should be made unique across DB075 (in principle not doing so should not bias variance estimates).

replace psutest=DB060*10+DB075 if country=="LV"



*2. Allocate split-off households randomly to PSUs of same rotational panel

*In the case of LV, DB060 is missing for 47 households. These are split-off households for which the orginal PSU is not given.
*Missing PSU codes could be randomly filled (alternatively, they could be dropped):
***If PSUcodes are randomly assigned, care is needed as PSUs are re-drawn for every panel. As a result, split-off households should be grouped with PSUs of the correct rotational panel.
***--> *since version 2 of EU-SILC 2009 this is no longer a problem, so can be ignored.


ta country if country=="LV" & DB060==.
local missinglv=r(r)

if `missinglv'!=0 {
	qui: tab DB075 if country=="LV", matrow(LVvals75)
	local nrows=rowsof(LVvals75)
	local vals75
	forvalues x=1/`nrows' {
		local value=el(LVvals75, `x', 1)
		local vals75 `vals75' `value'
	}
	local psuLV psuLV
	cap drop psuLV
	gen `psuLV'=.
	set seed 0001
	foreach panel of local vals75 {
		di "panel no. `panel'"
		
		cap mat drop mat075
		qui: tab psutest if country=="LV" & DB060!=. & DB075==`panel', matrow(mat075)

		local uni060lv=r(r)

		di "No. of PSUs in panel: `uni060lv'"
		
		if `uni060lv'>1 {
			replace `psuLV'=1+int((`uni060lv')*runiform()) if country=="LV" & DB060==. & DB075==`panel'
			replace psutest=el(mat075, `psuLV', 1) if country=="LV" & DB060==. & DB075==`panel'
		}
	}
	sort country DB075 psutest
	list DB060 psutest DB075 if country=="LV" & DB060==.
}

*7. Slovenia
************
*Most probably, DB060 codes are not unique across DB075.

*replace psutest=DB060*10+DB075 if country=="SI"
*no longer a problem for UDB 2009, version 4

*8. United Kingdom
*******************
*1. Northern Ireland is a self-representing PSU
*** The self-representing PSU (Northern Ireland) is recognisable as the PSU with the largest number of households, the only PSU which appears in the 4 rotational panels, the PSU with the largest number of households and the only PSU with missing values for DB070.
*** self-representing PSU is itself a stratum & PSUs within this stratum are households

cap drop cons
gen cons=1 if country=="UK"
cap drop nrpsu
bysort country DB060: egen nrpsu=total(cons==1) if country=="UK"

sum nrpsu if country=="UK"
local max=r(max)

ta npanels if country=="UK" & DB060[_n]!=DB060[_n-1]

ta nrpsu npanels if country=="UK"

sum DB060 if npanels==4 & country=="UK"
local test1=r(min)
sum DB060 if nrpsu==`max' & country=="UK"
local test2=r(min)
sum DB060 if DB070==. & country=="UK"
local test3=r(min)

if `test1'!=`test2' | `test1'!=`test3' {
	di in red "There is a problem with finding Northern Ireland, please mail this error to tim.goedeme@ua.ac.be"
	exit
}
else replace psutest=. if npanels==4 & country=="UK"

*2 if households move to another postcode sector, they form a new DB060 code. 
***That is why the number of PSUs is higher than those reported 
*-> unfortunately, there are too many PSUs (DB060) which contain only 1 household, otherwise they could be randomly merged with other PSUs...
*bysort country DB060: egen nhid=count(hid)
*sort country DB060
*ta nhid if country=="UK" & DB060[_n]!=DB060[_n-1]


*********************************
*Prepare Stratification variable*
*********************************

global stratcs AT BE BG CZ ES FR GR HU IT PL RO

cap drop region0
gen region0=""
foreach ctry of global stratcs {
	replace region0=DB040 if country=="`ctry'"
}
replace region0="ES80" if DB040=="ES63"|DB040=="ES64" //Melilla (ES64) and Ceuta (ES63) must be grouped together as they are part of the same stratum.

cap drop region1
encode region0, gen(region1)
replace region1=0 if region1==.
sum region1
local min=r(max)

replace region1=groups+`min' if country=="FR" & groups<=53
sum region1
local min=r(max)
replace region1=groupsit+`min' if country=="IT" & npanels==4

sum region1
local minimum=r(max)
local maximum=10

while `maximum'<=`minimum' {
local maximum=`maximum'*10
}
cap drop strata0
gen strata0=countryNR*`maximum'+region1

sum strata0 if country=="UK"
local stratum=r(max)+2
replace strata0=`stratum' if country=="UK" & psutest==.

sum strata0


**********************
*Prepare PSU variable*
**********************

sum hid
local minimum1=r(max)
local maximum1=10
while `maximum1'<=`minimum1' {
local maximum1=`maximum1'*10
}

sum psutest
local minimum2=r(max)
local maximum2=10

while `maximum2'<=`minimum2' {
local maximum2=`maximum2'*10
}

cap drop psu0
gen double psu0=.
replace psu0=strata0*`maximum2'+hid/`maximum1'
replace psu0=strata0*`maximum2'+psutest if psutest!=.


sum psu0


*********************
*RE-grouping of PSUs*
*********************
*(AT), BE, CZ, ES, FR, HU(?), IT, RO: re-group split PSUs!

* In the case of several countries, stratification by DB040 causes PSUs to be split across regions because
*of households moving between moment of selection and moment of interview. Hence, households that have moved, should be re-allocated to the correct stratum

***please note that in the case of Poland, PSU codes are not unique across strata and therefore should split after stratification, re-grouping would do more harm than good
*** in other countries for which DB060!=., no households have moved between moment of selection and moment of interview.

set more off
global countrypsu BE ES FR HU IT RO


cap drop checker
gen checker=.

sort country psutest hid

cap drop nocheck
gen nocheck=1 if psutest==. | (country=="FR" & groups<=53) | (country=="IT" & npanels==4)

replace checker=0 if psu0[_n-1]!=psu0[_n] & psutest[_n-1]!=psutest[_n] | nocheck==1
replace checker=0 if psu0[_n-1]==psu0[_n] & psutest[_n-1]==psutest[_n] & nocheck!=1
replace checker=1 if psu0[_n-1]!=psu0[_n] & psutest[_n-1]==psutest[_n] & nocheck!=1
replace checker=2 if psu0[_n-1]==psu0[_n] & psutest[_n-1]!=psutest[_n] & nocheck!=1

*reset checker to 0 if PSUs must be split across strata

foreach ctry of global countries {
	di "`ctry'", _continue
	replace checker=0 if country=="`ctry'" & strpos("${countrypsu}", "`ctry'")==0
}
sort country psu0
foreach ctry of global countrypsu {
	tab country checker if country=="`ctry'" & psu0[_n]!=psu0[_n-1]
}
set more off


cap drop strata1
gen strata1=strata0

foreach ctry of global countrypsu {
	global psu`ctry'
	di "`ctry'"
	tab psutest if country=="`ctry'" & checker==1, matrow(psu`ctry') // if you don't want the output, change to qui: tab etc.
	local rows=rowsof(psu`ctry')
	forvalues x=1/`rows' {
		local nr=el(psu`ctry', `x',1)
		global psu`ctry' ${psu`ctry'} `nr' 
	}
	di "${psu`ctry'}"
}


foreach ctry of global countrypsu {
	di "`ctry'"
	
	foreach psu of global psu`ctry' {
		local check1
		local check2
		local check3
		
		
		tab psutest strata0 if country=="`ctry'" & psutest==`psu', matcell(freq1) matcol(stratname) // if you don't want this output, change to qui: tab
		local cols=r(c)
		forvalues y=1/`cols' {
			local check1=el(freq1, 1, `y')
			if `y'<`cols' {
				local check2 `check2' `check1',
			}
			if `y'==`cols' {
				local check2 `check2' `check1'
			}
		}
		local check3=max(`check2')
		
		forvalues y=1/`cols' {
			if el(freq1, 1, `y')==`check3' {
			replace strata1=el(stratname, 1, `y') if (country=="`ctry'" & psutest==`psu')
			di "`ctry' `psu': "el(stratname, 1, `y')
			continue, break
			}
		}
		
	}
}

qui: sum psutest
local minimum2=r(max)
local maximum2=10
while `maximum2'<=`minimum2' {
local maximum2=`maximum2'*10
}
cap drop psu1
gen double psu1=psu0
replace psu1=strata1*`maximum2'+psutest if psutest!=.

**************
*Finalisation*
**************
drop  countryNR psutest poppsu groups npanels tester groupsit cons nrpsu region0 region1 strata0 psu0 checker nocheck


*1. Check sample designs on the basis of the re-constructed sample design variables

local vals 1
foreach x of local vals {
	svyset psu`x' [pw=DB090], strata(strata`x')

	cap mat drop svy`x'
	preserve
	foreach ctry of global countries {
		cap restore, preserve
		di "********************"
		di "`ctry'"
		di "********************"
		
		keep if country=="`ctry'"
		
		cap drop single`ctry'
		svydes if country=="`ctry'"
		local nsingle=r(N_single)
		local misstrat=r(N_mstrata)
		local mispsu=r(N_munits)
		local misobs=r(N_miss)
		local nstrats=r(N_strata)
		local npsu=r(N_units)
		local nobs=r(N)
		mat svy`x'=(nullmat(svy`x') \ `nsingle', `misstrat', `mispsu', `misobs', `nstrats', `npsu', `nobs')
		cap drop single`ctry' 
	}
	restore
	mat rownames svy`x'=${countries}
	mat colnames svy`x'=nsingle misstrat mispsu misobs nstrats npsu nobs
	mat li svy`x'
}

*Example: population shares by degree of urbanisation in Belgium

svyset hid [pw=DB090]
svy: prop DB100 if country=="BE" // if condition instead of subpop option is allowed as BE is a stratum
svyset hid [pw=DB090], strata(strata1)
svy: prop DB100 if country=="BE"
svyset psu1 [pw=DB090], strata(strata1)
svy: prop DB100 if country=="BE"


*2. Save D-file

rename country DB020
rename hid DB030

compress
save 2009d_Goedeme_surveydesign.dta, replace 
*save "C:\Analyse\Stata files\Data\silc2009\version4\2009c-4d_sdv.dta", replace



