/* 
Project: Measuring poverty in the EU: Investigating empirical validity of deprivation scales
			Part of the thesis submitted by Selçuk Bedük for a DPhil in Social Policy at University of Oxford
			Full thesis is available here: https://ora.ox.ac.uk/objects/uuid:22f61b32-32a3-4fb3-b0ce-67b1b8fe8c00 

Published paper: Bedük, S. (2018). Understanding material deprivation for 25 EU countries: risk and level perspectives, and distinctiveness of zeros. European Sociological Review, 34(2), 121-137.

Author: Selçuk Bedük 

Date of code: 4 December 2017

Purpose: Master file 
		1. Goedeme file to get survey design 
		2. Merging and some data management
		3. Constructing independent variables 
		4. Constructing deprivation indices 
		5. Running the analysis - hurdle negative binomial for 25 EU countries

Inputs: Do files 

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
		And various figures (see Zeros_D4_Countanalysis do file)
*/

///  

clear all
set more off
capture log close
cd "C:\Users\Selcuk Beduk\Desktop\DPhil_research_data\Working files"
global codedir "C:\Users\selcuk.beduk\Dropbox\Research\Code\Are zeros distinct"

run "${codedir}\Beduk2018_Zeros_D0_WeightfromGoedeme.do"
run "${codedir}\Beduk2018_Zeros_D1_Datapreparation.do"
run "${codedir}\Beduk2018_Zeros_D2_ConstructingIVs.do"
run "${codedir}\Beduk2018_Zeros_D3_ConstructingDVs.do"
run "${codedir}\Beduk2018_Zeros_D4_Countanalysis.do"
