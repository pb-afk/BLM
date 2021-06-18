clear
set more off
cd "$dir1"


*********************
* 4. FINAL ASSEMBLY *
*********************

**************************
* 4.1. APPEND WELL FILES *
**************************

*********
* PADEP *
*********

use "huc10_PADEP_ALL.dta", clear

// some cleaning
capture drop state_county_ID year year_fe month_year group_huc10 huc8_s group_huc8 group_month_year ///
datadate_s m_datadate datadate_spud_s well_status
 
g PADEP = 1

// keep only unconventional wells based on the PADEP variable
keep if unconventional=="Yes"

// renaming spud date variable
rename m_datadate_spud m_datadate_spud_PADEP

// rename lat and long variables
rename latitude lat_pa
rename longitude long_pa

save "huc10_PADEP_ALL_to_merge.dta", replace

******
* DI *
******

use "0.1.1 DI data/huc10_DI_H.dta", clear

// some cleaning
capture drop m_datadate_prod_date m_datadate_prod_date_s m_datadate_completion ///
 m_datadate_completion_s m_first_date_s m_last_date m_last_date_s ///
 group_month_year state_api month_year year state_county_ID m_datadate_spud_s ///
 group_huc10 huc8_s group_huc8

g DI = 1

save "0.1.1 DI data/huc10_DI_ALL.dta", replace

******
* WD *
******

use "WellDatabase/huc10_WD_H.dta", clear

// some cleaning
capture drop year year_fe month_year group_huc10 huc8_s group_huc8 group_month_year ///
 state_county_ID WD_testdate_int WD_plugdate_int WD_firstproddate_int WD_completiondate_int WD_permitdate_int WD_testdate ///
 WD_api WD_wellid WD_wellname WD_currentoperator WD_originaloperator WD_field WD_county WD_state  WD_permitdate WD_spuddate WD_completiondate WD_firstproddate WD_plugdate WD_permitnumber ///
 WD_reportedcurrentoperator WD_reportedoriginaloperator ///
 WD_reportedwellboreprofile WD_spuddate_int_s
capture drop _merge

g WD = 1

save "WellDatabase/huc10_WD_ALL.dta", replace

*******************************
* 4.2. merge PADEP, WD AND DI *
*******************************

// Import the three well datasets
use "WellDatabase/huc10_WD_ALL.dta", clear
merge 1:1 api10 using "0.1.1 DI data/huc10_DI_ALL.dta", gen(_merge_WD_DI) update
merge 1:1 api10 using "huc10_PADEP_ALL_to_merge.dta", gen(_merge_PADEP) update

// Keep only unconv wells from PA and H and Horizontal from DI and WD. I.e., at least one data provider marks a well as either horizontal or H
g DrillType_to_use = "H" if unconventional == "Yes"
replace DrillType_to_use = "H" if (DrillType=="H" | WD_wellboreprofile=="HORIZONTAL")
keep if DrillType_to_use=="H"

**** from row #89 to 120 is relevant only for the "super clean" robustness check analysis

// compute differences [in days] between spud dates recorded for each well among the three datasets
g difPA_WD = m_datadate_spud_PADEP - m_WD_spuddate_int_bis
g difPA_DI = m_datadate_spud_PADEP - m_datadate_spud_bis
g difWD_DI = m_WD_spuddate_int_bis - m_datadate_spud_bis

