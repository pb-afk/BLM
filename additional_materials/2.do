clear
set more off
set excelxlsxlargefile on
cd "$dir1"

*****************************
** 2. CLEANING OF HF WELLS **
*****************************

***********************
* 2.1.1. DrillingInfo *
***********************

// Import & Clean Raw Well Data
forval n = 1 / 20 {
import excel "0.1.1 DI data/well location/`n'.xlsx", firstrow allstring clear
save "0.1.1 DI data/well location/`n'.dta", replace
clear
}
//

use "0.1.1 DI data/well location/1.dta", clear
forval n = 2 / 20 {
append using "0.1.1 DI data/well location/`n'.dta"
}
//

// Some Cleaning
drop BottomHoleLatitude BottomHoleLongitude QuarterQuarter District Abstract Block Survey LASMnemonics Country Basin ///
 First6BOE First6Gas First6Oil First12BOE First12Gas First12Oil First24BOE First24Gas First24Oil First60BOE First60Gas First60Oil ///
 KBE UpperPerforation LowerPerforation PerforatedIntervalLength HorizontalLength WellboreCount CompletionCount TreatmentJobCount 
destring GroundElevation, replace
destring MeasuredDepthTD, replace
destring TrueVerticalDepth, replace
destring SurfaceHoleLatitude, replace
destring SurfaceHoleLongitude, replace

// Cleaning Spud Date
g splitat = strpos(SpudDate, "/")
g month = substr(SpudDate, 1,splitat -1)
g other = substr(SpudDate, splitat +1,.)
drop splitat
g splitat = strpos(other, "/")
g day = substr(other, 1,splitat -1)
g other_b = substr(other, splitat +1,.)
drop other
drop splitat
rename other_b year
g monthh ="jan" if month==" 1"
replace monthh ="jan" if month=="  1"
replace monthh ="feb" if month==" 2"
replace monthh ="mar" if month==" 3"
replace monthh ="apr" if month==" 4"
replace monthh ="may" if month==" 5"
replace monthh ="jun" if month==" 6"
replace monthh ="jul" if month==" 7"
replace monthh ="aug" if month==" 8"
replace monthh ="sep" if month==" 9"
replace monthh ="feb" if month=="  2"
replace monthh ="mar" if month=="  3"
replace monthh ="apr" if month=="  4"
replace monthh ="may" if month=="  5"
replace monthh ="jun" if month=="  6"
replace monthh ="jul" if month=="  7"
replace monthh ="aug" if month=="  8"
replace monthh ="sep" if month=="  9"
replace monthh ="oct" if month==" 10"
replace monthh ="oct" if month=="10"
replace monthh ="nov" if month==" 11"
replace monthh ="nov" if month=="11"
replace monthh ="dec" if month==" 12"
replace monthh ="dec" if month=="12"
g datadate = day + monthh + year
g datadate_spud = date(datadate, "DMY")
format datadate_s %d
drop datadate month monthh day year

// Cleaning Completion Date
g splitat = strpos(CompletionDate, "/")
g month = substr(CompletionDate, 1,splitat -1)
g other = substr(CompletionDate, splitat +1,.)
drop splitat
g splitat = strpos(other, "/")
g day = substr(other, 1,splitat -1)
g other_b = substr(other, splitat +1,.)
drop other
drop splitat
rename other_b year
g monthh ="jan" if month==" 1"
replace monthh ="jan" if month=="  1"
replace monthh ="feb" if month==" 2"
replace monthh ="mar" if month==" 3"
replace monthh ="apr" if month==" 4"
replace monthh ="may" if month==" 5"
replace monthh ="jun" if month==" 6"
replace monthh ="jul" if month==" 7"
replace monthh ="aug" if month==" 8"
replace monthh ="sep" if month==" 9"
replace monthh ="feb" if month=="  2"
replace monthh ="mar" if month=="  3"
replace monthh ="apr" if month=="  4"
replace monthh ="may" if month=="  5"
replace monthh ="jun" if month=="  6"
replace monthh ="jul" if month=="  7"
replace monthh ="aug" if month=="  8"
replace monthh ="sep" if month=="  9"
replace monthh ="oct" if month==" 10"
replace monthh ="oct" if month=="10"
replace monthh ="nov" if month==" 11"
replace monthh ="nov" if month=="11"
replace monthh ="dec" if month==" 12"
replace monthh ="dec" if month=="12"
g datadate = day + monthh + year
g datadate_completion = date(datadate, "DMY")
format datadate_completion %d
drop datadate month monthh day year CompletionDate

