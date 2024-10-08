/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2018). Understanding material deprivation for 25 EU countries: risk and level perspectives, and distinctiveness of zeros. European Sociological Review, 34(2), 121-137.

Author: Selçuk Bedük 

Date of code: 4 December 2017

Purpose: Analysis for the distinctiveness of zeroes 
		Dataset is constructed combining individual, register and household data
		Unit of analysis: adult individuals (16+) 
		Countries for the main analysis: Finland, Belgium, Ireland and Portugal 
		 1. Exploratory analysis - plotting risk factors (Y) against deprivation groups (X)
		 2. Comparison of hurdle vs logit - deprivation status  
		 3. Copmarison of hurdle vs ols - deprivation intensity

Inputs: MDspecification_EUSILC09.dta (from Zeros_D3_ConstructingDVs, EU SILC 2009; household, register and individual core modules and the deprivation module;) 

Data access conditions: The current legal framework enables access to anonymised microdata available at Eurostat only for scientific purposes (Commission Regulations (EU) 557/2013; (EC) No 1104/2006; (EC) No 1000/2007; Council Regulation 322/97), however the access is restricted to universities, research institutes, national statistical institutes, central banks inside the EU, as well as to the European Central Bank. Individuals cannot be granted direct data access.
See for an overview of data: http://ec.europa.eu/eurostat/web/microdata/overview
See for how to apply for microdata: http://ec.europa.eu/eurostat/documents/203647/203698/How_to_apply_for_microdata_access.pdf/82d98876-75e5-49f3-950a-d56cec15b896
See for data availability table: https://ec.europa.eu/eurostat/documents/203647/771732/Datasets-availability-table.pdf 

Outputs: WMpmnbmols_fit.csv
		WMhpmhnb_fit.csv
		WMallfit.csv
		GUIOallfit.csv
		socclassgradient_riskofdeprivation.csv	
		classgradient_riskdep.csv
		WMallcoun.csv
		WEIGHTEDallmodels.csv
		GUIO16ALLMODELS.csv
		And various figures (see below)
*/


// 

clear all 
set more off 
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"
use MDspecification_EUSILC09.dta

drop if country1==22 | country1==15 | country1==20
replace wmt=8 if wmt==9 & country1==7
global coun 7 11 21 18 1 29 2 6 14 12 16 10 27 5 4 8 9 28 23 24 17 13 19 25 3 
global selcoun 7 14 24 13
global richcoun 7 11 21 18 1 29 2 6 14 12 16 10 
global discoun 27 5 4 8 9 28 23 24 17 13 19 25 3 
global mod1 i.esec i.isced i.divorced i.si_par i.threech i.female i.aage log_equinc i.unemployed i.hhchronicst i.hhdisabilityst i.renter
global strat i.esec i.isced i.female 
global life i.divorced i.si_par i.threech i.aage 
global mediate log_equinc i.unemployed i.healthp i.renter
svyset psu1 [pw=DB090], strata(strata1) 

****************************
svy: tab country wmt0, row 
tab country wmt0, row nofreq
histogram wmt, percent ylabel(0(6)60) xlabel(0(1)9) xtitle("Total deprivation score - Whelan and Maitre 2012") name(wmt, replace) scheme(s2mono)
histogram guio12, percent ylabel(0(6)60) xlabel(0(1)13) xtitle("Total deprivation score - Guio et al. 2016") name(guio, replace) scheme(s2mono)
graph combine wmt guio
histogram wmt, discrete by(country) percent xlabel(0(1)9)  scheme(s1mono)

recode country1 (7=1 "DK") (11=2 "FI") (21=3 "NL") (18=4 "LU") (1=5 "AT") (29=6 "UK") (2=7 "BE") (6=8 "DE") ///
	(14=9 "IE") (12=10 "FR") (16=11 "IT") (10=12 "ES") (27=13 "SI") (5=14 "CZ") (4=15 "CY") (8=16 "EE") (9=17 "EL") ///
	(28=18 "SK") (23=19 "PL") (24=20 "PT") (17=21 "LT") (13=22 "HU") (19=23 "LV") (25=24 "RO") (3=25 "BG"), into(scon) label(hicoun)

histogram wmt, discrete by(scon) percent xlabel(0(1)9)  scheme(s1mono)	
	
// DESCRIPTIVE ANALYSIS 
gen lcl= (esec==4 | esec==5)
gen ucl= (esec==1)
replace ucl=. if esec==. 
replace lcl=. if esec==. 