// set the maximum difference [in days] to be within ABS[15 days]
local w 15
g difPA_WD_D = 1 if difPA_WD>=-`w' & difPA_WD<=`w' & difPA_WD!=.
g difPA_DI_D = 1 if difPA_DI>=-`w' & difPA_DI<=`w' & difPA_DI!=.
g difWD_DI_D = 1 if difWD_DI>=-`w' & difWD_DI<=`w' & difWD_DI!=.
replace difPA_WD_D= 0 if difPA_WD_D==.
replace difPA_DI_D= 0 if difPA_DI_D==.
replace difWD_DI_D= 0 if difWD_DI_D==.

	*1.	If the three agree [PADEP, WD, DI], generate the "super clean" version of spud date (which sets all other obs. for which we do not have the three agreeing obs. to missing - For states other than PA, use only WD and DI)
	g spud_date_super_clean = m_datadate_spud_PADEP if difPA_WD_D == 1 & difPA_DI_D == 1 & difWD_DI_D==1 & state_api=="37"
	replace spud_date_super_clean = m_WD_spuddate_int_bis if difWD_DI_D == 1 & spud_date_super_clean==. & state_api!="37" & m_WD_spuddate_int_bis!=. & m_datadate_spud_bis!=.
	format spud_date_super_clean %d

	*2.	"Augment" further for PA (which requires two out of three dates to agree)
	g spud_date_augmented_clean = spud_date_super_clean
	replace spud_date_augmented_clean = m_datadate_spud_PADEP if spud_date_augmented_clean==. & m_WD_spuddate_int_bis!=. & m_datadate_spud_PADEP!=. & difPA_WD_D == 1 & state_api=="37" 
	replace spud_date_augmented_clean = m_datadate_spud_PADEP if spud_date_augmented_clean==. & m_datadate_spud_bis!=. & m_datadate_spud_PADEP!=. & difPA_DI_D == 1 & state_api=="37" 
	replace spud_date_augmented_clean = m_WD_spuddate_int_bis if spud_date_augmented_clean==. & m_WD_spuddate_int_bis!=. & m_datadate_spud_bis!=. & difWD_DI_D == 1 & state_api=="37"
	format spud_date_augmented_clean %d

	*3.	Final "augmenting", which sets the dates as follows: First PADEP, then WD, finally DI
	g spud_date_augmented = spud_date_augmented_clean
	replace spud_date_augmented = m_datadate_spud_PADEP if spud_date_augmented==. & m_datadate_spud_PADEP!=. & state_api=="37"
	replace spud_date_augmented = m_WD_spuddate_int_bis if spud_date_augmented==. & m_WD_spuddate_int_bis!=. & state_api!="37"
	replace spud_date_augmented = m_datadate_spud_bis if spud_date_augmented ==. & m_datadate_spud_bis!=. & state_api!="37"
	format spud_date_augmented %d
	
// drop non-relevant spud dates 
drop if spud_date_augmented==.
drop if spud_date_augmented<d(01jan2004) & spud_date_augmented!=.
drop if spud_date_augmented>d(01jan2017) & spud_date_augmented!=.

// drop non-production wells
drop if ProductionType=="DISPOSAL" | ///
		ProductionType=="INJECTION" | ///
		ProductionType=="INJECTOR" | ///
		ProductionType=="GOR CALC" | ///
		ProductionType=="STORAGE"

drop if WD_welltype=="DISPOSAL" | ///
		WD_welltype=="Disposal Well" | ///
		WD_welltype=="GAS STORAGE" | ///
		WD_welltype=="INJECTION" | ///
		WD_welltype=="STORAGE" | ///
		WD_welltype=="STORAGE WELL" | ///
		WD_welltype=="Water Supply" | ///
		WD_welltype=="WATER INJECTION" | ///
		WD_welltype=="Salt Water Prod" | ///
		WD_welltype=="SOURCE" | ///
		WD_welltype=="Coal Bed Methane Service Well" | ///
		WD_welltype=="LI" | ///
		WD_welltype=="LW" | ///
		WD_welltype=="Monitor" | ///
		WD_welltype=="OBSERVATION" | ///
		WD_welltype=="TEST" | ///
		WD_welltype=="WATER" 

// some cleaning
capture drop _merge* unconventional configuration DrillType states WD_wellboreprofile  

/// import shales and limit the sample of wells in huc10s on shales
merge m:1 huc10 using "shales_EPA_huc10_link.dta", gen(_merge_shale)
keep if _merge_shale==3
drop _merge_shale

compress
save "huc10_temp_NOV 2019_ALL_bis.dta", replace


//

*************************************************
* 4.3. Generate Cumulative well counts by HUC10 *
*************************************************

use "huc10_temp_NOV 2019_ALL_bis.dta", clear
drop if spud_date_augmented ==.

// # newly spudded wells by HUC10-day
bysort huc10 DrillType_to_use spud_date_augmented: g tot_well_c_d = _N
bysort huc10 DrillType_to_use spud_date_augmented: g ok = 1 if spud_date_augmented==spud_date_augmented[_n+1]
keep if ok ==.

// data cleaning the data to the huc10-day level
rename tot_well_c_d tot_well_c_dH
drop DrillType_to_use
order huc10 huc10_s spud_date_augmented 
rename spud_date_augmented date

