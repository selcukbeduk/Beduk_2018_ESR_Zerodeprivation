/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2018). Understanding material deprivation for 25 EU countries: risk and level perspectives, and distinctiveness of zeros. European Sociological Review, 34(2), 121-137.

Author: Selçuk Bedük 

Date of code: 4 December 2017

Purpose: Constructing data and relevant variables 

Inputs: EU SILC 2009; household, register and individual core modules and the deprivation module;
		2009d_Goedeme_surveydesign.dta, created in previous do file Zeros_D0_WeightfromGoedeme

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.
See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview
See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896
See for data availability table: https://ec.europa.eu/eurostat/documents/203647/771732/Datasets-availability-table.pdf 

Outputs: SILC09_R_P_H_WM.dta 
*/



clear all
set more off
capture log close
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"


* Taking variables (e.g. hid) from Register file  

use RB010 RB020 RB030 RX030 RB050 RB080 RB090 RB220_F RB230_F RB240_F RB245 RB250 RX* using "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\EUSILC09_personal_register"
rename RB010 year
rename RB020 country 

* Keeping only EU27 countries 

encode country, gen(country1)
label variable RB080 "Year of birth"
rename RX020 age
replace age=year-RB080-1 if age==. 

label variable RX040 "Work intensity" 
label variable RX050 "Low work intensity" 
label variable RX060 "Severely materially deprived household" 
label variable RX070 "At risk of poverty or social exclusion" 

gen ageg=. 
replace ageg=1 if age>=0 & age<15
replace ageg=2 if age>14 & age<25
replace ageg=3 if age>24 & age<45
replace ageg=4 if age>44 & age<65
replace ageg=5 if age>64 & age<80
replace ageg=6 if age>=80
label define ag 1 "0-14" 2 "15-24" 3 "25-44" 4 "45-64" 5 "65-80" 6 "80+", replace 
label values ageg ag
tab ageg, m

gen agegg=.
replace agegg=1 if age>14 & age<25
replace agegg=2 if age>24 & age<35
replace agegg=3 if age>34 & age<45
replace agegg=4 if age>44 & age<55
replace agegg=5 if age>54 & age<65
replace agegg=6 if age>64
label define aee 1 "15-24" 2 "25-34" 3 "35-44" 4 "45-54" 5 "55-64" 6 "65+", replace 
label values agegg aee
label variable agegg "Age group 6"
tab agegg, m

gen agegr=. 
replace agegr=1 if age<31
replace agegr=2 if age>30 & age<65
replace agegr=3 if age>64
label variable agegr "Age group 3" 
label define agea 1 "<31" 2 "30-64" 3 "65+"
label values agegr agea 

gen aage=. 
replace aage=1 if age<31
replace aage=2 if age>30 & age<45
replace aage=3 if age>44 & age<65
replace aage=4 if age>64
replace aage=5 if age>79 
label define ae 1 "15-30" 2 "31-45" 3 "45-64" 4 "65-79" 5 "80+", replace 
label values aage ae
label variable aage "Age group"
tab aage, m


gen age2=age*age

labe variable RB090 "Gender" 
recode RB090 (2=1) (1=0), gen(female) 
rename RB030 pid
rename RX030 hid
label variable RB245 "Respondent status" 

bysort country hid: egen hhsize=count(pid) // creating household size 
gen old=0
replace old=1 if age>64
bysort country hid: egen old_H=sum(old), m 

gen child=0
replace child=1 if age<16
bysort country hid: egen n_child=sum(child), m

* OPTIONAL keep if RB245<4 	// Keeping respondents that are eligible and have contacted 
* OPTIONAL keep if RB250==11 | RB250== 12 | RB250==13 | RB250==14		// Keeping respondents that have complete information from a type of interview 

sort year country pid
save SILC09_R.dta, replace 





* Merging Register with Personal file (selected md items)
clear 
use PB020 PB030 PB140 PB190 PD010-PD070_F PE040 PE040_F PH010-PH070 PL015 PL015_F PL020-PL025_F PL031 PL031_F PL040 PL040_F PL050 PL050_F PX* ///
	PL060 PL060_F PL073-PL076_F PL080 PL080_F PL085-PL090_F PL100 PL110 PL100_F PL110_F PL120 PL120_F PL130 PL130_F PL140 PL140_F PL150 PL150_F PL160-PL200_F using "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\EUSILC09_personal"
	
