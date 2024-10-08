/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2018). Understanding material deprivation for 25 EU countries: risk and level perspectives, and distinctiveness of zeros. European Sociological Review, 34(2), 121-137.

Author: Selçuk Bedük 

Date of code: 4 December 2017

Purpose:  Constructing household level independent variables 

Inputs: SILC09_R_P_H_WM.dta (from Zeros_D1_Datapreparation, using EU SILC 2009; household, register and individual core modules and the deprivation module;) 

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.
See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview
See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896
See for data availability table: https://ec.europa.eu/eurostat/documents/203647/771732/Datasets-availability-table.pdf 

Outputs: MDdimensions_EUSILC09.dta 
*/


clear all
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"
use SILC09_R_P_H_WM.dta

recode occupation (1 2 3 = 1) (4 5 = 2) (7 8 10 = 3) (6 = 4) (9 = 5), gen(occup)
label variable occup "Occupation" 
label define ISCO_gr 1 "Managers,prof.,tech." 2 "Service workers" 3 "Technical manual" 4 "Farmers&fishers" 5 "Elemantary workers"
label values occup ISCO_gr
tab occup, m
tab country occup, m row nofreq  // not low non-response rates in each country and Malta coded only as Army; in total 4.9% of the sample
tab country occupation

gen unemployed=0
replace unemployed=1 if ecost==3
replace unemployed=. if ecost==. 
label variable unemployed "Unemployed"
tab unemployed, m

drop jobless
recode RX050 (2=0), gen(jobless)
label variable jobless "Low work intensity" 

gen si_par=0
replace si_par=1 if HX060==9
replace si_par=. if HX060==. 
label variable si_par "Single parent household" 
tab si_par, m

recode h_educ (4 5 6 = 1) (3 = 2) (2 1 0 = 3), gen(educ)
label variable educ "Highest education level" 
label define isced1 1 "Third level" 2 "Upper 2ndary" 3 "Low2nd/Primary/Pre", replace
label values educ isced1
tab educ, m
tab country educ

recode h_educ (0 1 2=3) (3 4=2) (5=1) , gen(isced)
replace isced=3 if PE040_F==-2
label define isced 3 "Low2nd/Primary/Pre" 2 "Upper secondary" 1 "Tertiary"
label values isced isced 

gen single=0
replace single=1 if hhtype==1
replace single=. if HX060==. 
label variable single "Single adult" 
tab single, m
tab country single [aw=RB050], m row nofreq
tab single aage [aw=RB050], cell nofreq

gen threech=0
replace threech=1 if n_child>2
replace threech=. if n_child==.
label variable threech "3+children"
tab threech, m

recode marstat (3 5 = 1) (1 2 4 = 0), gen(divorced)
label variable divorced "Divorced/separated"
tab divorced, m

gen younghh=(aage==1)
label variable younghh " HRP Young(<31)"
gen oldhh=(aage==5)
label variable oldhh "HRP Old(80+)"
gen eldhh=(aage>=4)
label variable eldhh "HRP Old(65+)" 

recode tenure (2 3 = 1) (1 4 = 0), gen(renter)
label variable renter "Tenant" 
tab renter, m


// Household responsible person from the accommodation HRP

tab HB080_F HB090_F
replace HB080=HB090 if HB080_F==-1 & HB090_F==1

gen HRP=0
replace HRP=1 if HB080==pid
replace HRP=. if HB080_F==-1 & (HB090_F==-1 | HB090_F==-2)


// Using the information from household members to replace missings of HRP adult deprivation items 

bysort country hid: egen tshoes=sum(MDshoes), m
replace MDshoes=1 if tshoes>0 & HRP==1 & RB245==3
replace MDshoes=0 if tshoes==0 & HRP==1 & RB245==3

bysort country hid: egen tcloth=sum(MDcloth), m
replace MDcloth=1 if tcloth>0 & HRP==1 & RB245==3
replace MDcloth=0 if tcloth==0 & HRP==1 & RB245==3

