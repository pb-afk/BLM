********************
* 5. Paired-Sample *
********************

clear
set more off
cd "$dir1"


local d spud_date_augmented 
local b _bis

local ions "Barium Bromide Chloride Strontium"
local n_models : word count `ions'

forval i=1/`n_models' {

		local ion_type `: word `i' of `ions''
		di "`ion_type'"
		
		use "id_geo_estimation_sample_T_spud_date_augmented_ALL_bis_ALL.dta", clear
		compress

		foreach var in varlist state_county_ID CountryCode CountyCode Value_clean1 Value_clean2 Value_clean3 ///
		SiteName_HydroD SiteID_HydroD SiteCode_HydroD VariableID_HydroD VariableCode_HydroD ///
		 Organization_HydroD DATA_SOURCE_HydroD SourceDescription_HydroD FLAG1 FLAG2 flag max_DataValue_HydroD ///
		 min_DataValue_HydroD median_DataValue_HydroD mean_DataValue_HydroD OrganizationIdentifier ///
		 ActivityTypeCode MonitoringLocationIdentifier ResultDetectionConditionText ResultSampleFractionText ResultMeasureMeasureUnitCode  ///
		DetectionQuantitationLimitMeasur ProviderName ResultDetectionConditionText_D ///
		ResultDetectionConditionText_ ResultDetectionConditionValue weights_* sample_* {
			cap drop `var'
	}

	keep if m_cum_well_huc10_H>0
	keep if CharacteristicName=="`ion_type'"
	tab CharacteristicName
	save "id_geo_estimation_sample_T_`d'_ALL`b'_paired_def`i'D.dta", replace
}


local d spud_date_augmented 
local b _bis
forval i = 1/4 {

	// start with database containing direction and distance information 
	use "T3_start`i'.dta", clear
	keep  api10 FlowDir_WD_H FlowLen_WD_H FlowDir_DI_H FlowLen_DI_H FlowDir_padep FlowLen_padep monitoring FlowDir FlowLen distance_geodes state_api spud_date_augmented

	// merge with monitoring stations
	merge m:1 monitoring using "water_quality_data_daily_wqs_buffer_new_NOV_2019_id_geo_forpaired`i'BIS.dta", gen(_merge_check)
	keep if _merge_check == 3

	// create pairs
	joinby ID_geo MonitoringLocationTypeName using "id_geo_estimation_sample_T_`d'_ALL`b'_paired_def`i'D.dta" 
	compress

	merge m:1 monitoring CharacteristicName MonitoringLocationTypeName using "huc12_monitoring.dta", gen(_merge_huc12) 
	keep if _merge_huc12==3
	merge m:1 api10 using "huc12_api10.dta", gen(_merge_huc12_api10)
	keep if _merge_huc12_api10==3
	drop _merge_huc12_api10 _merge_huc12

	// Create flow lenght variable for wells
	g FlowLen_DI_WD = FlowLen_padep if state_api=="37"
	replace FlowLen_DI_WD = FlowLen_WD_H if FlowLen_DI_WD ==.
	replace FlowLen_DI_WD = FlowLen_DI_H if FlowLen_DI_WD ==.

	// "Likely" upstream / downstream assignemnt			
	g upstream_len = 1 if FlowLen_DI_WD > FlowLen
	replace upstream_len = 0 if upstream_len==.
	g upstream_lenD = 1 if upstream_len == 1 & huc12_s_mon ==huc12_s_well
	replace upstream_lenD = 0 if upstream_lenD ==.

	// Post spud variable
	g post_= 1 if date > `d'
	replace post_ = 0 if post_==.

	// check code
	g dif_days = date - `d'
	g post_d = 1 if date > `d' 
	g pre_d = 1 if date <= `d' 
	replace post_d = 0 if post_d==.
	replace pre_d = 0 if pre_d==.
	bysort Ch api10: egen m_post_d = max(post_d)
	bysort Ch api10: egen m_pre_d = max(pre_d)
	g both_pre_post = 1 if  m_post_d==1 & m_pre_d==1
	replace both_pre_post = 0 if both_pre_post==.

	// Distance brackets
	rename distance_geodesic _Distance_m_
	g within5km = 1 if _Distance_m_<=5000 & _Distance_m_!=.
	replace  within5km = 0 if within5km==.
	g within10km = 1 if _Distance_m_<=10000 & _Distance_m_!=.
	replace within10km = 0 if within10km==.
	g within15km = 1 if _Distance_m_<=15000 & _Distance_m_!=.
	replace within15km = 0 if within15km==.
	g within20km = 1 if _Distance_m_<=20000 & _Distance_m_!=.
	replace within20km = 0 if within20km==.

	* FE
	egen group_ID_geo_WELL = group(ID_geo MonitoringLocationTypeName api10)
	egen group_huc8_year_month = group(huc8_s date_string_year date_string_month)

	compress
	foreach var in varlist OrganizationIdentifier ActivityTypeCode ///
		MonitoringLocationIdentifier ResultDetectionConditionText ///
		ResultSampleFractionText ResultMeasureMeasureUnitCode  ///
		DetectionQuantitationLimitMeasur ProviderName ///
		ResultDetectionConditionText_D ResultDetectionConditionText_ ///
		ResultDetectionConditionValue weights_* sample_* {
		
		cap drop `var'
	}



	save "_`i'FEB.dta", replace // this sample is an input for Table S11

}
//

local b _bis
local d spud_date_augmented

use "_1FEB.dta", clear
append using "_2FEB.dta"
append using "_3FEB.dta"
append using "_4FEB.dta"

// imposing further sample restrictions for table S12

// drop obs.: only upstream
keep if upstream_lenD == 1

// drop obs.: only within 15km
keep if within15km == 1

// Using only observations up to 360-day after the spud date
capture drop within_360dd
capture drop m_360
g within_360dd = 1 if date<= `d' + 360
replace within_360dd = 0 if within_360dd==.
capture drop sample_*
capture drop weights_huc8_s*
keep if within_360dd==1

// drop obs.: at least 2 in pre and post by pair
bysort Ch group_ID_geo_WELL post_: g tot_pre =  _N if post_ == 0
bysort Ch group_ID_geo_WELL post_: g tot_post =  _N if post_ == 1
replace tot_pre = 0 if tot_pre ==.
replace tot_post = 0 if tot_post ==.
bysort Ch group_ID_geo_WELL : egen Mtot_pre =  max(tot_pre)
bysort Ch group_ID_geo_WELL : egen Mtot_post =  max(tot_post)
drop if Mtot_pre <=1
drop if Mtot_post <=1

egen group_api = group(api10)

keep log_t_t_Value_clean3 log_t_t_Value_clean2 log_t_t_Value_clean1 mean_geo_Value_clean3_t99 mean_geo_Value_clean2_t99 mean_geo_Value_clean1_t99 log_cum_prec_3days T_mean_D_5_groups group_items huc4_year_month_fe huc8_year_month_fe  huc10_s huc8_s huc4_s  CharacteristicName date_string_year date_string_month huc8_fe ID_geo_feN StateCode MonitoringLocationTypeName Ch post_ group_huc8_year_month  group_ID_geo_WELL date_string_month huc10_s group_api StateCode spud_date_augmented MonitoringLocationTypeName date

compress

save "paired_sample.dta", replace

				