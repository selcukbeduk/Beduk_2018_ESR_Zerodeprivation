/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2018). Understanding material deprivation for 25 EU countries: risk and level perspectives, and distinctiveness of zeros. European Sociological Review, 34(2), 121-137.

Author: Selçuk Bedük 

Date of code: 4 December 2017

Purpose:  Creating dependent variables i.e., material deprivation indices by Whelan and Maitre 2012; Kenworthy, 2011; Nelson, 2013

Inputs: MDdimensions_EUSILC09.dta (from Zeros_D2_ConstructingIVs, using EU SILC 2009; household, register and individual core modules and the deprivation module;) 

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.
See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview
See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896
See for data availability table: https://ec.europa.eu/eurostat/documents/203647/771732/Datasets-availability-table.pdf 

Outputs: MDspecification_EUSILC09.dta 
*/

clear all
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"
use MDdimensions_EUSILC09.dta 


// WEIGHTING // 
///////////////
// Weighting with the prevalence rate in each country 
 
	gen wMDcloth=.
	gen wMDshoes=.
	gen wMDmeat=.
	gen wMDwarm=. 
	gen wMDbtw=.
	gen wMDg_out=.
	gen wMDsmoney=.
	gen wMDleisure=.
	gen wMDholiday=.
	gen wMDPC=. 
	gen wMDcar=. 
	gen wMDTV=.
	gen wMDtel=.
	gen wMDwash=. 
	gen wMDrefurnish=.
	gen wMDarrears=.
	gen wMDun_exp=. 
	gen wmeet=.
	gen wburhc=.
	gen wburdebt=.
	gen wovercrowd=. 
	gen wenv=. 
	gen wutility=.
	gen wmortgage=.
	
	gen twMDcloth=.
	gen twMDshoes=.
	gen twMDmeat=.
	gen twMDwarm=. 
	gen twMDbtw=.
	gen twMDg_out=.
	gen twMDsmoney=.
	gen twMDleisure=.
	gen twMDholiday=.
	gen twMDPC=. 
	gen twMDcar=. 
	gen twMDTV=.
	gen twMDtel=.
	gen twMDwash=. 
	gen twMDrefurnish=.
	gen twMDarrears=.
	gen twMDun_exp=. 
	gen twmeet=.
	gen twburhc=.
	gen twburdebt=.
	gen twovercrowd=. 
	gen twenv=. 
	gen twutility=.
	gen twmortgage=.
	