label variable lcl "Labor" 
label variable ucl "Salariat" 


foreach ab in $coun{
	ciplot equinc if country1==`ab', recast(connect) by(wmt) ylabel(5000(5000)30000, angle(45) labsize(small)) note("") legend(rows(1)) scheme(s1mono) name(inc`ab', replace)
	ciplot lcl ucl if country1==`ab', recast(connect) by(wmt) ylabel(0(0.2)1) note("") symbol(circle plus) legend(rows(1) ring(0) position(1) symxsize(*.4) keygap(*.2) size(small) forcesize) scheme(s1mono) name(esec`ab', replace)
	ciplot h_educ if country1==`ab', recast(connect) by(wmt) ylabel(1.4(0.4)3.8) note("") legend(rows(1)) scheme(s1mono)  name(educ`ab', replace)
	ciplot female if country1==`ab', recast(connect) by(wmt) ylabel(0.2(0.2)0.8) note("") legend(rows(1)) scheme(s1mono) name(female`ab', replace)
	ciplot unemployed if country1==`ab', recast(connect) by(wmt) ylabel(0(0.2)0.6) note("") legend(rows(1)) scheme(s1mono) name(une`ab', replace)
	ciplot si_par if country1==`ab', recast(connect) by(wmt) ylabel(0(0.1)0.4) note("") legend(rows(1)) scheme(s1mono) name(sp`ab', replace)
	ciplot hhbad_health if country1==`ab', recast(connect) by(wmt) ylabel(0.3(0.2)0.9) note("") legend(rows(1)) scheme(s1mono) name(he`ab', replace)
	ciplot renter if country1==`ab', recast(connect) by(wmt) ylabel(0(0.2)1) note("") legend(rows(1)) scheme(s1mono) name(rent`ab', replace)
	graph combine inc`ab' esec`ab' educ`ab' female`ab' une`ab' sp`ab' he`ab' rent`ab', title(`ab') scheme(s1mono) cols(4) name(ciplot`ab', replace)
}

foreach ab in $escoun{
	ciplot equinc if country1==`ab', recast(connect) by(wmt) ylabel(5000(5000)30000, angle(45) labsize(small)) note("") legend(rows(1)) scheme(s1mono) name(inc`ab', replace)
	ciplot lcl ucl if country1==`ab', recast(connect) by(wmt) ylabel(0(0.2)1) note("") symbol(circle plus) legend(rows(1) ring(0) position(1) symxsize(*.4) keygap(*.2) size(small) forcesize) scheme(s1mono) name(esec`ab', replace)
	ciplot h_educ if country1==`ab', recast(connect) by(wmt) ylabel(1.4(0.4)3.8) note("") legend(rows(1)) scheme(s1mono)  name(educ`ab', replace)
	ciplot female if country1==`ab', recast(connect) by(wmt) ylabel(0.2(0.2)0.8) note("") legend(rows(1)) scheme(s1mono) name(female`ab', replace)
	ciplot unemployed if country1==`ab', recast(connect) by(wmt) ylabel(0(0.2)0.6) note("") legend(rows(1)) scheme(s1mono) name(une`ab', replace)
	ciplot si_par if country1==`ab', recast(connect) by(wmt) ylabel(0(0.1)0.4) note("") legend(rows(1)) scheme(s1mono) name(sp`ab', replace)
	ciplot hhbad_health if country1==`ab', recast(connect) by(wmt) ylabel(0.3(0.2)0.9) note("") legend(rows(1)) scheme(s1mono) name(he`ab', replace)
	ciplot renter if country1==`ab', recast(connect) by(wmt) ylabel(0(0.2)1) note("") legend(rows(1)) scheme(s1mono) name(rent`ab', replace)
	graph combine inc`ab' esec`ab' educ`ab' female`ab' une`ab' sp`ab' he`ab' rent`ab', title(`ab') scheme(s1mono) cols(4) name(ciplot`ab', replace)
}

foreach ab in $coun {
	ciplot equinc if country1==`ab', recast(connect) by(wmt) yaxis(1,2) ylabel(0(15000)30000, axis(1)) title(`ab') ytitle("") xtitle(, size(small)) note("") legend(rows(1)) scheme(s1mono) ///
	yline(`=c_median' `=thresh60', axis(2)) ylabel(`=c_median' "Median" `=thresh60' "60%Med", angle(horizontal) labsize(vsmall) axis(2)) name(inc`ab', replace)
		}