// Cleaning First Prod Date
g splitat = strpos(FirstProdDate, "/")
g month = substr(FirstProdDate, 1,splitat -1)
g other = substr(FirstProdDate, splitat +1,.)
drop splitat
g splitat = strpos(other, "/")
g day = substr(other, 1,splitat -1)
g other_b = substr(other, splitat +1,.)
drop other
drop splitat
rename other_b year
g monthh ="jan" if month==" 1"
replace monthh ="jan" if month=="  1"
replace monthh ="feb" if month==" 2"
replace monthh ="mar" if month==" 3"
replace monthh ="apr" if month==" 4"
replace monthh ="may" if month==" 5"
replace monthh ="jun" if month==" 6"
replace monthh ="jul" if month==" 7"
replace monthh ="aug" if month==" 8"
replace monthh ="sep" if month==" 9"
replace monthh ="feb" if month=="  2"
replace monthh ="mar" if month=="  3"
replace monthh ="apr" if month=="  4"
replace monthh ="may" if month=="  5"
replace monthh ="jun" if month=="  6"
replace monthh ="jul" if month=="  7"
replace monthh ="aug" if month=="  8"
replace monthh ="sep" if month=="  9"
replace monthh ="oct" if month==" 10"
replace monthh ="oct" if month=="10"
replace monthh ="nov" if month==" 11"
replace monthh ="nov" if month=="11"
replace monthh ="dec" if month==" 12"
replace monthh ="dec" if month=="12"
g datadate = day + monthh + year
g datadate_prod_date = date(datadate, "DMY")
format datadate_p %d
drop datadate month monthh day year FirstProdDate

compress
save "0.1.1 DI data/well location/well_ID_DI_2019.dta", replace

use "0.1.1 DI data/well location/well_ID_DI_2019.dta", clear
rename SurfaceHoleLatitude latitude
rename SurfaceHoleLongitude longitude
compress

// Base Cleaning
drop if longitude==. | latitude ==.
drop if DrillType==""
drop if DrillType=="30000000000000"
drop if ProductionType=="WATER"
drop if ProductionType=="WATER SUPPLY" 
drop if ProductionType=="WSW (UNDEFINED)"
drop if ProductionType=="N/A" 
drop if ProductionType=="NOT REPORTED" // spudding before 14jan1996
drop if ProductionType=="STRATIGRAPHIC/CORE TEST"

// Cleaning api10 ID
g API10_l = length(API10) 
replace API10 = "0" + API10 if API10_l ==9
g state_api = substr(API10,1,2)
g api10 = API10

// Identify Duplicates
duplicates tag API10 DrillType, gen(flag_p)

// Drop Weird Wells
// They are weird because they have some V, H, U, at different points in time over 50 years
drop if API10== "2501521769" | ///
API10== "2502105015" | ///
API10== "2502505376" | ///
API10== "2502521436" | ///
API10== "2502521930" | ///
API10== "2507921030" | ///
API10== "2508322401" | ///
API10== "2508323130" | ///
API10== "2510905011" | ///
API10== "2510921147"