describe 
rename PL031 eco_status 
label define ecost 1 "ES Full-time" 2 "ES Part-time" 3 "ES Self-employed FT" 4 "ES Self-employed PT" 5 "ES Unemployed" ///
	6 "ES Student/trainee" 7 "ES Retired" 8 "ES Disabled" 9 "ES Compulsory service" 10 "ES Domestic unpaid work" 11 "ES Other inactive"
label values eco_status ecost

recode PD010 (2=1) (1 3=0), into(mobtel)
label variable mobtel "Mobile phone"


label variable PX050 "Activity status"
label define act 1 "EMP/TOT > 0.5" 2 "UNP/TOT > 0.5" 3 "RET/TOT > 0.5" 4 "OIN/TOT > 0.5"
label values PX050 act 

label variable PX040 "Respondent status"
label define resp 1 "cur HH member 16+" 2 "selected resp 16+" 3 "non-selected resp 16+"
label values PX040 resp

label variable PX030 "Household ID" 
label variable PX010 "Currency exchange rate" 

 
rename PX020 age
rename PB020 country 
encode country, gen(country1)
rename PB030 pid
sort country pid

save SILC09_P.dta ,replace 


use SILC09_R.dta
merge 1:1 country pid using SILC09_P.dta
tab _merge
save SILC09_R_P.dta, replace




* Recoding module items

recode PD020 PD030 PD050 PD060 PD070 (1 3 = 0) (2 = 1), pre(n_) test

rename n_PD020 MDcloth
label variable MDcloth "Replace worn-out clothes by some new ones"

rename n_PD030 MDshoes
label variable MDshoes "Having two pairs of shoes"

rename n_PD050 MDg_out
label variable MDg_out "Meeting with friends/relatives at least twice a month"

rename n_PD060 MDleisure
label variable MDleisure "Participating ordinary leisure activities"

rename n_PD070 MDsmoney
label variable MDsmoney "Having little spare money every week"

 




*** Constructing individual and household unmet health need due to inadequate resources indicators 

// missing 

tab PH040_F PH050_F
tab country PH040_F, row
tab country PH050_F, row

/* For PH050, there are almost no missings, but for PH040, UK(12%), PL(8%), CZ(15%) 
have significant amount of missing values */


* Creating an indicator of chronic health conditions in the household 

// Missings 

tab country PH010_F, row 
tab country PH020_F, row 
tab country PH030_F, row 

/* For subjective health indicator, CZ (15%), EE(23%), LT(15%), PL(8%) have missings
For the chronic health and disability indicators CZ (15%) and PL (8%) have missings */


*** HEALTH
rename PH010 health
recode health (1 2 3 = 0) (4 5 = 1), gen(i_healthst) test
label variable i_healthst "IN-Subj. Health Status"

bysort country hid: egen hhealth=sum(i_healthst), m  
gen hhhealthst= (hhealth>0) if hhealth!=.  // HH health status


*** CHRONIC HEALTH CONDITIONS 
recode PH020 (2 8 = 0), gen(i_chronic)
label variable i_chronic "IN-Chronic Health Condition" 

bysort country hid: egen hchronic=sum(i_chronic), m
gen hhchronicst= (hchronic>0) if hchronic!=.    // HH chronic status


*** DISABILITY 
recode PH030 (1 2 = 1) (3 8 = 0), gen(i_disability)
label variable i_disability "IN-Disability" 

bysort country hid: egen hdisability=sum(i_disability), m
gen hhdisabilityst= (hdisability>0) if hdisability!=.   // HH disability 

sort year country hid pid
save SILC09_R_P.dta, replace



* Merging with the Household File  - Assigning individual deprivation variables to household

clear 
use HB010 HB020 HB030 HB070 HB080-HB090_F HD010 HD010_F HD020 HD020_F HD025 HD025_F HS010-HS190 HS190_F HH010-HH030_F HH040-HH050_F HH070-HH080_F HH081 HH081_F HH090-HH091_F ///
	HD030 HD030_F HD040 HD040_F HD050 HD050_F HD060 HD060_F HD070 HD070_F HD080-HD090_F HY020 HY070G HY070G_F HY070G_I HY070N HY070N_F HY070N_I HX* using "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\EUSILC09_household"