save "wells_huc10_NOV 2019_spud_date_augmented_ALL.dta", replace

// import a daily TS without gaps from 01jan2004 to 31dec2016]
clear
import excel "county_for cum count.xls", sheet("county_for cum count") firstrow // TS w/o gaps
g huc10_s="0901000201"

// check no dates are missing
drop if date==.

// merge with # newly spudded wells by HUC10-day
merge m:1 huc10_s date using "wells_huc10_NOV 2019_spud_date_augmented_ALL.dta"
rename _merge _merge_w_true_obs

fillin huc10_s date
drop if date>d(01jan2017)
replace tot_well_c_dH = 0 if tot_well_c_dH==.

// create cumulative number of wells
sort huc10_s date
by huc10_s: g cum_well_H = sum(tot_well_c_dH)

keep huc10_s date huc10 areaacres areasqkm cum_well_H

g huc8_s = substr(huc10_s,1,8)
g huc4_s = substr(huc10_s,1,4)

save "_T_spud_date_augmented_ALL_bis.dta", replace




//

***********************************************************
* 4.4. Assembly HF wells data with the water quality data *
***********************************************************

use "WQS_DAILY__id_geo_cleaned.dta", clear

/// Import Shale Information
merge m:1 huc10 using "shales_EPA_huc10_link.dta", gen(_merge_shale)
drop if _merge_shale==2

// drop Groundwater data sources
drop if MonitoringLocationTypeName=="Groundwater"

// import cumulative well variables
merge m:1 huc10_s date using "_T_spud_date_augmented_ALL_bis.dta", gen(_merge_cum_well_count)
replace cum_well_H = 0 if cum_well_H==.
drop if _merge_cum_well_count == 2
	
// identifying HUC10s with HF wells over the sample period
bysort MonitoringLocationTypeName CharacteristicName huc10_s: egen m_cum_well_huc10_H = max(cum_well_H)

// identifying HUC4s with HF wells over the sample period and keep only those
bysort MonitoringLocationTypeName CharacteristicName huc4_s: egen m_cum_well_huc4_H = max(m_cum_well_huc10_H)
g m_cum_well_huc4_H_D = 1 if m_cum_well_huc4_H>0 & m_cum_well_huc4_H!=.
replace m_cum_well_huc4_H_D = 0 if  m_cum_well_huc4_H_D ==.	
keep if m_cum_well_huc4_H_D==1

// create alternative version of the cumulative well count variable
merge m:1 huc10_s using "huc10_size.dta", gen(_merge_size)
keep if _merge_size == 3
g cum_well_H_s = cum_well_H / areasqkm_monitoring
drop _merge_size

save "id_geo_estimation_sample_T_spud_date_augmented_ALL_bis_ALL.dta", replace

***********************************************************
* 4.5 Create well count variables for Figure 3 (Table S8) *
*********************************************************** 

local A ""id_geo_estimation_sample_T_spud_date_augmented_ALL""
local B _bis