// alterntive ways of measuring relevant dates [for robustness tests and checks only]
bysort API10 DrillType: egen m_datadate_spud = min(datadate_spud)
format m_datadate_spud %d
compare m_datadate_spud datadate_spud
bysort API10 DrillType: egen m_datadate_prod_date = min(datadate_prod_date)
format m_datadate_prod_date %d
compare m_datadate_prod_date datadate_prod_date
bysort API10 DrillType: egen m_datadate_completion = min(datadate_completion)
format m_datadate_completion %d
compare m_datadate_completion  datadate_completion
g m_datadate_spud_bis = m_datadate_spud
replace m_datadate_spud_bis = m_datadate_completion if m_datadate_completion!=. & m_datadate_spud_bis==.
format m_datadate_spud_bis %d

// drop obs. with missing dates
egen date_check =  rowmin(m_datadate_spud m_datadate_prod_date m_datadate_completion)
format date_check %d
drop if date_check ==.

bysort API10 DrillType: gen ok = 1 if DrillType==DrillType[_n+1]
keep if ok ==. // drop duplicates [checked: these are truly duplicates]
cap drop check_dDrillType 
cap drop ok
duplicates tag API10, gen(check_d)
drop if check_d>0 & DrillType !="H" // same spud dates, different types, give priority to "H". Those are wells with some H and V together
isid API10

save "0.1.1 DI data/well_ID_DI_to_import_NOV 2019.dta", replace

// for the QGIS to allocate wells to the corresponding huc10s
use "0.1.1 DI data/well_ID_DI_to_import_NOV 2019.dta", clear
keep if DrillType=="H"
keep api10 latitude longitude DrillType
export delimited using "0.1.1 DI data/DI_well_list_NOV 2019_H.csv", replace // file with HUC10 ALLOCATION: "DI_list_H_huc10.csv" 
// for the QGIS to allocate wells [non-H] to the corresponding huc10s
use "0.1.1 DI data/well_ID_DI_to_import_NOV 2019.dta", clear
drop if DrillType!="H"
keep api10 latitude longitude DrillType
export delimited using "0.1.1 DI data/DI_well_list_NOV 2019_ALL_NON_H.csv", replace // file with HUC10 ALLOCATION: "DI_list_non_H_huc10.csv" 

// Import List of Wells w/ HUC10 Assignement
import delimited "0.1.1 DI data/DI_list_H_huc10.csv", clear
drop x y tnmid metasource sourcedata sourceorig sourcefeat loaddate gnis_id name hutype humod

// Clean api10 ID
rename api10 api10_d
tostring api10_d, gen(api10)
drop api10_d
g api10_l = length(api10) 
replace api10 = "0" + api10 if api10_l ==9 
drop api10_l 

// Clean HUC10 ID
tostring huc10, gen(huc10_s)
g huc10_l = length(huc10_s) 
replace huc10_s = "0" + huc10_s if huc10_l ==9
drop huc10_l

drop drilltype latitude longitude shape_leng shape_area

// Import Wells Details 
merge 1:1 api10 using "0.1.1 DI data/well_ID_DI_to_import_NOV 2019.dta", gen(_merge_well)
keep if _merge_well==3
drop _merge*

destring MeasuredDepthTD, replace 
destring TrueVerticalDepth, replace

// tostring m_first_date, gen(m_first_date_s) force usedisplayformat
tostring m_datadate_spud, gen(m_datadate_spud_s) force usedisplayformat
tostring m_datadate_prod_date, gen(m_datadate_prod_date_s) force usedisplayformat
tostring m_datadate_completion, gen(m_datadate_completion_s) force usedisplayformat
// tostring m_last_date, gen(m_last_date_s) force usedisplayformat

g year = substr(m_datadate_spud_s,6,4)  // DEL LATER
g month_year = substr(m_datadate_spud_s,3,7) // DEL LATER
destring year, gen(year_fe) // DEL LATER
egen group_month_year = group(month_year) // DEL LATER

g huc8_s = substr(huc10_s,1,8) // DEL LATER
egen group_huc8 = group(huc8_s) // DEL LATER
egen group_huc10 = group(huc10_s) // DEL LATER

g state_county_ID = substr(api10,1,5)