describe
rename HB010 year
rename HB020 country 

encode country, gen(country1)
rename HB030 hid 
rename HB070 pid 
rename HH010 dw_type
rename HH020 tenure
rename HH030 nrooms
rename HH040 lroof
rename HH070 tothcost
rename HY070G h_allow
rename HH080 bathx
rename HH081 bathy
rename HH090 toiletx
rename HH091 toilety

recode HD050 (1 2 = 1) (3 4=0), gen (MDdamaged)

rename HS160 dark 
sort year country hid pid

* Data management for the Household file

* Binary deprivation items

recode HD010 HD030 HH050 HS040-HS060 (2 = 1) (1 = 0), pre(n_) test
recode HD080 HD090 HS070-HS110 (2 = 1) (1 3 = 0), pre(n_) test

rename n_HS060 MDun_exp
rename n_HS040 MDholiday
rename n_HS050 MDmeat
rename n_HH050 MDwarm
rename n_HS100 MDwash
rename n_HS080 MDTV
rename n_HS070 MDtel
rename n_HS110 MDcar
rename n_HS090 MDPC
rename n_HD080 MDrefurnish
rename n_HD090 MDnet
rename n_HD030 MDshortspace

recode HS190 (2=0), gen(MDcrime)
label variable MDcrime "Crime in neighbourhood"


gen MDpc_net=. 
replace MDpc_net=0 if MDPC==0 | MDnet==0
replace MDpc_net=1 if MDPC==1 & MDnet==1


rename HS120 endsmeet 
label variable endsmeet "Subj. Income inadequacy"

rename n_HD010 water
label variable water "Having running hot water at home" 

gen debt=.
replace debt=1 if HS150_F==1
replace debt=0 if HS150_F==-2
label variable debt "Having debt - credit/loan"

// Creating arrears 

gen mortgage=. 
replace mortgage=0 if HS010==2 | HS010_F==-2 | HS011==3 | HS011_F==-2
replace mortgage=1 if HS010==1 | HS011==1 | HS011==2

gen utility=.
replace utility=0 if HS020==2 | HS020_F==-2 | HS021==3 | HS021_F==-2
replace utility=1 if HS020==1 | HS021==1 | HS021==2
replace utility=0 if HS020_F==-1 & country1==29

gen installment=. 
replace installment=0 if HS030==2 | HS030_F==-2 | HS031==3 | HS031_F==-2
replace installment=1 if HS030==1 | HS031==1 | HS031==2
replace installment=0 if HS030_F==-1 & country1==29


gen MDarrears=.
replace MDarrears=0 if mortgage==0 & utility==0 & installment==0 
replace MDarrears=1 if mortgage==1 | utility==1 | installment==1


sort country hid
save SILC09_H.dta, replace 


* Taking degree of urbanisation from household register file 
use "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\EUSILC09_household_register"
rename DB020 country
rename DB030 hid 
sort country hid 
save SILC09_HR.dta, replace 

use SILC09_H.dta 
merge 1:1 country hid using SILC09_HR
keep if _merge==3 
drop _merge 
save SILC09_H.dta, replace 


* Merging all 

use SILC09_R_P.dta 
drop _merge
merge m:1 year country hid using SILC09_H.dta
keep if _merge==3
drop _merge
save SILC09_R_P_H.dta, replace 

* Adding the design variables from Goedeme
clear all
use 2009d_Goedeme_surveydesign.dta
sort country hid 
save 2009d_Goedeme_surveydesign.dta, replace 

clear all
use SILC09_R_P_H.dta
merge m:1 country hid using 2009d_Goedeme_surveydesign 
keep if _merge==3
drop _merge
save SILC09_R_P_H.dta, replace 



*** INCOME 
 
rename HY020 h_income
inspect h_income

gen eq_scale=sqrt(hhsize) // OECD equivalence scale - square root 

label variable eq_scale "OECD square root equivalence scale"

gen equinc=h_income/eq_scale

label variable equinc "Equivalized income"


* Labeling 

