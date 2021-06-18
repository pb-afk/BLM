**********************************
* Figure 4 Estimates [Table S12] *
**********************************

global dir1 "C:\Users\pbonetti\Dropbox (IESE)\fracking wqs analysis\Fracking to clean"

clear
set more off

cd "$dir1"

use "paired_sample.dta", clear

// In the main analyses, we use Ion Concentration V2 ["log_t_t_Value_clean2"]

* gen count of # obs. per Ion-huc8-year-month
local items 1 2 3 4
local errors ""huc8_fe""
local W 2 // use V2
foreach k of local items {
	foreach e of local errors {
		foreach w of local W {

			reghdfe log_t_t_Value_clean`w' post_ log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k', cluster(`e') absorb(group_ID_geo_WELL group_huc8_year_month)
			g sample_`k'_est`w'B3 = e(sample)
			bysort huc8_s CharacteristicName date_string_year date_string_month sample_`k'_est`w'B3: gen weights_huc8_s`k'`w'B3 = _N
			replace weights_huc8_s`k'`w'B3 = 0 if weights_huc8_s`k'`w'B3==.

		}
	}
}



* Figure 4 estimates (Table S12, Panel C)
local K 1 2 3 4
local w 2
local e ""huc8_fe""
local y log_t_t_Value_clean 
foreach k of local K {

	*** ALL
	reghdfe `y'`w' post_ log_cum_prec_3days i.T_mean_D_5_groups  [aweight=weights_huc8_s`k'`w'B3]   if group_items == `k' & StateCode=="42", cluster(`e') absorb(group_ID_geo_WELL group_huc8_year_month)
		outreg2 using TabS12_C_`k'.xls, /// * Variables you want to display
		bracket bdec (5) sdec(5) replace ///
		addtext(Sample, PA, Weather Controls, Yes, Pair FE, Yes, HUC8-Y-M FE, Yes, Est, WLS)
		
	reghdfe `y'`w' post_ log_cum_prec_3days i.T_mean_D_5_groups  [aweight=weights_huc8_s`k'`w'B3]   if group_items == `k', cluster(`e') absorb(group_ID_geo_WELL group_huc8_year_month)
		outreg2 using TabS12_C_`k'.xls, /// * Variables you want to display
		bracket bdec (5) sdec(5) append ///
		addtext(Sample, ALL, Weather Controls, Yes, Pair FE, Yes, HUC8-Y-M FE, Yes, Est, WLS)
	
}

drop sample_*

* create samples for the statistics
local K 1 2 3 4
local w 2
local e ""huc8_fe""
local y log_t_t_Value_clean 
foreach k of local K {

reghdfe `y'`w' post_ log_cum_prec_3days i.T_mean_D_5_groups  [aweight=weights_huc8_s`k'`w'B3] if group_items == `k' & StateCode=="42", cluster(`e') absorb(group_ID_geo_WELL group_huc8_year_month)
	g sample_`k'_1 = e(sample)
reghdfe `y'`w' post_ log_cum_prec_3days i.T_mean_D_5_groups  [aweight=weights_huc8_s`k'`w'B3] if group_items == `k', cluster(`e') absorb(group_ID_geo_WELL group_huc8_year_month)
	g sample_`k'_2 = e(sample)
}
//

***********************
* Inputs for Figure 4 *
***********************

keep if sample_1_2 == 1 | sample_2_2 == 1 | sample_3_2 == 1 | sample_4_2 == 1

save "t3_stats.dta", replace

/// Ion Concentrations
use "t3_stats.dta", clear

capture drop ok
bysort Ch ID_geo_feN date: g ok =1 if date ==date[_n+1]
keep if ok == .

// Table S12 A
tabstat mean_geo_Value_clean2_t99 log_t_t_Value_clean2 if CharacteristicName=="Barium", stat(count mean p25 p50 p75 sd) columns(statistics) 
tabstat mean_geo_Value_clean2_t99 log_t_t_Value_clean2 if CharacteristicName=="Bromide", stat(count mean p25 p50 p75 sd) columns(statistics) 
tabstat mean_geo_Value_clean2_t99 log_t_t_Value_clean2 if CharacteristicName=="Chloride", stat(count mean p25 p50 p75 sd) columns(statistics) 
tabstat mean_geo_Value_clean2_t99 log_t_t_Value_clean2 if CharacteristicName=="Strontium", stat(count mean p25 p50 p75 sd) columns(statistics) 

// Table S12 B
tabstat mean_geo_Value_clean2_t99 log_t_t_Value_clean2 if CharacteristicName=="Barium" & sample_1_1 == 1, stat(count mean p25 p50 p75 sd) columns(statistics) 
tabstat mean_geo_Value_clean2_t99 log_t_t_Value_clean2 if CharacteristicName=="Bromide" & sample_2_1 == 1, stat(count mean p25 p50 p75 sd) columns(statistics) 
tabstat mean_geo_Value_clean2_t99 log_t_t_Value_clean2 if CharacteristicName=="Chloride" & sample_3_1 == 1, stat(count mean p25 p50 p75 sd) columns(statistics) 
tabstat mean_geo_Value_clean2_t99 log_t_t_Value_clean2 if CharacteristicName=="Strontium" & sample_4_1 == 1, stat(count mean p25 p50 p75 sd) columns(statistics) 

/// number of wells by year [ALL]
use "t3_stats.dta", clear
bysort Ch huc10_s group_api: g ok_api10 = 1 if group_api==group_api[_n+1]
keep if ok_api10 ==.

tostring spud_date_augmented, generate(date_string_spud) force usedisplayformat
g year_spud = substr(date_string_spud, 6, 4)

bysort Ch huc10_s year_spud: g number_well = _N

tabstat number_well if CharacteristicName=="Barium", stat( mean p25 p50 p75 sd) columns(statistics) 
tabstat number_well if CharacteristicName=="Bromide", stat( mean p25 p50 p75 sd) columns(statistics) 
tabstat number_well if CharacteristicName=="Chloride", stat( mean p25 p50 p75 sd) columns(statistics) 
tabstat number_well if CharacteristicName=="Strontium", stat( mean p25 p50 p75 sd) columns(statistics) 

/// number of wells by year [PA]
use "t3_stats.dta", clear
keep if sample_1_1 == 1 | sample_2_1 == 1 | sample_3_1 == 1 | sample_4_1 == 1

bysort Ch huc10_s group_api: g ok_api10 = 1 if group_api==group_api[_n+1]
keep if ok_api10 ==.

tostring spud_date_augmented, generate(date_string_spud) force usedisplayformat
g year_spud = substr(date_string_spud, 6, 4)

bysort Ch huc10_s year_spud: g number_well = _N

tabstat number_well if CharacteristicName=="Barium" & sample_1_1 == 1, stat( mean p25 p50 p75 sd) columns(statistics) 
tabstat number_well if CharacteristicName=="Bromide" & sample_2_1 == 1, stat( mean p25 p50 p75 sd) columns(statistics) 
tabstat number_well if CharacteristicName=="Chloride" & sample_3_1 == 1, stat( mean p25 p50 p75 sd) columns(statistics) 
tabstat number_well if CharacteristicName=="Strontium" & sample_4_1 == 1, stat( mean p25 p50 p75 sd) columns(statistics) 