bysort country hid: egen tgout=sum(MDg_out), m
replace MDg_out=1 if tgout>0 & HRP==1 & RB245==3
replace MDg_out=0 if tgout==0 & HRP==1 & RB245==3

bysort country hid: egen tleisure=sum(MDleisure), m
replace MDleisure=1 if tleisure>0 & HRP==1 & RB245==3
replace MDleisure=0 if tleisure==0 & HRP==1 & RB245==3

bysort country hid: egen tsmoney=sum(MDsmoney), m
replace MDsmoney=1 if tsmoney>0 & HRP==1 & RB245==3
replace MDsmoney=0 if tsmoney==0 & HRP==1 & RB245==3

bysort country hid: egen trefur=sum(MDrefurnish), m
replace MDrefurnish=1 if trefur>0 & HRP==1 & RB245==3
replace MDrefurnish=0 if trefur==0 & HRP==1 & RB245==3


gen MDbtw=.
replace MDbtw=1 if bath==1 | toilet==1 | water==1 
replace MDbtw=0 if bath==0 & toilet==0 & water==0 


// Arranging items

gen overcrowd=.
replace overcrowd=0 if nrooms>=HX040
replace overcrowd=1 if nrooms<HX040
label variable overcrowd "Overcrowded house" 

recode HS170 (2 = 0), gen(noise)
label variable noise "Noise from street/neighbors"

recode HS180 (2 = 0), gen(pollution)
label variable pollution "Pollution, grime problems" 

gen env=.
replace env=1 if noise==1 | pollution==1
replace env=0 if noise==0 & pollution==0

label variable mortgage "Arrears on mortgage/rent"
label variable utility "Arrears on utility payments"

gen meet=.
replace meet=1 if endsmeet==1 | endsmeet==2 
replace meet=0 if endsmeet==4 | endsmeet==5 | endsmeet==6 | endsmeet==3

recode HS150 (1 = 1) (2 3=0), into(debtburden)
replace debtburden=0 if HS150_F==-2
label variable debtburden "Heavy burden of debt"

gen burhc=.
replace burhc=1 if HS140==1 
replace burhc=0 if HS140==2 | HS140==3 | HS140_F==-2
label variable burhc "Heavy burden of housing cost" 

gen burdebt=.
replace burdebt=1 if HS150==1  
replace burdebt=0 if HS150==2 |HS150==3 | HS150_F==-2
label variable burdebt "Heavy burden of debt" 



// Creating ESEC from ISCO 88 

gen empst=. 
replace empst=1 if PL040==1 & firmsize>10
replace empst=2 if PL040==1 & firmsize<11
replace empst=3 if PL040==2
replace empst=4 if PL040==3 & PL150==1
replace empst=5 if PL040==3 & PL150==2 

label define em 1 "Employer-large" 2 "Employer-small" 3 "Self-employed-noemp" 4 "Supervisors" 5 "Other employees" 
label values empst em

recode PL050 (1/7 11 12 21/24 31 32 = 1) (8/10 33 34 41 = 2) (13 61 = 3) (42 51 52 = 4) (71 72 73 74 81/83 91/93 = 5), into(esec) 

replace esec=1 if empst==1

foreach x in 12 13 33 40 41 42 51 52 71 72 73 74 81 82 83 91 92 93 {
	replace esec=3 if PL050==`x' & (empst==2 | empst==3)
}

foreach y in 11 12 13 21 22 23 24 31 32 33 34 41 {
	replace esec=1 if empst==4 & PL050==`y' 
}