label variable HX090 "Equivalized Disposable HH Income"
label variable HX080 "Relative income poverty status"
label variable HX040 "Household size"
label variable HX050 "Equivalized household size" 
label variable HX070 "Tenure status"
label variable HX120 "Overcrowded household" 
label variable HX010 "Change rate" 
label variable old_H "HH # of 65+ members" 
label variable health "Subjective health" 
label variable equinc "HH disposable income - equivalized" 





/* Housing deprivation indicators 

- Tenure status = HH020 tenure 

- Housing quality - overcrowding rate and housing deprivation 
	
	Severe housing deprivation rate is defined as the percentage of population living in the dwelling 
	which is considered as overcrowded, while also exhibiting at least one of the housing deprivation measures.

	Housing deprivation is a measure of poor amenities and is calculated by referring to those households with a leaking roof, 
	no bath/shower, no indoor toilet, or a dwelling considered too dark.
	
	leaking roof = HH040 lroof
	bath/shower	 = HH080/81 bathx bathy
	toilet		 = HH090/91 toiletx toilety
	dark		 = HS160 dark
	
- Housing affordability 

	The housing cost overburden rate is the percentage of the population living in households where 
	the total housing costs ('net' of housing allowances) represent more than 40 % of disposable income ('net' of housing allowances).

	
*/ 


	
// Housing cost overburden rate ///

gen msc=0 
replace msc=1 if tothcost==. | h_allow==. | h_income==. 
gen hcobr=. 
label variable hcobr "Housing cost overburden rate" 
replace hcobr=1 if (tothcost*12-h_allow)>(h_income-h_allow)*0.4  & msc!=1
replace hcobr=0 if (tothcost*12-h_allow)<=(h_income-h_allow)*0.4 & msc!=1

tab country hcobr [aw=RB050], row nofreq 




/// Creating housing overcrowding rate ///

gen hover=.
label variable hover "Housing overcrowding rate" 

* nrooms --> number of rooms available to the household 

* The number of rooms needed for the household 
gen a=1
bysort country hid: egen rh=sum(a) // room for the household
replace rh=rh/hhsize

gen coup=0 
replace coup=1 if RB240_F==1  // one room for couples
bysort country hid: egen tcoup=sum(coup)
replace tcoup=tcoup*0.5

gen adu=0
replace adu=1 if RB240_F!=1 & age>=18 
bysort country hid: egen tadu=sum(adu)


gen ychi=0
replace ychi=1 if age<12 // one room for two young children 
bysort country hid: egen tychi=sum(ychi)
recode tychi(2 3 =1) (4 5 = 2) (6 7 = 3) (8 9=4) (11=5), into(txychi)

gen fih=0
replace fih=1 if age>11 & age<18 & female==1
bysort country hid: egen HHnf=sum(fih) 
recode HHnf (2=1) (3 4 = 2) (7=4), into(frooms)

gen mih=0
replace mih=1 if age>11 & age<18 & female==0
bysort country hid: egen HHnm=sum(mih) 
recode HHnm (2=1) (3 4 = 2), into(mrooms) 

gen tnroom=tcoup+tadu+txychi+frooms+mrooms+rh

replace hover=0 if tnroom<=nrooms
replace hover=1 if tnroom>nrooms

tab hover, m
tab country hover [aw=RB050], row nofreq 
label variable hover "Housing overcrowding rate" 



/// Severe housing deprivation rate ///

/*	leaking roof = HH040 lroof
	bath/shower	 = HH080/81 bathx bathy
	toilet		 = HH090/91 toiletx toilety
	dark		 = HS160 dark
*/

recode lroof (2=0), into(roof)
label variable roof "Leaking roof, damp walls/floors/foundation, rot in the window frames or floor"

gen bath=.
replace bath=0 if bathx==1 | bathy==1 | bathy==2 
replace bath=1 if bathx==2 | bathy==3
replace bath=. if HH080_F==-1 | HH081_F==-1 

gen toilet=. 
replace toilet=0 if toiletx==1 | toilety==1 | toilety==2
replace toilet=1 if toiletx==2 | toilety==3
replace toilet=. if HH090_F==-1 | HH091_F==-1 

recode dark (2=0), into(tdark)
label variable tdark "too dark, not enough light"

gen SHDR=.
replace SHDR=0 if roof==0 & bath==0 & toilet==0 & tdark==0
replace SHDR=1 if hover==1 & (roof==1 | bath==1 | toilet==1 | tdark==1)
replace SHDR=0 if hover==0