// cleaning
foreach var in varlist WellStatus  states CountyParish year_fe API10  StartDateFirstTreatmentJob - CumOil ///
				HasDigitizedTrajectoryYN HasWellLogLASYN HasWellLogRasterYN API12 API14  ///
				WellNumber LeaseName Field GroundElevation MeasuredDepthTD TrueVerticalDepth SpudDate Section Township Range UWI API10_l check_d ///
				datadate_spud datadate_completion datadate_prod_date   WellName state_api {
	cap drop `var'
}

// Import Shale info
merge 1:1 api10 using "0.1.1 DI data/H_DI_shale_huc10_ID", gen(_merge_shale)
keep if _merge_shale == 3
drop _merge_shale

merge 1:1 api10 using "0.1.1 DI data/H_basin_DI_shale_huc10_ID.dta", gen(_merge_basin)
keep if _merge_basin == 3
drop _merge_basin

// Cleaning State info based on api10 (for checks only)
g state_api = substr(api10,1,2)
g 		STATE="Alabama"       if state_api=="01"
replace STATE="Arizona"       if state_api=="02"
replace STATE="Arkansas"      if state_api=="03"
replace STATE="California"    if state_api=="04"
replace STATE="Colorado"      if state_api=="05"
replace STATE="Kansas"        if state_api=="15"
replace STATE="Kentucky"      if state_api=="16"
replace STATE="Louisiana"     if state_api=="17"
replace STATE="Michigan"      if state_api=="21"
replace STATE="Mississippi"   if state_api=="23"
replace STATE="Montana"       if state_api=="25"
replace STATE="Nebraska"      if state_api=="26"
replace STATE="New Mexico"    if state_api=="30"
replace STATE="New York"      if state_api=="31"
replace STATE="North Dakota"  if state_api=="33"
replace STATE="Ohio"          if state_api=="34"
replace STATE="Oklahoma"      if state_api=="35"
replace STATE="PA"            if state_api=="37"
replace STATE="South Dakota"  if state_api=="40"
replace STATE="Texas"         if state_api=="42"
replace STATE="Utah"          if state_api=="43"
replace STATE="Virginia"      if state_api=="45"
replace STATE="West Virginia" if state_api=="47"
replace STATE="Wyoming"       if state_api=="49"
replace STATE="Alaska"        if state_api=="50"

save "0.1.1 DI data/huc10_DI_H.dta", replace

***********************
* 2.1.2. WellDatabase *
***********************

use "WellDatabase/WD_cut.dta", clear

// Base Cleaning
drop if WD_api==""
drop if WD_latitude ==. | WD_longitude ==.
drop if WD_spuddate_int==. & WD_completiondate_int==. & WD_firstproddate_int==.
drop if WD_wellboreprofile=="Lateral 1 (Northeast)"
drop if WD_wellboreprofile=="Lateral 1 (West)"
drop if WD_wellboreprofile=="Lateral 2 (Northeast sidetrack 1)"
drop if WD_wellboreprofile=="N"
drop if WD_wellboreprofile=="Y"
drop if WD_state=="GoM"
drop if WD_wellboreprofile==""
drop if WD_welltype==""

preserve

// for the QGIS to allocate wells to the corresponding huc10s
// for the QGIS [H wells]
// dropped obs. with missing api10
// dropped obs. with missing WD type
// dropped obs. with wierd WD_wellboreprofile
// dropped obs. with missing lat/long
// dropped obs. with missing dates
// dropped non-H wells
sort api10 WD_spuddate_int
keep WD_api api10 WD_latitude WD_longitude WD_welltype WD_wellboreprofile WD_spuddate_int WD_completiondate_int WD_firstproddate_int
keep if WD_wellboreprofile=="HORIZONTAL"
export delimited using "WellDatabase/WellDatabase_list_H.csv", replace

restore, preserve
// for the QGIS to allocate wells [non-H] to the corresponding huc10s
// dropped obs. with missing api10
// dropped obs. with missing WD type
// dropped obs. with wierd WD_wellboreprofile
// dropped obs. with missing lat/long
// dropped obs. with missing dates
// dropped H wells
sort api10 WD_spuddate_int
keep WD_api api10 WD_latitude WD_longitude WD_welltype WD_wellboreprofile WD_spuddate_int WD_completiondate_int WD_firstproddate_int
drop if WD_wellboreprofile != "HORIZONTAL"
export delimited using "WellDatabase/WellDatabase_list_non-H.csv", replace

restore
// Remove Duplicates [manually checked] 
sort api10 WD_wellboreprofile
duplicates tag api10 WD_wellboreprofile, gen(check_dDrillType)
drop if inlist(check_dDrillType,8,10,15) // These are not relevant wells, either before 2003 or after 2016, or marked as U
drop check_dDrillType

// Alterntive ways of measuring spud dates [for robustness tests and checks only]
bysort api10 WD_wellboreprofile: egen m_WD_spuddate_int = min(WD_spuddate_int)
format m_WD_spuddate_int %d
bysort api10 WD_wellboreprofile: egen m_WD_completiondate_int = min(WD_completiondate_int)
format m_WD_completiondate_int %d
g m_WD_spuddate_int_bis = m_WD_spuddate_int 
replace m_WD_spuddate_int_bis =m_WD_completiondate_int if m_WD_spuddate_int_bis==. & m_WD_completiondate_int!=.
format m_WD_spuddate_int_bis %d

bysort api10 WD_wellboreprofile: gen ok = 1 if WD_wellboreprofile==WD_wellboreprofile[_n+1]
keep if ok ==. // drop duplicates [checked: these are truly duplicates]
cap drop check_dDrillType 
cap drop ok
duplicates tag api10, gen(check_d)
drop if check_d>0 & WD_wellboreprofile !="HORIZONTAL" // same spud dates, different types, give priority to "H". Those are wells with some H and V together
isid api10

save "WellDatabase/well_ID_WD_to_import_NOV 2019.dta", replace

// Import List of Wells w/ HUC10 Assignement
import delimited "WellDatabase/WD_list_H_huc10.csv", clear

// check for duplicates
duplicates tag api10 wd_wellbor, gen(check_dDrillType)
g wd_spuddat_ = date(wd_spuddat, "DMY")
format wd_spuddat_ %d
drop check_dDrillType

sort api10 wd_spuddat
bysort api10 wd_wellbor: gen ok = 1 if wd_wellbor==wd_wellbor[_n+1]
keep if ok ==. // drop duplicates [checked: these are truly duplicates]
drop  ok
duplicates tag api10, gen(check_d )
isid api10

// Cleaning
foreach var in varlist x y tnmid metasource sourcedata sourceorig ///
			sourcefeat loaddate gnis_id name hutype humod {
	cap drop `var'		
	}