foreach z in 42 51 52 61 71 72 73 74 81 82 83 91 92 93 { 
	replace esec=2 if empst==4 & PL050==`z'
} 
replace esec=6 if PL015==2 & esec==.
replace esec=6 if esec==. & (eco_status>9 | eco_st==8)

/*
replace esec=6 if PL015==2 & esec==. 
replace esec=6 if esec==. & ecost>5
*/

tab esec

label variable esec "Social Class ESEC 5"
label define es 1 "Salariat" 2 "Inter. employee" 3 "Small self-emp." 4 "Lowe white collar" 5 "Manual" 6 "Never worked", replace 
label values esec es 
		
// Just keeping the HRPs without missing information on dependent variables				

drop if HRP==0 

drop if country1==22 | country1==15    // Norway and Iceland is not from Europe 

/*
keep if country1==1 | country1==2 | country1==6 | country1==7 | (country1>8 & country1<13) | country1==14 | country1==16 ///
				| country1==18 | country1==21 | country1==24 | country1==26 | country1==29
*/

misstable summarize MDcloth MDshoes MDmeat MDwarm MDbtw MDg_out MDsmoney MDleisure MDholiday MDPC MDcar MDTV MDtel MDwas MDrefurnish 
gen wmtm=MDholiday+MDmeat+MDwarm+MDrefurnish+MDcloth+MDshoes+MDg_out+MDleisure+MDsmoney
misstable summarize wmtm MDholiday MDmeat MDwarm MDrefurnish MDcloth MDshoes MDg_out MDleisure MDsmoney esec isced equinc female unemployed si_par divorced hhchronicst hhdisabilityst threech renter
tabstat wmtm MDholiday MDmeat MDwarm MDrefurnish MDcloth MDshoes MDg_out MDleisure MDsmoney esec isced equinc female unemployed si_par divorced hhchronicst hhdisabilityst threech renter, stats(mean sd min max) columns(stat)

// Checking country missings
tab country wmtm , row nofreq m
tab country esec , row nofreq m
tab country isced , row nofreq m
tab country medinc [aw=RB050], row nofreq m
tab country hhchronicst [aw=RB050], row nofreq m

misstable pattern MDholiday MDmeat MDwarm MDrefurnish MDcloth MDshoes MDg_out MDleisure MDsmoney
misstable pattern MDholiday MDmeat MDwarm MDrefurnish MDcloth MDshoes MDg_out MDleisure MDsmoney if country1==26
misstable pattern MDholiday MDmeat MDwarm MDrefurnish MDcloth MDshoes MDg_out MDleisure MDsmoney if country1==29 // In both Sweeden and the UK, the missings are related to new module variables

// Dealing with missings
gen edmiss=missing(educ)

gen mis_cases=0
replace mis_cases=1 if MDcloth==. | MDshoes==. | MDmeat==. | MDwarm==. | MDg_out==. | MDsmoney==. ///
	| MDleisure==. | MDholiday==. | MDrefurnish==.
	
gen missing=(esec==. | isced==. | female==. | si_par==. | divorced==. | threech==. | aage==. | log_equinc==. | unemployed==. | hhchronicst==. | hhdisabilityst==. | renter==.)

// Missings in education - Portugal, UK, Spain	
tab wmtm edmiss [aw=RB050] if country1==24, col nofreq m
tab esec edmiss [aw=RB050] if country1==24, col nofreq m
tab medinc edmiss [aw=RB050] if country1==24, col nofreq m 

tab wmtm edmiss [aw=RB050] if country1==29, col nofreq m
tab esec edmiss [aw=RB050] if country1==29, col nofreq m
tab medinc edmiss [aw=RB050] if country1==29, col nofreq m 

tab wmtm edmiss [aw=RB050] if country1==10, col nofreq m
tab esec edmiss [aw=RB050] if country1==10, col nofreq m
tab medinc edmiss [aw=RB050] if country1==10, col nofreq m 

keep if mis_cases==0
drop if country1==26	// Sweeden has problems in some deprivation items - 35%
drop if country1==20	// Malta has problems with the occupation variable - everyone is in Army

egen wmt=rowtotal(MDholiday MDmeat MDwarm MDrefurnish MDcloth MDshoes MDg_out MDleisure MDsmoney)

// healthp
gen healthp=(hhdisabilityst==1 | hhchronicst==1)
replace healthp=. if hhdisabilityst==. | hhchronicst==.
bysort country hid: egen hbad_health=sum(healthp), m 
gen hhbad_health=(hbad_health>0) if hbad_health!=. 

save MDdimensions_EUSILC09.dta, replace 



  