graph combine inc7 inc11 inc21 inc18 inc1 inc29 inc2 inc6 inc14 inc12 inc16 inc10 inc27 inc5 inc4 inc8 inc9 inc28 inc23 inc24 inc17 inc13 inc19 inc25 inc3 

foreach ab in $richcoun {
	ciplot equinc if country1==`ab', recast(connect) by(wmt) yaxis(1,2) ylabel(5000(15000)35000, axis(1)) title(`ab') ytitle("") xtitle(, size(small)) note("") legend(rows(1)) scheme(s1mono) ///
	yline(`=c_median' `=thresh60', axis(2)) ylabel(`=c_median' "Median" `=thresh60' "60%Med", angle(horizontal) labsize(vsmall) axis(2)) name(inc`ab', replace)
		}
graph combine inc7 inc11 inc21 inc18 inc1 inc29 inc2 inc6 inc14 inc12 inc16 inc10   
	
foreach ab in $discoun {
	ciplot equinc if country1==`ab', recast(connect) by(wmt) yaxis(1,2) ylabel(0(10000)20000, axis(1)) title(`ab') ytitle("") xtitle(, size(small)) note("") legend(rows(1)) scheme(s1mono) ///
	yline(`=c_median' `=thresh60', axis(2)) ylabel(`=c_median' "Median" `=thresh60' "60%Med", angle(horizontal) labsize(vsmall) axis(2)) name(inc`ab', replace)
		}
graph combine inc27 inc5 inc4 inc8 inc9 inc28 inc23 inc24 inc17 inc13 inc19 inc25 inc3, holes(12) 

graph combine inc7 inc21 inc29 inc6 inc14 inc12 inc16 inc10 inc5 inc9 inc23 inc24 inc13 inc3

tabstat c_median thresh60, by(scon) 

foreach u in $coun {
	nbreg wmt $mod1 if country1==`u'
	}


// AIC/BIC 

global coun 7 11 21 18 1 29 2 6 14 12 16 10 27 5 8 9 28 23 24 17 13 19 25 3 


// Whelan and Maitre (2012)
eststo clear 
foreach ab in $coun {
	poisson wmt $mod1 if country1==`ab'
	eststo poisson`ab': fitstat
	estadd fitstat 
	nbreg wmt $mod1 if country1==`ab'
	eststo nbreg`ab': fitstat
	estadd fitstat 
	tpoisson wmt $mod1 if country1==`ab' & wmt>0
	eststo tpoisson`ab': fitstat
	estadd fitstat 
	tnbreg wmt $mod1 if country1==`ab' & wmt>0
	eststo tnbreg`ab': fitstat
	estadd fitstat 
	logit wmt $mod1 if country1==`ab'
	eststo log`ab': fitstat
	estadd fitstat
	reg wmt $mod1 if country1==`ab'
	eststo ols`ab': fitstat
	estadd fitstat 
} 
esttab using WMpmnbmols_fit.csv, cells(none) plain stats(aic bic) replace 

eststo clear 
foreach ab in $coun {
	xi: hplogit wmt $mod1 if country1==`ab'
	eststo hp`ab': abich
	estadd fitstat
	xi: hnblogit wmt $mod1 if country1==`ab'
	eststo hnb`ab': abich
	estadd fitstat
} 
esttab using WMhpmhnb_fit.csv, cells(none) plain stats(aic bic) replace 


// Weighted index 
eststo clear 
foreach ab in $coun {
	poisson wawmt $mod1 if country1==`ab'
	eststo poisson`ab': fitstat
	estadd fitstat 
	nbreg wawmt $mod1 if country1==`ab'
	eststo nbreg`ab': fitstat
	estadd fitstat 
	logistic wawmt $mod1 if country1==`ab'
	eststo logistic`ab': fitstat
	estadd fitstat 
	tpoisson wawmt $mod1 if country1==`ab' & wawmt>0
	eststo tpoisson`ab': fitstat
	estadd fitstat
	tnbreg wawmt $mod1 if country1==`ab' & wawmt>0
	eststo tnbreg`ab': fitstat
	estadd fitstat
	reg wawmt $mod1 if country1==`ab'
	eststo ols`ab': fitstat
	estadd fitstat 
} 
esttab using WWMallfit.csv, cells(none) plain stats(aic bic) replace 


// Guio et al. 2016
eststo clear 
foreach ab in $coun {
	poisson guio12 $mod1 if country1==`ab'
	eststo poisson`ab': fitstat
	estadd fitstat 
	nbreg guio12 $mod1 if country1==`ab'
	eststo nbreg`ab': fitstat
	estadd fitstat 
	logistic guio12 $mod1 if country1==`ab'
	eststo logistic`ab': fitstat
	estadd fitstat 
	tpoisson guio12 $mod1 if country1==`ab' & guio12>0
	eststo tpoisson`ab': fitstat
	estadd fitstat
	tnbreg guio12 $mod1 if country1==`ab' & guio12>0
	eststo tnbreg`ab': fitstat
	estadd fitstat
	reg guio12 $mod1 if country1==`ab' 
	eststo ols`ab': fitstat
	estadd fitstat
} 
esttab using GUIOallfit.csv, cells(none) plain stats(aic bic) replace 
// Cyprus and Romania are separately run using Hilbe's commands - hplogit/hnblogit



// SOCIAL CLASS GRADIENT 

// LEVEL OF DEPRIVATION 

eststo clear 
foreach c in $selcoun {
	eststo: reg wmt i.esec if country1==`c' & missing==0
	tnbreg wmt i.esec if country1==`c' & wmt>0 & missing==0
	eststo: margins if country1==`c' & missing==0 , dydx(*) noesample post 
	eststo: reg wmt $strat if country1==`c' & missing==0
	tnbreg wmt $strat if country1==`c' & wmt>0 & missing==0
	eststo: margins if country1==`c' & missing==0, dydx(*) noesample post
	eststo: reg wmt $strat $life $mediate if country1==`c' & missing==0
	tnbreg wmt $strat $life $mediate if country1==`c' & wmt>0 & missing==0
	eststo: margins if country1==`c' & missing==0, dydx(*) noesample post
	}

esttab using socclassgradient_riskofdeprivation.csv, replace cells(b(star fmt(3)) se(par fmt(2))) ///
legend label varlabels(_cons constant)               ///
refcat(1.esec "Social Class - ESEC 5" 1.educ "Education", nolabel) ///
stats(r2 N, fmt(3 0 1) label(R-sqr N))


// RISK OF DEPRIVATION 
eststo clear 
foreach c in $selcoun {
	logit wmt2 i.esec if country1==`c' & missing==0
	eststo: margins if country1== `c' & missing==0 , dydx(*) post 
	logit wmt i.esec if country1==`c' & missing==0
	eststo: margins if country1== `c' & missing==0 , dydx(*) post 
	logit wmt2 $strat $life if country1==`c' & missing==0
	eststo: margins if country1== `c' & missing==0 , dydx(*) post 
	logit wmt $strat $life if country1==`c' & missing==0
	eststo: margins if country1== `c' & missing==0 , dydx(*) post
	logit wmt2 $strat $life $mediate if country1==`c' & missing==0
	eststo: margins if country1== `c' & missing==0 , dydx(*) post 
	logit wmt $strat $life $mediate if country1==`c' & missing==0
	eststo: margins if country1== `c' & missing==0 , dydx(*) post
}	

esttab using classgradient_riskdep.csv, replace cells(b(star fmt(3)) se(par fmt(2))) ///
legend label varlabels(_cons constant)               ///
refcat(1.esec "Social Class - ESEC 5" 1.educ "Education", nolabel) ///
stats(r2 N, fmt(3 0 1) label(R-sqr N))

 
// FIGURES 

// SOCIAL CLASS GRADIENT ON RISK 
foreach c in $selcoun {
	logit wmt i.esec if country1==`c' & missing==0
	eststo a`c'log: margins if country1==`c', at(esec=(1(1)6)) post
	logit wmt2 i.esec if country1==`c' & missing==0
	eststo a`c'log2: margins if country1==`c', at(esec=(1(1)6)) post
	coefplot a`c'log a`c'log2, vertical recast(connected) ciopts(recast(rcap)) title(`c') ///
		xlabel(`=1' "Salariat" `=2' "Mixed" `=3' "Self" `=4' "LaborI" `=5' "LaborII" `=6' "Excluded") ///
		ylabel(0(0.2)1) scheme(s1mono) nooffsets name(x`c'log1, replace)
	local xlog "`xlog' x`c'log1" 
}
grc1leg `xlog',  cols(2)
 
foreach c in 11 21 18 1 29 2 6 12 16 10 27 5 4 8 9 28 23 17 19 25 3 {
	logit wmt i.esec if country1==`c' & missing==0
	eststo a`c'log: margins if country1==`c', at(esec=(1(1)6)) post
	logit wmt2 i.esec if country1==`c' & missing==0
	eststo a`c'log2: margins if country1==`c', at(esec=(1(1)6)) post
	coefplot a`c'log a`c'log2, vertical recast(connected) ciopts(recast(rcap)) title(`c') ///
		xlabel(`=1' "Salariat" `=2' "Mixed" `=3' "Self" `=4' "LaborI" `=5' "LaborII" `=6' "Excluded", labsize(small)) ///
		ylabel(0(0.2)1, grid) scheme(s1mono) nooffsets name(x`c'log1, replace)
	local xlog "`xlog' x`c'log1" 
}
grc1leg `xlog', cols(5) holes(4 5 15 25)


// LEVEL 

foreach c in $selcoun {
 	tnbreg wmt i.esec if country1==`c' & missing==0 & wmt>0
	eststo a`c'hnb: margins if country1==`c', at(esec=(1(1)6)) noesample post
	reg wmt i.esec if country1==`c' & missing==0
	eststo a`c'reg: margins if country1==`c', at(esec=(1(1)6)) post
	coefplot a`c'hnb a`c'reg, vertical recast(connected) ciopts(recast(rcap)) title(`c') ///
		xlabel(`=1' "Salariat" `=2' "Mixed" `=3' "Self" `=4' "LaborI" `=5' "LaborII" `=6' "Excluded", labsize(small)) ///
		ylabel(0(1)4, grid) scheme(s1mono) nooffsets name(x`c'reg1, replace)
		local xlog "`xlog' x`c'reg1" 
}
grc1leg `xlog', cols(2)

foreach c in 11 21 18 1 29 2 6 12 16 10 27 5 4 8 9 28 23 17 19 25 3  {
 	tnbreg wmt i.esec if country1==`c' & missing==0 & wmt>0
	eststo a`c'hnb: margins if country1==`c', at(esec=(1(1)6)) noesample post
	reg wmt i.esec if country1==`c' & missing==0
	eststo a`c'reg: margins if country1==`c', at(esec=(1(1)6)) post
	coefplot a`c'hnb a`c'reg, vertical recast(connected) ciopts(recast(rcap)) title(`c') ///
		xlabel(`=1' "Salariat" `=2' "Mixed" `=3' "Self" `=4' "LaborI" `=5' "LaborII" `=6' "Excluded", labsize(small)) ///
		ylabel(0(1)4, grid) scheme(s1mono) nooffsets name(x`c'reg1, replace)
		local xlog "`xlog' x`c'reg1" 
}
grc1leg `xlog', cols(5) holes(4 5 15 25)

      
//// Comparing models - WHELAN AND MAITRE 2012
/*
// design weighted - susceptible to problems of selection in truncated models
eststo clear
foreach ab in $coun {
	svy: logistic wmt2 $mod1 if country1==`ab'
	eststo logit`ab': margins if country1==`ab', dydx(*) post 
	svy: logistic wmt $mod1 if country1==`ab'
	eststo HUbinary`ab': margins if country1==`ab', dydx(*) post 
	svy: tnbreg wmt $mod1 if country1==`ab' & wmt>0
	eststo HUcount`ab': margins if country1==`ab', dydx(*) noesample post 
	eststo OLS`ab': svy: reg wmt $mod1 if country1==`ab'
}
esttab using WMallmod.csv, replace cells(b(star fmt(3)) se(par fmt(2))) ///
   legend label varlabels(_cons constant)               ///
   refcat(1.esec "Social Class - ESEC 5" 1.educ "Education", nolabel) ///
   stats(r2 N, fmt(3 0 1) label(R-sqr N))   