// Clean api10 ID
rename api10 api10_d
tostring api10_d, gen(api10)
drop api10_d
g api10_l = length(api10) 
replace api10 = "0" + api10 if api10_l ==9
drop api10_l 

// Clean HUC10 ID
tostring huc10, gen(huc10_s)
g huc10_l = length(huc10_s) 
replace huc10_s = "0" + huc10_s if huc10_l ==9
drop huc10_l

drop shape_leng shape_area wd_spuddat wd_complet wd_longitu wd_latitud  wd_welltyp ///
 wd_spuddat_ check_d wd_firstpr wd_api

// Import Wells Details 
merge 1:1 api10 using "WellDatabase/well_ID_WD_to_import_NOV 2019.dta", gen(_merge_well)
keep if _merge_well==3
drop _merge*

tostring WD_spuddate_int, gen(WD_spuddate_int_s) force usedisplayformat
g year = substr(WD_spuddate_int_s,6,4) // DEL LATER
g month_year = substr(WD_spuddate_int_s,3,7) // DEL LATER
egen group_month_year = group(month_year) // DEL LATER
destring year, gen(year_fe) // DEL LATER

g state_county_ID = substr(api10,1,5) 
egen group_huc10 = group(huc10_s) // DEL LATER
g huc8_s = substr(huc10_s,1,8) // DEL LATER
egen group_huc8 = group(huc8_s) // DEL LATER

