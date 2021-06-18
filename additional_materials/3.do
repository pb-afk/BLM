clear
set matsize 11000
set more off
cd "$dir1"

cap ssc install winsor2

************************************************************************************************
* 3. MERGE WATER DATA w/ PRECIPITATION / TEMPERATURE DATA - Performed on the computing cluster *
************************************************************************************************

// Start w/ Water Quality Data
use "1. Water quality data/water_quality_data_daily_wqs_buffer_new_NOV_2019_id_geo", clear
capture drop _merge*

// Merge w/ Grid Numbers Codes
merge m:1 monitoring using "../../temp_computing cluster/weather_buffers_monitors_codes.dta" 
keep if _merge == 3
capture drop _merge*
rename date dateNum
compress

// Drop non-Relevant Chemicals
drop if Ch=="Nitrogen"
drop if Ch=="Ethanol"

// Keep Only Relevant Variables
keep monitoring_code dateNum Ch

// Merge w/ Weather Data
merge m:1 monitoring_code dateNum using "../../temp_computing cluster/weather_WS_temp.dta" 
keep if _merge == 3
rename dateNum date

save "1. Water quality data/_id_geo_water_weather_data.dta", replace

// Start w/ Weather Data
use "1. Water quality data/_id_geo_water_weather_data", clear
capture drop _merge*

// Merge w/ Grid Numbers Codes
merge m:1 monitoring using "../../temp_computing cluster/weather_buffers_monitors_codes.dta" 
keep if _merge ==3
capture drop _merge*
append using "weather_to_append.dta" 

save "1. Water quality data/_id_geo_water_weather_data_clean.dta", replace

****************************************************
* 3.1.1 FURTHER CLEANING OF THE WATER QUALITY DATA * 
****************************************************

use "1. Water quality data/water_quality_data_daily_wqs_buffer_new_NOV_2019_id_geo.dta", clear

// Drop non-Relevant Water Body Sources
capture drop if MonitoringLocationTypeName=="LAND"
capture drop if MonitoringLocationTypeName=="Surface Water - W"

// Drop obs. before 2005
drop if year <=2005
tostring year, gen(year_string)

// Import Weather Data
merge 1:1 monitoring Ch date using "_id_geo_water_weather_data_clean.dta", gen(_merge_weather)
drop if _merge_weather==2

// Import HUC10s Assignment 
merge m:1 monitoring using "huc10/huc10 wqs/huc10_wqs_final.dta", gen(_merge_huc10)
keep if _merge_huc10==3
drop _merge_huc10

// create HUC10s Variables 
g huc8_s = substr(huc10_s,1,8)
g huc6_s = substr(huc10_s,1,6)
g huc4_s = substr(huc10_s,1,4)
destring huc8_s, gen(huc8)
destring huc6_s, gen(huc6)
destring huc4_s, gen(huc4)
egen group_HUC4 = group(huc4_s)

// Define Indicator Variable for the Chemicals
egen group_items = group(CharacteristicName)