levelsof country1, local(levels)
foreach c of local levels {
	foreach X of varlist MDcloth MDshoes MDmeat MDwarm MDbtw MDg_out MDsmoney MDleisure MDholiday MDPC MDcar MDTV ///
						MDtel MDwash MDrefurnish MDarrears MDun_exp meet burhc burdebt overcrowd env utility mortgage {
							sum `X' [aw=RB050] if country1==`c', detail
							replace w`X'=1-(r(mean)) if country1==`c' 
							replace tw`X'=(`X')*(w`X') if country1==`c'
						}
}


// Calculating 9-item index of Whelan and Maitre 

gen wmtdep=. 
egen wmtot= rowtotal(twMDholiday twMDmeat twMDwarm twMDrefurnish twMDcloth twMDshoes twMDg_out twMDleisure twMDsmoney) 
levelsof country1, local(levels)
foreach c of local levels {
	sum wmtot if country1==`c' [aw=RB050], detail
	replace wmtdep= [wmtot - r(min)] / [r(max)-r(min)] if country1==`c'
	}
	label variable wmtdep "Whelan/Maitre"

gen wmt0= (wmt>0)
gen wmt1= (wmt>1)
gen wmt2= (wmt>2)
gen wmt3= (wmt>3) 


gen wawmt=round(wmtdep, .01) * 100
gen wawmt2= (wawmt>40)

	

// Calculating Kenworthy 
gen kentdep=.
egen kenttot=rowtotal(twMDwarm twMDmeat twovercrowd twenv twutility twmortgage twmeet)
levelsof country1, local(levels)
foreach c of local levels {
	sum kenttot if country1==`c' [aw=RB050], detail
	replace kentdep= [kenttot - r(min)] / [r(max)-r(min)] if country1==`c'
	}
label variable kentdep "Kenworthy" 



// Calculating Guio (2009) for Nelson (2013)
gen guio9dep=.
egen guio9tot= rowtotal(twMDarrears twMDholiday twMDmeat twMDun_exp twMDtel twMDTV twMDwash twMDcar twMDwarm ) if mis_cases!=1
levelsof country1, local(levels)
foreach c of local levels {
	sum guio9tot if country1==`c' [aw=RB050], detail
	replace guio9dep= [guio9tot - r(min)] / [r(max)-r(min)] if country1==`c'
	}
label variable guio9dep "Nelson" 

gen guio9= MDarrears+MDholiday+MDmeat+MDun_exp+MDtel+MDTV+MDwash+MDcar+MDwarm
gen guio12= MDarrears+MDholiday+MDmeat+MDun_exp+MDcar+MDwarm+MDrefurnish+MDpc_net+MDcloth+MDshoes+MDg_out+MDleisure+MDsmoney
gen guio125= (guio12>4)
replace guio12=10 if guio12>10
label variable wmt "Deprivation score"
label variable wawmt "Prevalence-weighted depscore"


// TYPES of enforced deprivation?

alpha MDcloth MDshoes MDmeat MDwarm MDbtw 
alpha MDg_out MDsmoney MDleisure MDholiday
alpha MDPC MDcar MDTV MDtel MDwash MDrefurnish
alpha MDarrears MDun_exp meet burhc burdebt


//////
egen totbn=rowtotal(MDcloth MDshoes MDmeat MDwarm MDbtw)
egen totbn1=rowtotal(MDcloth MDshoes MDmeat MDwarm MDbtw )
egen totsa=rowtotal(MDg_out MDsmoney MDleisure MDholiday)
egen totdur=rowtotal(MDPC MDcar MDTV MDtel MDwash MDrefurnish)
egen totfs=rowtotal(MDarrears MDun_exp meet burhc burdebt)

egen totst=rowtotal(MDcloth MDshoes MDmeat MDwarm MDg_out MDsmoney MDleisure)
egen totlt=rowtotal(MDcar MDrefurnish MDbtw MDholiday MDwash MDPC)


sum totbn [aw=RB050], detail 
gen bna = [totbn - r(min)] / [r(max)-r(min)]
sum totsa [aw=RB050], detail 
gen saa = [totsa - r(min)] / [r(max)-r(min)]
sum totdur [aw=RB050], detail 
gen dura = [totdur - r(min)] / [r(max)-r(min)]
sum totfs [aw=RB050], detail 
gen fsa = [totfs - r(min)] / [r(max)-r(min)]

//////

egen totbnw=rowtotal(twMDcloth twMDshoes twMDmeat twMDbtw twMDwarm)
sum totbnw [aw=RB050], detail
gen bn = [totbnw - r(min)] / [r(max)-r(min)]

egen totbn1w=rowtotal(twMDcloth twMDshoes twMDmeat twMDbtw twMDwarm )
sum totbn1w [aw=RB050], detail
gen bn1 = [totbn1w - r(min)] / [r(max)-r(min)]

egen totsaw=rowtotal(twMDg_out twMDsmoney twMDleisure twMDholiday)
sum totsaw [aw=RB050], detail
gen sa = [totsaw - r(min)] / [r(max)-r(min)]

egen totdurw=rowtotal(twMDPC twMDcar twMDTV twMDtel twMDwash twMDrefurnish)
sum totdurw [aw=RB050], detail
gen dur = [totdurw - r(min)] / [r(max)-r(min)]

egen totfsw= rowtotal(twMDarrears twMDun_exp twmeet twburhc twburdebt)
sum totfsw [aw=RB050], detail
gen fs = [totfsw - r(min)] / [r(max)-r(min)]

gen robn=round(bn, .001) * 1000
gen robn1=round(bn1, .001) * 1000
gen rosa=round(sa, .001) * 1000
gen rodur=round(dur, .001) * 1000
gen rofs=round(fs, .001) * 1000


sum wmtdep kentdep guio9dep robn robn1 rosa rodur rofs
corr wmtdep kentdep guio9dep robn robn1 rosa rodur rofs


gen bnst=0
replace bnst=1 if totbn>0
replace bnst=. if totbn==. 

gen sast=0
replace sast=1 if totsa>0 
replace sast=. if totsa==. 

gen durst=0 
replace durst=1 if totdur>0 
replace durst=. if totdur==. 

gen fsst=0
replace fsst=1 if totfs>0
replace fsst=. if totfs==. 

label variable bnst "Basic Needs Status"
label variable sast "Social Activities Status"
label variable durst "Durables Status"
label variable fsst "Financial Strain Status"

gen bnsa=0
replace bnsa=1 if bnst==1 & sast==1



save MDspecification_EUSILC09.dta, replace 