tab SHDR, m
tab country SHDR [aw=RB050], row nofreq
label variable SHDR "Severe Housing Deprivation rate"


sum hcobr hover SHDR




sort country hid

save SILC09_R_P_H.dta, replace 

merge 1:1 country hid pid using EU2020_PSE_ind_ImPRovE.dta
tab _merge
drop _merge

gen log_equinc=log(hystd) if !missing(hystd)

egen inctile=xtile(hystd), by(country) nq(10)
egen decile=xtile(h_income), by(country) nq(10)

_pctile hystd [aw=RB050] if country1==29, p(50, 60)
return list 


// Creating key variables
 
label variable log_equinc "Log_Equiv.HHIncome" 
label variable poor120 "120% of Median HH Income"
label variable poor60 "Inc.Poverty(60%med)"
label variable endsmeet "Subj.Inc.Inadequacy"
label variable i_disability "Disability"
label variable i_chronic "Chronic Health Problem"
label variable female "Female"  

gen htype=HX060
label variable htype "Household type"
label variable HX060 "Household type"


rename PB190 marstat
label variable marstat "Marital status"

rename PE040 h_educ
label variable h_educ "Highest ISCED level" 
label define ISCED 0 "pre-primary" 1 "primary" 2 "lower secondary" 3 "secondary" 4 "post_sec. non-tertiary" 5 "first tertiary" 6 "sec. tertiary" 
label values h_educ ISCED 


recode eco_st (3=1) (4=2) (5=3) (6=4) (7=5) (8=6) (9=1) (10=7) (11=8), into(ecost)
label variable ecost "Economic status - 8"
label define ecosta 1 "ES Full-time" 2 "ES Part-time" 3 "ES Unemployed" 4 "ES Student/trainee" 5 "ES Retired" ///
	6 "ES Disabled" 7 "ES Domestic unpaid work" 8 "ES Other inactive", replace 
label values ecost ecosta 

gen ISCO=PL050
recode PL050 (1/10=10) (11/13=1) (21/24=2) (31/34=3) (41 42=4) (51 52= 5) (61=6) (71/74=7) (81/83=8) (91/93=9), into(occupation)
label define occ 1 "Managers, senior officials, legislators" 2 "Professionals" 3 "Technicians/ass.profs" 4 "Clerks" 5 "Service workers" ///
	6 "Skilled agr. and fishery workers" 7 "Craft trade workers" 8 "Plant/Machine operators" 9 "Elementary occupations" 10 "Army", replace 
label values occupation occ	
label variable occupation "ISCO-88(COM)"

gen slf=PL040
recode slf (2=1), into(slfemp)

recode PL130 (15=11) (14=10), into(firmsize)


label define htyp 5 "Single person" 6 "2adults_<65 no child" 7 "2adults_65+ no child" 8 "Others no child" 9 "Single parent" ///
	10 "2 adults 1 child" 11 "2 adults 2 child" 12 "2 adults 3+ child" 13 "Extended family" 16 "Other", replace
label values htype htyp

recode htype (5=1) (6/7=2) (8=3) (9=4) (10/12=5) (13=6) (16=7), into(hhtype)
label variable hhtype "Household type"
label define htp 1 "Single person" 2 "2 adults no child" 3 "Others no child" 4 "Single parent" 5 "2 adults with children" ///
	6 "Extended family" 7 "Other"
label values hhtype htp 

label define mar 1 "Never married" 2 "Married" 3 "Separated" 4 "Widowed" 5 "Divorced"
label values marstat mar 

recode hhsize (5/20=5), into(h_size) 
label define hs 1 "1" 2 "2" 3 "3" 4 "4" 5 "5+"
label values h_size hs 
label variable h_size "Household size" 

rename DB100 urban
label variable urban "Degree of urbanisation"
label define urb 1 "UR-densely populated" 2 "UR-intermediate" 3 "UR-thinly populated" 
label values urban urb

label define ten 1 "TN-owner" 2 "TN-marketprice renter" 3 "TN-reducedprice renter" 4 "TN-Free" 
label values tenure ten 

label define hei 1 "Very good" 2 "Good" 3 "Fair" 4 "Bad" 5 "Very bad" 
label values health hei


save SILC09_R_P_H_WM.dta, replace 