*/
   
// Comparing models - WM index 

eststo clear
foreach ab in $coun {
	logistic wmt $mod1 if country1==`ab'
	eststo HUbinary`ab': margins if country1==`ab', dydx(*) post 
	tnbreg wmt $mod1 if country1==`ab' & wmt>0
	eststo HUcount`ab': margins if country1==`ab', dydx(*) noesample post 
	logistic wmt2 $mod1 if country1==`ab'
	eststo logit`ab': margins if country1==`ab', dydx(*) post 
	eststo OLS`ab': reg wmt $mod1 if country1==`ab'
}

foreach ab in 25 3 4 {
	logistic wmt $mod1 if country1==`ab'
	eststo HUbinary`ab': margins if country1==`ab', dydx(*) post 
	tpoisson wmt $mod1 if country1==`ab' & wmt>0
	eststo HUcount`ab': margins if country1==`ab', dydx(*) noesample post 
	logistic wmt2 $mod1 if country1==`ab'
	eststo logit`ab': margins if country1==`ab', dydx(*) post 
	eststo OLS`ab': reg wmt $mod1 if country1==`ab'
}

esttab using WMallcoun.csv, replace cells(b(star fmt(2)) se(par fmt(2))) ///
   legend label varlabels(_cons constant)               ///
   refcat(1.esec "Social Class - ESEC 5" 1.educ "Education", nolabel) ///
   stats(r2 N, fmt(3 0 1) label(R-sqr N))   

  
   