// Cleaning
foreach var in varlist ActivityMediaSubdivisionName ActivityStartDate HydrologicEvent ///
			SampleCollectionMethodMethodIde MonitoringLocationName HUCEightDigitCode ///
			first_4 _merge areaacres areasqkm DetectionQuantitationLimitMeasur ///
			ProviderName ResultMeasureMeasureUnitCode ResultSampleFractionText ///
			ResultDetectionConditionText OrganizationIdentifier ActivityTypeCode ///
			ResultMeasureValue_0 ResultDetectionConditionText_D ResultDetectionConditionText_ ///
			ResultDetectionConditionValue SiteName_HydroD SiteID_HydroD SiteCode_HydroD ///
			VariableID_HydroD VariableCode_HydroD Organization_HydroD ///
			SourceDescription_HydroD DATA_SOURCE_HydroD FLAG1 FLAG2 ///
			mean_DataValue_HydroD median_DataValue_HydroD min_DataValue_HydroD ///
			max_DataValue_HydroD flag1 flag1_check flag2 flag2_check flag2_check_b ///
			monitoring_code gridNumber gridnumber _merge_weather ///
			huc10_s1 shape_leng shape_area v3 v4 data_sourc latitudeme longitudem ///
			 awater aland lsad name_2 stusps geoid affgeoid statens statefp flag {
	
	cap drop `var'
			 }

// Generate Weather Variables
g log_prec = log(1+prec)
g log_cum_prec_2days = log(1+cum_prec_2days)
g log_cum_prec_3days = log(1+cum_prec_3days)
g log_precB = log(0.01 +prec)
g log_cum_prec_2daysB = log(0.01 +cum_prec_2days)
g log_cum_prec_3daysB = log(0.01 +cum_prec_3days)

g T_mean = (tMin + tMax)/2
g T_mean_D_5_groups = 0 if T_mean<=-10 & T_mean!=.
replace T_mean_D_5_groups = 1 if T_mean>-10 & T_mean<=3
replace T_mean_D_5_groups = 2 if T_mean>3 & T_mean<=15
replace T_mean_D_5_groups = 3 if T_mean>15 & T_mean<=25
replace T_mean_D_5_groups = 4 if T_mean>25 & T_mean!=.
g T_mean_D_4_groups = 0 if T_mean<=3 & T_mean!=.
replace T_mean_D_4_groups = 1 if T_mean>3 & T_mean<=15
replace T_mean_D_4_groups = 2 if T_mean>15 & T_mean<=25
replace T_mean_D_4_groups = 3 if T_mean>25 & T_mean!=.

g snow = 1 if cum_prec_3days>0.5 & T_mean<=3 & T_mean!=. & cum_prec_3days!=.
replace snow = 0 if snow ==.
g snowB = 1 if cum_prec_3days>1.5 & T_mean<=3 & T_mean!=. & cum_prec_3days!=.
replace snowB = 0 if snowB ==.

// Truncating & Winsorizing
replace mean_geo_Value = mean_geo_Value*1000 // to ug/L 
replace mean_geo_Value_clean1 = mean_geo_Value_clean1*1000 // to ug/L 
replace mean_geo_Value_clean2 = mean_geo_Value_clean2*1000 // to ug/L 
replace mean_geo_Value_clean3 = mean_geo_Value_clean3*1000 // to ug/L 

// locals for the truncation and winsorization
local var ""mean_geo_Value" "mean_geo_Value_clean1" "mean_geo_Value_clean2" "mean_geo_Value_clean3""

foreach v of local var {
	g log_`v' = log(1 + `v')
}
//

// Winsorization by HUC4	
winsor2  mean_geo_Value mean_geo_Value_clean1 mean_geo_Value_clean2 mean_geo_Value_clean3 ///
		log_mean_geo_Value log_mean_geo_Value_clean1 log_mean_geo_Value_clean2 log_mean_geo_Value_clean3, ///
		cuts(0 99) by(group_HUC4 CharacteristicName) suffix("_w99") 

// Truncation by HUC4
winsor2  mean_geo_Value mean_geo_Value_clean1 mean_geo_Value_clean2 mean_geo_Value_clean3 ///
		log_mean_geo_Value log_mean_geo_Value_clean1 log_mean_geo_Value_clean2 log_mean_geo_Value_clean3, ///
		cuts(0 99) by(group_HUC4 CharacteristicName) trim suffix("_t99") 
	
// relabelling of the key variables
rename log_mean_geo_Value_t99          log_t_t_Value
rename log_mean_geo_Value_clean1_t99   log_t_t_Value_clean1
rename log_mean_geo_Value_clean2_t99   log_t_t_Value_clean2
rename log_mean_geo_Value_clean3_t99   log_t_t_Value_clean3
 
rename log_*_w99 log_w99_*
rename *_t99 t99_*
rename *_w99 w99_*

compress
save "WQS_DAILY__id_geo.dta", replace

// generate fixed effects
tostring date, gen(date_string) force usedisplayformat

g date_string_month = substr(date_string, 3, 3)
g date_string_year = substr(date_string, 6, 4)
g date_string_day = substr(date_string, 1, 2)

egen ID_geo_feN = group(ID_geo MonitoringLocationTypeName)
egen year_fe = group(date_string_year)
egen month_year_fe = group(date_string_month date_string_year)

egen state_fe = group(StateCode)
egen state_year_fe = group(StateCode date_string_year)
egen state_month_fe = group(StateCode date_string_month)
egen state_month_year_fe = group(StateCode date_string_month date_string_year)

egen huc4_fe = group(huc4_s)
egen huc4_year_fe = group(huc4_s date_string_year)
egen huc4_month_fe = group(huc4_s date_string_month)
egen huc4_year_month_fe = group(huc4_s date_string_month date_string_year)

egen huc8_fe = group(huc8_s)
egen huc8_year_fe = group(huc8_s date_string_year)
egen huc8_month_fe = group(huc8_s date_string_month)
egen huc8_year_month_fe = group(huc8_s date_string_month date_string_year)

egen huc10_fe = group(huc10_s)
egen huc10_year_fe = group(huc10_s date_string_year)
egen huc10_month_fe = group(huc10_s date_string_month)
egen huc10_year_month_fe = group(huc10_s date_string_month date_string_year)

compress
save "WQS_DAILY__id_geo_cleaned.dta", replace