foreach a of local A {
foreach b of local B {

local ONLY_ONE_TYPE "H" 

// use clean well data 
clear
use "huc10_temp_NOV 2019_ALL`b'.dta", clear
keep api10 huc10 huc10_s spud_date_augmented DrillType_to_use
rename DrillType_to_use DrillType
keep if DrillType == "`ONLY_ONE_TYPE'"
drop if spud_date_augmented==.

// merging in Table S4 sample and water data - note that time-specific well counts depend only relative timing of spud and monitoring date (not on water data being available)
joinby huc10_s using "FA_bulding_`a'`b'.dta", _merge(MERGE) 
drop MERGE

***************************** Time-based Well Counts *************************

local ONLY_ONE_TYPE "H" 
rename spud_date_augmented spud_date

// create dummy variable depending on the # of days between monitoring date and well spud date
local LAST_NUMBER = 0
foreach CURRENT_NUMBER in 0 90 180 360 1000000 {
  gen within_`ONLY_ONE_TYPE'_`LAST_NUMBER'_`CURRENT_NUMBER' = ///
  (date >= spud_date +`LAST_NUMBER') & (date <= spud_date + `CURRENT_NUMBER' )
  local LAST_NUMBER = `CURRENT_NUMBER' + 1
}

/* For example, within_H_0_90 is a dummy variable that takes the value of 1 if the
 respective well was spudded in the last 90 days relative to the Char-monitoring-date,
 and 0 otherwise. Via collapse in line 311 this variable will be aggregated on the Char-monitoring-date level*/

 local LAST_NUMBER = 1

 foreach CURRENT_NUMBER in 0 90 180 360 1000000 {

  gen future_`ONLY_ONE_TYPE'_`LAST_NUMBER'_`CURRENT_NUMBER' = ///
  (spud_date >= date +`LAST_NUMBER') & (spud_date <= date + `CURRENT_NUMBER' ) 
  local LAST_NUMBER = `CURRENT_NUMBER' + 1

}

****************** checking time-based well counts are properly assigned ************************
egen ROWTOTAL = rowtotal(within* future_*)
tab ROWTOTAL  // rowtotal should be equal to 1 so that time-based dummies are mutually exclusive
drop ROWTOTAL

************** Collapse to Char-monitor-dataset *******************

//gcollapse install see: https://github.com/mcaceresb/stata-gtools
gcollapse (mean) cum_well_H (sum) within* future* , by(huc10_s CharacteristicName MonitoringLocationTypeName ID_geo date)

****************** checking time-based well counts are properly computed ************************
egen cum_well_H_check = rowtotal(within*)
compare cum_well_H cum_well_H_check    // the two variables should always be equal

/* Merge with monitoring dataset to get monitoring-date obs irrespective of when 
 and whether a well was spudded back into the sample after collapse. 
 Also to get huc10-variables back that were lost in collapse step */

	merge 1:1 CharacteristicName MonitoringLocationTypeName ID_geo date using "FA_bulding_`a'`b'.dta"
	drop if log_t_t_Value_clean2 ==.
	
foreach VAR of varlist within* {
  replace `VAR' = 0 if missing(`VAR')  
}

sort CharacteristicName MonitoringLocationTypeName ID_geo date
capture drop _merge 

*********** Save file with well count variables for Figure 3 ***********

save "`ONLY_ONE_TYPE'_FA_bulding_`a'`b'.dta", replace
}
}


*****************************************************
* 4.6 Define final Sample For Figure 2 and Figure 3 *
*****************************************************

use "id_geo_estimation_sample_T_spud_date_augmented_ALL_bis_ALL.dta", replace

// keep only huc10s with HF [at least one well at some point in time]
keep if m_cum_well_huc10_H>0

// import well counts calculated over fixed time intervals around the spud dates
merge 1:1 CharacteristicName MonitoringLocationTypeName ID_geo date using "H_FA_bulding_id_geo_estimation_sample_T_spud_date_augmented_ALL_bis.dta"
drop if _merge==2
drop _merge

gen future_H_0_90 = within_H_0_0 + future_H_1_90 // combining counts from day 0 to 90
replace future_H_0_90 = 0 if future_H_0_90==.
replace future_H_91_180 = 0 if future_H_91_180==.
replace within_H_1_90 = 0 if within_H_1_90 ==.
replace within_H_91_180 = 0 if within_H_91_180 ==.
replace within_H_181_360 = 0 if within_H_181_360 ==.
replace within_H_361_1000000 = 0 if within_H_361_1000000==.

// In the main analyses, we use Ion Concentration V2 ["log_t_t_Value_clean2"]
drop log_t_t_Value_clean1 log_t_t_Value_clean3 mean_geo_Value_clean1_t99 mean_geo_Value_clean3_t99

// Compiling the relevant variables for the final sample
keep CharacteristicName MonitoringLocationTypeName ID_geo LatitudeMeasure LongitudeMeasure StateCode date huc10_s huc8_s huc4_s group_items ///
log_cum_prec_3days T_mean_D_5_groups snow log_t_t_Value_clean2 date_string_month date_string_year ID_geo_feN huc4_year_month_fe huc8_fe huc8_year_month_fe ///
cum_well_H m_cum_well_huc10_H mean_geo_Value_clean2_t99 shale_play basin within_H_1_90 within_H_91_180 within_H_181_360 within_H_361_1000000 future_H_91_180 future_H_0_90

save "id_geo_estimation_sample_T_spud_date_augmented_ALL_bis.dta", replace