//// Comparing models - Weighted WM index  
eststo clear
foreach ab in $coun {
	logistic wawmt2 $mod1 if country1==`ab'
	eststo logit`ab': margins if country1==`ab', dydx(*) post 
	logistic wawmt $mod1 if country1==`ab'
	eststo HUlogit`ab': margins if country1==`ab', dydx(*) post 
	tnbreg wawmt $mod1 if country1==`ab' & wawmt>0
	eststo HUOLS`ab': margins if country1==`ab', dydx(*) noesample post 
	eststo OLS`ab': reg wawmt $mod1 if country1==`ab'
}
esttab using WEIGHTEDallmodels.csv, replace cells(b(star fmt(3)) se(par fmt(2))) ///
   legend label varlabels(_cons constant)               ///
   refcat(1.esec "Social Class - ESEC 5" 1.educ "Education", nolabel) ///
   stats(r2 N, fmt(3 0 1) label(R-sqr N))   



//// Comparing models - 13 item index of GUIO et al. 2016  
eststo clear  
foreach ab in $coun {
	logistic guio125 $mod1 if country1==`ab'
	eststo logit`ab': margins if country1==`ab', dydx(*) post 
	logistic guio12 $mod1 if country1==`ab'
	eststo HUlogit`ab': margins if country1==`ab', dydx(*) post 
	tnbreg guio12 $mod1 if country1==`ab' & guio12>0
	eststo HUOLS`ab': margins if country1==`ab', dydx(*) noesample post 
	eststo OLS`ab': reg guio12 $mod1 if country1==`ab'
}
esttab using GUIO16ALLMODELS.csv, replace cells(b(star fmt(3)) se(par fmt(2))) ///
   legend label varlabels(_cons constant)               ///
   refcat(1.esec "Social Class - ESEC 5" 1.educ "Education", nolabel) ///
   stats(r2 N, fmt(3 0 1) label(R-sqr N))   

   
   
   
   
