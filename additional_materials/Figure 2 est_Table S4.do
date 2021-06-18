*********************************
* Figure 2 Estimates [Table S4] *
*********************************

global dir1 "C:\Users\pbonetti\Dropbox (IESE)\fracking wqs analysis\Fracking to clean"

clear
set more off

cd "$dir1"

use "id_geo_estimation_sample_T_spud_date_augmented_ALL_bis.dta", clear

// In the main analyses, we use Ion Concentration V2 ["log_t_t_Value_clean2"]

label define ions 1 "Barium" 2 "Bromide" 3 "Chloride" 4 "Strontium"
label values group_items ions

* mark samples w/o singletons
local items 1 2 3 4
local errors "cluster(huc8_fe)"
local fe "ID_geo_feN"
local treatment "cum_well_H"

* generating sample identifiers
foreach k of local items {

	reghdfe log_t_t_Value_clean2 cum_well_H log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k' & m_cum_well_huc10_H>0, `errors' absorb(`fe')
	g sample_`k'_2_base = e(sample)

}

//

* gen count of # obs. per Ion-huc8-year-month
local items  1 2 3 4
foreach k of local items {
	bysort huc10_s CharacteristicName date_string_year date_string_month sample_`k'_2_base: gen weights_huc10_s`k'2 = _N if log_t_t_Value_clean2!=.
	bysort huc8_s CharacteristicName  date_string_year date_string_month sample_`k'_2_base: gen weights_huc8_s`k'2 = _N if log_t_t_Value_clean2!=.
	bysort huc4_s CharacteristicName  date_string_year date_string_month sample_`k'_2_base: gen weights_huc4_s`k'2 = _N if log_t_t_Value_clean2!=.
	replace weights_huc10_s`k'2 = 0 if weights_huc10_s`k'2 == .
	replace weights_huc8_s`k'2 =  0 if weights_huc8_s`k'2  == .
	replace weights_huc4_s`k'2 =  0 if weights_huc4_s`k'2  == . 

}
//

* Regressions to generate Figure 2 (Table S4) estimates
local items  1 2 3 4
foreach k of local items {

	* PA
	// 1 base w/ HUC4 
	reghdfe log_t_t_Value_clean2 `treatment' log_cum_prec_3days i.T_mean_D_5_groups  if group_items == `k' & m_cum_well_huc10_H>0 & StateCode=="42" & weights_huc8_s`k'2>=2 , `errors' absorb(`fe' huc4_year_month_fe)
	g sample_`k'_STAT1 = e(sample)
	outreg2 using TabS4`k'Value2`errors'`fe'.xls, /// 
	title ("ATE - `k' - Value 2") ctitle("Only Treated") ///
	bracket bdec (5) sdec(5) replace ///
	addtext(Sample, PA - huc8 with at least 2 obs., Weather Controls, Yes, Monitoring FE, Yes, HUC4*Month*Year FE, Yes)
	// 2 base w/ HUC8
	reghdfe log_t_t_Value_clean2 `treatment' log_cum_prec_3days i.T_mean_D_5_groups  if group_items == `k' & m_cum_well_huc10_H>0 & StateCode=="42" & weights_huc8_s`k'2>=2 , `errors' absorb(`fe' huc8_year_month_fe)
	outreg2 using TabS4`k'Value2`errors'`fe'.xls, /// 
	title ("ATE - `k' - Value 2") ctitle("Only Treated") ///
	bracket bdec (5) sdec(5) append ///
	addtext(Sample, PA - huc8 with at least 2 obs., Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)

	* ALL
	// 3 base w/ HUC4
	reghdfe log_t_t_Value_clean2 `treatment' log_cum_prec_3days i.T_mean_D_5_groups  if group_items == `k' & m_cum_well_huc10_H>0 & weights_huc8_s`k'2>=2 , `errors' absorb(`fe' huc4_year_month_fe)
	g sample_`k'_STAT3 = e(sample)
	outreg2 using TabS4`k'Value2`errors'`fe'.xls, /// * Variables you want to display
	title ("ATE - `k' - Value 2") ctitle("Only Treated") ///
	bracket bdec (5) sdec(5) append ///
	addtext(Sample, All - huc8 with at least 2 obs., Weather Controls, Yes, Monitoring FE, Yes, HUC4*Month*Year FE, Yes)
	// 4 base w/ HUC8
	reghdfe log_t_t_Value_clean2 `treatment' log_cum_prec_3days i.T_mean_D_5_groups  if group_items == `k' & m_cum_well_huc10_H>0 & weights_huc8_s`k'2>=2, `errors' absorb(`fe' huc8_year_month_fe)
	outreg2 using TabS4`k'Value2`errors'`fe'.xls, /// * Variables you want to display
	title ("ATE - `k' - Value 2") ctitle("Only Treated") ///
	bracket bdec (5) sdec(5) append ///
	addtext(Sample, All - huc8 with at least 2 obs., Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)

}


**************************************************
* Inputs for Figure 2 [Table S1, Panels A and B] *
**************************************************

// These descriptive statistics are computed for the final sample, which we obtain after estimating the regressions - see commands in row #55 and row #70

bysort Ch huc10_s: egen total_final_cum_well_H = max(cum_well_H)

// Table S1, Panel A
tabstat log_t_t_Value_clean2 mean_geo_Value_clean2_t99 total_final_cum_well_H if CharacteristicName=="Barium" & sample_1_STAT3 == 1, stat(count mean p25 p50 p75 sd) columns(statistics) 
tabstat log_t_t_Value_clean2 mean_geo_Value_clean2_t99 total_final_cum_well_H if CharacteristicName=="Bromide" & sample_2_STAT3 == 1, stat(count mean p25 p50 p75 sd) columns(statistics) 
tabstat log_t_t_Value_clean2 mean_geo_Value_clean2_t99 total_final_cum_well_H if CharacteristicName=="Chloride" & sample_3_STAT3 == 1, stat(count mean p25 p50 p75 sd) columns(statistics) 
tabstat log_t_t_Value_clean2 mean_geo_Value_clean2_t99 total_final_cum_well_H if CharacteristicName=="Strontium" & sample_4_STAT3 == 1, stat(count mean p25 p50 p75 sd) columns(statistics) 

// Table S1, Panel B
tabstat log_t_t_Value_clean2 mean_geo_Value_clean2_t99 total_final_cum_well_H if CharacteristicName=="Barium" & sample_1_STAT1 == 1, stat(count mean p25 p50 p75 sd) columns(statistics) 
tabstat log_t_t_Value_clean2 mean_geo_Value_clean2_t99 total_final_cum_well_H if CharacteristicName=="Bromide" & sample_2_STAT1 == 1, stat(count mean p25 p50 p75 sd) columns(statistics) 
tabstat log_t_t_Value_clean2 mean_geo_Value_clean2_t99 total_final_cum_well_H if CharacteristicName=="Chloride" & sample_3_STAT1 == 1, stat(count mean p25 p50 p75 sd) columns(statistics) 
tabstat log_t_t_Value_clean2 mean_geo_Value_clean2_t99 total_final_cum_well_H if CharacteristicName=="Strontium" & sample_4_STAT1 == 1, stat(count mean p25 p50 p75 sd) columns(statistics) 