drop WD_wellboreprofile
rename wd_wellbor WD_wellboreprofile

// Cleaning
capture drop check_d
capture drop state_api

// Import Shale info
merge 1:1 api10 using "WellDatabase/H_WD_shale_huc10_ID", gen(_merge_shale)
keep if _merge_shale == 3
drop _merge_shale

merge 1:1 api10 using "WellDatabase/H_basin_WD_shale_huc10_ID", gen(_merge_basin)
keep if _merge_basin == 3
drop _merge_basin

// Cleaning State info based on api10 (for checks only)
g state_api = substr(api10,1,2)
g 		STATE="Alabama"       if state_api=="01"
replace STATE="Arizona"       if state_api=="02"
replace STATE="Arkansas"      if state_api=="03"
replace STATE="California"    if state_api=="04"
replace STATE="Colorado"      if state_api=="05"
replace STATE="Kansas"        if state_api=="15"
replace STATE="Kentucky"      if state_api=="16"
replace STATE="Louisiana"     if state_api=="17"
replace STATE="Michigan"      if state_api=="21"
replace STATE="Mississippi"   if state_api=="23"
replace STATE="Montana"       if state_api=="25"
replace STATE="Nebraska"      if state_api=="26"
replace STATE="New Mexico"    if state_api=="30"
replace STATE="New York"      if state_api=="31"
replace STATE="North Dakota"  if state_api=="33"
replace STATE="Ohio"          if state_api=="34"
replace STATE="Oklahoma"      if state_api=="35"
replace STATE="PA"            if state_api=="37"
replace STATE="South Dakota"  if state_api=="40"
replace STATE="Texas"         if state_api=="42"
replace STATE="Utah"          if state_api=="43"
replace STATE="Virginia"      if state_api=="45"
replace STATE="West Virginia" if state_api=="47"
replace STATE="Wyoming"       if state_api=="49"
replace STATE="Alaska"        if state_api=="50"

save "WellDatabase/huc10_WD_H.dta", replace

****************
* 2.1.3. PADEP *
****************

// Import & Clean Raw Well Data
import delimited "NM CO PA/PA/PADEP_Spud_External_Data.csv", clear

// Cleaning Spud Dates
g splitat = strpos(ïspud_date, "/")
g month = substr(ïspud_date, 1,splitat -1)
g other = substr(ïspud_date, splitat +1,.)
drop splitat
g splitat = strpos(other, "/")
g day = substr(other, 1,splitat -1)
g other_b = substr(other, splitat +1,.)
drop other
drop splitat
rename other_b year
g month_b = "jan" if month==" 1"
replace month_b = "feb" if month==" 2"
replace month_b = "feb" if month==" 2"
replace month_b = "mar" if month==" 3"
replace month_b = "mar" if month==" 3"
replace month_b = "apr" if month==" 4"
replace month_b = "may" if month==" 5"
replace month_b = "jun" if month==" 6"
replace month_b = "jul" if month==" 7"
replace month_b = "aug" if month==" 8"
replace month_b = "sep" if month==" 9"
replace month_b = "oct" if month==" 10"
replace month_b = "nov" if month==" 11"
replace month_b = "dec" if month==" 12"
replace month_b = "jan" if month=="  1"
replace month_b = "feb" if month=="  2"
replace month_b = "feb" if month=="  2"
replace month_b = "mar" if month=="  3"
replace month_b = "mar" if month=="  3"
replace month_b = "apr" if month=="  4"
replace month_b = "may" if month=="  5"
replace month_b = "jun" if month=="  6"
replace month_b = "jul" if month=="  7"
replace month_b = "aug" if month=="  8"
replace month_b = "sep" if month=="  9"
replace month_b = "oct" if month=="  10"
replace month_b = "nov" if month=="  11"
replace month_b = "dec" if month=="  12"
replace month_b = "jan" if month=="1"
replace month_b = "feb" if month=="2"
replace month_b = "feb" if month=="2"
replace month_b = "mar" if month=="3"
replace month_b = "mar" if month=="3"
replace month_b = "apr" if month=="4"
replace month_b = "may" if month=="5"
replace month_b = "jun" if month=="6"
replace month_b = "jul" if month=="7"
replace month_b = "aug" if month=="8"
replace month_b = "sep" if month=="9"
replace month_b = "oct" if month=="10"
replace month_b = "nov" if month=="11"
replace month_b = "dec" if month=="12"
drop month
replace day = "01" if day=="1"
replace day = "02" if day=="2"
replace day = "03" if day=="3"
replace day = "04" if day=="4"
replace day = "05" if day=="5"
replace day = "06" if day=="6"
replace day = "07" if day=="7"
replace day = "08" if day=="8"
replace day = "09" if day=="9"
g datadate_spud_s = day + month_b + year
g datadate_spud = date(datadate_spud_s, "DMY")
format datadate_spud %d
rename datadate_spud m_datadate_spud
g m_datadate_spudPADEP = m_datadate_spud
g m_datadate_spudPADEP_s = datadate_spud_s