/*   
gen wmtonly=[(wmt>0) & (poor60<1)] if wmt!=. & poor60!=.
  
gen wmtpr=[(wmt>2) & (poor60>0)] if wmt!=. & poor60!=.
eststo clear 
logit wmtpr $mod1 if country1==2
eststo: margins if country1==2, dydx(*) post
logistic wmtonly $mod1 if country1==2 
eststo: margins if country1==2, dydx(*) post
logistic wmt $mod1 if country1==2 
eststo: margins if country1==2, dydx(*) post
 
esttab, cells(b(star fmt(3)) se(par fmt(2))) ///
   legend label varlabels(_cons constant)               ///
   refcat(log_equinc "LogHHeq.income" 1.esec "Social Class - ESEC 5" 1.educ "Education" 1.aage "Age group", nolabel) ///
   stats(r2 N, fmt(3 0 1) label(R-sqr N))      
  
eststo clear 
logit wmtpr $mod1 if country1==10
eststo: margins if country1==10, dydx(*) post
logistic wmt $mod1 if country1==10 
eststo: margins if country1==10, dydx(*) post 
esttab, cells(b(star fmt(3)) se(par fmt(2))) ///
   legend label varlabels(_cons constant)               ///
   refcat(log_equinc "LogHHeq.income" 1.esec "Social Class - ESEC 5" 1.educ "Education" 1.aage "Age group", nolabel) ///
   stats(r2 N, fmt(3 0 1) label(R-sqr N))      
      
  
eststo clear 
logit wmtpr $mod1 if country1==14
eststo: margins if country1==14, dydx(*) post
logistic wmt $mod1 if country1==14 
eststo: margins if country1==14, dydx(*) post 
esttab, cells(b(star fmt(3)) se(par fmt(2))) ///
   legend label varlabels(_cons constant)               ///
   refcat(log_equinc "LogHHeq.income" 1.esec "Social Class - ESEC 5" 1.educ "Education" 1.aage "Age group", nolabel) ///
   stats(r2 N, fmt(3 0 1) label(R-sqr N))      
  */    	  
		  
		  