// Cleaning Well ID
g api3 = substr(api, 1, 3)
g api5 = substr(api, 5, 5)
g api10 = "37" + api3 + api5
drop api3 api5

drop ïspud_date api ogo_num day year month_b m_datadate_spudPADEP m_datadate_spudPADEP_s

save "well_pa non H wells NOV 2019.dta", replace

// for the QGIS to allocate wells to the corresponding huc10s
export delimited using "NM CO PA/PA/PA_list_ ALL non-H.csv", replace

// Import List of Wells w/ HUC10 Assignement
import delimited "NM CO PA/PA/PA_list_non_H_huc10.csv" , clear
drop x y tnmid metasource sourcedata sourceorig sourcefeat loaddate gnis_id name hutype humod

// Clean api10 ID
rename api10 api10_d
tostring api10_d, gen(api10)
drop api10_d
g api10_l = length(api10) 
replace api10 = "0" + api10 if api10_l ==9
drop api10_l 

// Clean HUC10 ID
tostring huc10, gen(huc10_s)
g huc10_l = length(huc10_s) 
replace huc10_s = "0" + huc10_s if huc10_l ==9
drop huc10_l

// Import Wells Details 
merge 1:1 api10 using "well_pa non H wells NOV 2019.dta", gen(_merge_well)
keep if _merge_well==3
drop _merge*

g year = substr(datadate_spud_s,6,4) // DEL LATER
g month_year = substr(datadate_spud_s,3,7) // DEL LATER
destring year, gen(year_fe)  // DEL LATER
egen group_month_year = group(month_year) // DEL LATER

egen group_huc10 = group(huc10_s) // DEL LATER
g huc8_s = substr(huc10_s,1,8) // DEL LATER
egen group_huc8 = group(huc8_s) // DEL LATER
g state_county_ID = substr(api10,1,5)

// Other Cleaning
drop region county farm_name municipali well_code_ configurat unconventi ///
shape_leng shape_area municipality well_code_desc well_statu

replace configuration ="D" if configuration=="Deviated Well"
replace configuration ="H" if configuration=="Horizontal Well"
replace configuration ="U" if configuration=="Undetermined"
replace configuration ="V" if configuration=="Vertical Well"

drop if m_datadate_spud<d(01jan2000)

// Import Shale & Basin Details
merge 1:1 api10 using "H_PA_shale_huc10_ID", gen(_merge_shale)
keep if _merge_shale == 3
drop _merge_shale

// cleaning state info
g state_api = substr(api10,1,2)
g STATE="PA"            if state_api=="37"

save "huc10_PADEP_ALL.dta", replace
