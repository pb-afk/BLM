*********************************
* Figure 3 Estimates [Table S8] *
*********************************

global dir1 "C:\Users\pbonetti\Dropbox (IESE)\fracking wqs analysis\Fracking to clean"

clear
set more off

cd "$dir1"

use "id_geo_estimation_sample_T_spud_date_augmented_ALL_bis.dta", clear

// In the main analyses, we use Ion Concentration V2 ["log_t_t_Value_clean2"]

* generating sample identifiers
local items 1 2 3 4
local Ys 2 // use V2
local errors ""cluster(huc8_fe)""
local fe ""ID_geo_feN""
foreach k of local items {
foreach y of local Ys {
foreach f of local fe {
foreach e of local errors {

reghdfe log_t_t_Value_clean`y' cum_well_H log_cum_prec_3days i.T_mean_D_5_groups if group_items == `k' & m_cum_well_huc10_H>0, `e' absorb(`f')
g sample_`k'_`y'_base = e(sample)

}
}
}
}


* gen count of # obs. per Ion-huc8-year-month
local items  1 2 3 4
local Ys 2
foreach k of local items {
foreach y of local Ys {
bysort huc10_s CharacteristicName date_string_year date_string_month sample_`k'_`y'_base: gen weights_huc10_s`k'`y' = _N if log_t_t_Value_clean`y'!=.
bysort huc8_s CharacteristicName  date_string_year date_string_month sample_`k'_`y'_base: gen weights_huc8_s`k'`y' = _N if log_t_t_Value_clean`y'!=.
bysort huc4_s CharacteristicName  date_string_year date_string_month sample_`k'_`y'_base: gen weights_huc4_s`k'`y' = _N if log_t_t_Value_clean`y'!=.
replace weights_huc10_s`k'`y' = 0 if weights_huc10_s`k'`y' == .
replace weights_huc8_s`k'`y' =  0 if weights_huc8_s`k'`y'  == .
replace weights_huc4_s`k'`y' =  0 if weights_huc4_s`k'`y'  == . 
}
}


* Regressions to generate Figure 3 (Table S8) estimates

local items  1 2 3 4
local Ys 2
local errors ""cluster(huc8_fe)""
local fe ""ID_geo_feN""
foreach k of local items {
foreach y of local Ys {
foreach f of local fe {
foreach e of local errors {

local t future_H_91_180 future_H_0_90 within_H_1_90 within_H_91_180 within_H_181_360 within_H_361_1000000

	// 2 base w/ HUC8
	reghdfe log_t_t_Value_clean`y' `t' log_cum_prec_3days i.T_mean_D_5_groups  if group_items == `k' & m_cum_well_huc10_H>0 & StateCode=="42" & weights_huc8_s`k'`y'>=2 , `e' absorb(`f' huc8_year_month_fe)
	outreg2 using TabS8`k'Value`y'`e'`f'.xls, /// * Variables you want to display
	title ("ATE - `k' - Value `y'") ctitle("Only Treated") ///
	bracket bdec (5) sdec(5) replace ///
	addtext(Sample, PA - huc8 with at least 2 obs., Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)
	// 4 base w/ HUC8
	reghdfe log_t_t_Value_clean`y' `t' log_cum_prec_3days i.T_mean_D_5_groups  if group_items == `k' & m_cum_well_huc10_H>0 & weights_huc8_s`k'`y'>=2, `e' absorb(`f' huc8_year_month_fe)
	outreg2 using TabS8`k'Value`y'`e'`f'.xls, /// * Variables you want to display
	title ("ATE - `k' - Value `y'") ctitle("Only Treated") ///
	bracket bdec (5) sdec(5) append ///
	addtext(Sample, All - huc8 with at least 2 obs., Weather Controls, Yes, Monitoring FE, Yes, HUC8*Month*Year FE, Yes)


}
}
}
}


// Prepare the Data for Fig. 3
local K 1 2 3 4
local B _bis
local G spud_date_augmented
foreach k of local K {
foreach b of local B {
foreach g of local G {

import delimited "TabS8`k'Value2cluster(huc8_fe)ID_geo_feN.txt", clear

drop in 1/3
drop in 14/32

replace v1 = "se_future_H_91_180" in 3
replace v1 = "se_future_H_0_90" in 5
replace v1 = "se_within_H_1_90" in 7
replace v1 = "se_within_H_91_180" in 9
replace v1 = "se_within_H_181_360" in 11
replace v1 = "se_within_H_361_1000000" in 13
g flag = substr(v1,1,2)

forval i = 2/3 {
replace v`i' = subinstr(v`i', "]", "",.) 
replace v`i' = subinstr(v`i', "[", "",.) 
replace v`i' = subinstr(v`i', "*", "",.) 
}
//

forval i = 2/3 {
destring v`i', replace
}
//

rename v1 dummy
forval i = 2/3 {

g v`i'_se =.
replace v`i'_se = v`i' if flag=="se"
replace v`i'_se = v`i'_se[_n+1] if v`i'_se==. & v`i'_se[_n+1]!=. & (flag=="fu" | flag=="wi") & flag[_n+1]=="se"
}
//

drop if flag=="se"
replace dummy = "base" in 1

forval i = 2/3 {
replace v`i' = 0 in 1
replace v`i'_se = 0 in 1
}
//

g time_first = 0 if dummy=="within_H_1_90"
replace time_first =1 if dummy=="within_H_91_180" 
replace time_first =2 if dummy=="within_H_181_360" 
replace time_first =3 if dummy=="within_H_361_1000000" 
replace time_first =-1 if dummy=="future_H_0_90" 
replace time_first =-2 if dummy=="future_H_91_180" 
replace time_first =-3 if dummy=="base" 

sort time_first
save "data_MA_`g'`b'_`k'", replace
clear

}
}
}


graph drop _all 

***********
* Bromide *
***********
local B ""_bis""
local G  spud_date_augmented
foreach g of local G {
foreach b of local B {

use "data_MA_`g'`b'_2.dta", clear

set obs 8
replace dummy = "Table_1" in 8

forval i = 2/3 {
replace v`i' = 0.00020  in 8  
replace v`i'_se = 0.00040  in 8 
}
//

forval i = 2/3 {
g int_v`i'down = v`i' + - invttail(72,0.025)*v`i'_se
g int_v`i'up = v`i' + invttail(72,0.025)*v`i'_se
}
//
//
 replace time_first =4 if dummy=="Table_1" 
// //
local i 2
local t first
mylabels -0.010(0.005)0.025, format(%04.3f) clean local(labels)
twoway (rspike int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium)  mcolor(black)) ///
(rcap int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium) mcolor(black)) ///
(scatter v`i' time_`t' if time_`t' < 4, sort lc(black) lp(shortdash) msize(medium) mfcolor(white) mlcolor(black) mlwidth(medium) lwidth(medium) msymbol(circle) ) /// 
 (scatter v`i' time_`t' if time_`t' == 4 , sort lc(black) lp(shortdash) msize(medium) mfcolor(maroon) mlcolor(black) mlwidth(vthin) lwidth(medium) msymbol(circle) ) , ///
yline(0, lwidth(thin) lc(black)) ///
xline(3.5, lwidth(thin) lc(black) lp(dash) ) ///
text( 0.025 -3 "A", placement(c) margin(l+1 t+1 b+1 r+1) fcolor(white) ) ///
ylabel(`labels', labsize(small) nogrid    angle(horizontal)   ) ytick(#10)  /// format(%04.3f)
yscale(range(-0.010(0.005)0.025)) ///
ytitle("Bromide (ug/l)", size(small) height(3))  ///
xtitle("Time window", size(small) height(6)) ///
xlabel(#7,labsize(small)) ///
xlabel(-3 "<-180" -2 "[-180, -91]"  -1 "[-90, 0]"  0 "[1, 90]"  1 "[91, 180]"  2 "[181, 360]" 3 ">360" 4 "Avg. Est.") ///
plotregion(margin(5 7 2 2)) graphregion(margin(3 3 2 2))  ///
legend(off) scheme(sj) graphregion(c(white) fcolor(white)) name(gg1)
graph display, ysize(2.6) xsize(4.2)
graph  export "Bromide_`g'`b'_model 10.pdf", as(pdf) replace

local i 3
local t first
mylabels -0.015(0.005)0.02, format(%04.3f) clean local(labels)
twoway (rspike int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium)  mcolor(black)) ///
(rcap int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium) mcolor(black)) ///
(scatter v`i' time_`t' if time_`t' < 4, sort lc(black) lp(shortdash) msize(medium) mfcolor(white) mlcolor(black) mlwidth(medium) lwidth(medium) msymbol(circle) ) /// 
 (scatter v`i' time_`t' if time_`t' >= 4 , sort lc(black) lp(shortdash) msize(medium) mfcolor(maroon) mlcolor(black) mlwidth(vthin) lwidth(medium) msymbol(circle) ) , ///  (pcarrowi  0.01 3 0.0005 3.90 (12) "For comparison") 
yline(0, lwidth(thin) lc(black)) /// 
xline(3.5, lwidth(thin) lc(black) lp(dash) ) ///
text( 0.02 -3 "A", placement(c) margin(l+1 t+1 b+1 r+1) fcolor(white) ) ///
ylabel(`labels', labsize(small) nogrid    angle(horizontal)   ) ytick(#10)  /// format(%04.3f)
yscale(range(-0.015(0.005)0.02)) ///
ytitle("Bromide (ug/l)", size(small) height(3))  ///
xtitle("Time window", size(small) height(6)) ///
xlabel(#7,labsize(small)) ///
xlabel(-3 "<-180" -2 "[-180, -91]"  -1 "[-90, 0]"  0 "[1, 90]"  1 "[91, 180]"  2 "[181, 360]" 3 ">360" 4 "Avg. Est.") ///
plotregion(margin(5 7 2 2)) graphregion(margin(3 3 2 2))  ///
legend(off) scheme(sj) graphregion(c(white) fcolor(white)) name(g1)

graph display, ysize(2.6) xsize(4.2)
graph  export "Bromide_`g'`b'_model 12.pdf", as(pdf) replace
}
}

************
* Chloride *
************
local B ""_bis""
local G  spud_date_augmented
foreach g of local G {
foreach b of local B {

use "data_MA_`g'`b'_3.dta", clear

set obs 8
replace dummy = "Table_1" in 8

forval i = 2/3 {
replace v`i' = 0.00056  in 8
replace v`i'_se = 0.00030  in 8
}
//

forval i = 2/3 {
g int_v`i'down = v`i' + - invttail(72,0.025)*v`i'_se
g int_v`i'up = v`i' + invttail(72,0.025)*v`i'_se
}
//

replace time_first =4 if dummy=="Table_1" 

local i 2
local t first
mylabels -0.01(0.002)0.008, format(%04.3f) clean local(labels)
twoway (rspike int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium)  mcolor(black)) ///
(rcap int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium) mcolor(black)) ///
(scatter v`i' time_`t' if time_`t' < 4, sort lc(black) lp(shortdash) msize(medium) mfcolor(white) mlcolor(black) mlwidth(medium) lwidth(medium) msymbol(circle) ) /// 
 (scatter v`i' time_`t' if time_`t' == 4 , sort lc(black) lp(shortdash) msize(medium) mfcolor(maroon) mlcolor(black) mlwidth(vthin) lwidth(medium) msymbol(circle) ) , ///
yline(0, lwidth(thin) lc(black)) ///
xline(3.5, lwidth(thin) lc(black) lp(dash) ) ///
text( 0.008 -3 "B", placement(c) margin(l+1 t+1 b+1 r+1) fcolor(white) ) ///
ylabel(`labels', labsize(small) nogrid    angle(horizontal)   ) ytick(#10)  /// format(%04.3f)
yscale(range(-0.010(0.002)0.008)) ///
ytitle("Chloride (ug/l)", size(small) height(3))  ///
xtitle("Time window", size(small) height(6)) ///
xlabel(#7,labsize(small)) ///
xlabel(-3 "<-180" -2 "[-180, -91]"  -1 "[-90, 0]"  0 "[1, 90]"  1 "[91, 180]"  2 "[181, 360]" 3 ">360" 4 "Avg. Est.") ///
plotregion(margin(5 7 2 2)) graphregion(margin(3 3 2 2))  ///
legend(off) scheme(sj) graphregion(c(white) fcolor(white))  name(gg2)
graph display, ysize(2.6) xsize(4.2)
graph  export "Chloride_`g'`b'_model 10.pdf", as(pdf) replace

local i 3
local t first
mylabels -0.015(0.005)0.02, format(%04.3f) clean local(labels)
twoway (rspike int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium)  mcolor(black)) ///
(rcap int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium) mcolor(black)) ///
(scatter v`i' time_`t' if time_`t' < 4, sort lc(black) lp(shortdash) msize(medium) mfcolor(white) mlcolor(black) mlwidth(medium) lwidth(medium) msymbol(circle) ) /// 
 (scatter v`i' time_`t' if time_`t' == 4 , sort lc(black) lp(shortdash) msize(medium) mfcolor(maroon) mlcolor(black) mlwidth(vthin) lwidth(medium) msymbol(circle) ) , ///
yline(0, lwidth(thin) lc(black)) ///
xline(3.5, lwidth(thin) lc(black) lp(dash) ) ///
text( 0.02 -3 "B", placement(c) margin(l+1 t+1 b+1 r+1) fcolor(white) ) ///
ylabel(`labels', labsize(small) nogrid    angle(horizontal)   ) ytick(#10)  /// format(%04.3f)
yscale(range(-0.015(0.005)0.02)) ///
ytitle("Chloride (ug/l)", size(small) height(3))  ///
xtitle("Time window", size(small) height(6)) ///
xlabel(#7,labsize(small)) ///
xlabel(-3 "<-180" -2 "[-180, -91]"  -1 "[-90, 0]"  0 "[1, 90]"  1 "[91, 180]"  2 "[181, 360]" 3 ">360" 4 "Avg. Est.") ///
plotregion(margin(5 7 2 2)) graphregion(margin(3 3 2 2))  ///
legend(off) scheme(sj) graphregion(c(white) fcolor(white)) name(g2) 
graph display, ysize(2.6) xsize(4.2)
graph  export "Chloride_`g'`b'_model 12.pdf", as(pdf) replace
}
}


**********
* Barium *
**********
local B ""_bis""
local G  spud_date_augmented 
foreach g of local G {
foreach b of local B {

use "data_MA_`g'`b'_1.dta", clear

set obs 8
replace dummy = "Table_1" in 8

forval i = 2/3 {
replace v`i' = 0.00023  in 8 
replace v`i'_se = 0.00015  in 8  
}
//

forval i = 2/3 {
g int_v`i'down = v`i' + - invttail(72,0.025)*v`i'_se
g int_v`i'up = v`i' + invttail(72,0.025)*v`i'_se
}
//

replace time_first =4 if dummy=="Table_1" 

local i 2
local t first
mylabels -0.008(0.002)0.008, format(%04.3f) clean local(labels)
twoway (rspike int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium)  mcolor(black)) ///
(rcap int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium) mcolor(black)) ///
(scatter v`i' time_`t' if time_`t' < 4, sort lc(black) lp(shortdash) msize(medium) mfcolor(white) mlcolor(black) mlwidth(medium) lwidth(medium) msymbol(circle) ) /// 
 (scatter v`i' time_`t' if time_`t' == 4 , sort lc(black) lp(shortdash) msize(medium) mfcolor(maroon) mlcolor(black) mlwidth(vthin) lwidth(medium) msymbol(circle) ) , ///
yline(0, lwidth(thin) lc(black)) ///
xline(3.5, lwidth(thin) lc(black) lp(dash) ) ///
text( 0.008 -3 "C", placement(c) margin(l+1 t+1 b+1 r+1) fcolor(white) ) ///
ylabel(`labels', labsize(small) nogrid    angle(horizontal)   ) ytick(#10)  /// format(%04.3f)
yscale(range(-0.008(0.002)0.008)) ///
ytitle("Barium (ug/l)", size(small) height(3))  ///
xtitle("Time window", size(small) height(6)) ///
xlabel(#7,labsize(small)) ///
xlabel(-3 "<-180" -2 "[-180, -91]"  -1 "[-90, 0]"  0 "[1, 90]"  1 "[91, 180]"  2 "[181, 360]" 3 ">360" 4 "Avg. Est.") ///
plotregion(margin(5 7 2 2)) graphregion(margin(3 3 2 2))  ///
legend(off) scheme(sj) graphregion(c(white) fcolor(white))  name(gg3)
graph display, ysize(2.6) xsize(4.2)
graph  export "Barium_`g'`b'_model 10.pdf", as(pdf) replace

local i 3
local t first
mylabels -0.008(0.002)0.008, format(%04.3f) clean local(labels)
twoway (rspike int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium)  mcolor(black)) ///
(rcap int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium) mcolor(black)) ///
(scatter v`i' time_`t' if time_`t' < 4, sort lc(black) lp(shortdash) msize(medium) mfcolor(white) mlcolor(black) mlwidth(medium) lwidth(medium) msymbol(circle) ) /// 
 (scatter v`i' time_`t' if time_`t' == 4 , sort lc(black) lp(shortdash) msize(medium) mfcolor(maroon) mlcolor(black) mlwidth(vthin) lwidth(medium) msymbol(circle) ) , ///
yline(0, lwidth(thin) lc(black)) ///
xline(3.5, lwidth(thin) lc(black) lp(dash) ) ///
text( 0.008 -3 "C", placement(c) margin(l+1 t+1 b+1 r+1) fcolor(white) ) ///
ylabel(`labels', labsize(small) nogrid    angle(horizontal)   ) ytick(#10)  /// format(%04.3f)
yscale(range(-0.008(0.002)0.008)) ///
ytitle("Barium (ug/l)", size(small) height(3))  ///
xtitle("Time window", size(small) height(6)) ///
xlabel(#7,labsize(small)) ///
xlabel(-3 "<-180" -2 "[-180, -91]"  -1 "[-90, 0]"  0 "[1, 90]"  1 "[91, 180]"  2 "[181, 360]" 3 ">360" 4 "Avg. Est.") ///
plotregion(margin(5 7 2 2)) graphregion(margin(3 3 2 2))  ///
legend(off) scheme(sj) graphregion(c(white) fcolor(white)) name(g3)
graph display, ysize(2.6) xsize(4.2)
graph  export "Barium_`g'`b'_model 12.pdf", as(pdf) replace
}
}
 
*************
* Strontium *
*************
local B ""_bis""
local G  spud_date_augmented 
foreach g of local G {
foreach b of local B {

use "data_MA_`g'`b'_4.dta", clear

set obs 8
replace dummy = "Table_1" in 8

forval i = 2/3 {
replace v`i' = 0.00036  in 8  
replace v`i'_se = 0.00008  in 8  
}
//

forval i = 2/3 {
g int_v`i'down = v`i' + - invttail(72,0.025)*v`i'_se
g int_v`i'up = v`i' + invttail(72,0.025)*v`i'_se
}
//

replace time_first =4 if dummy=="Table_1" 

local i 2
local t first
mylabels -0.008(0.002)0.008, format(%04.3f) clean local(labels)
twoway (rspike int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium)  mcolor(black)) ///
(rcap int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium) mcolor(black)) ///
(scatter v`i' time_`t' if time_`t' < 4, sort lc(black) lp(shortdash) msize(medium) mfcolor(white) mlcolor(black) mlwidth(medium) lwidth(medium) msymbol(circle) ) /// 
 (scatter v`i' time_`t' if time_`t' == 4 , sort lc(black) lp(shortdash) msize(medium) mfcolor(maroon) mlcolor(black) mlwidth(vthin) lwidth(medium) msymbol(circle) ) , ///
yline(0, lwidth(thin) lc(black)) ///
xline(3.5, lwidth(thin) lc(black) lp(dash) ) ///
text( 0.008 -3 "D", placement(c) margin(l+1 t+1 b+1 r+1) fcolor(white) ) ///
ylabel(`labels', labsize(small) nogrid    angle(horizontal)   ) ytick(#10)  /// format(%04.3f)
yscale(range(-0.008(0.002)0.008)) ///
ytitle("Strontium (ug/l)", size(small) height(3))  ///
xtitle("Time window", size(small) height(6)) ///
xlabel(#7,labsize(small)) ///
xlabel(-3 "<-180" -2 "[-180, -91]"  -1 "[-90, 0]"  0 "[1, 90]"  1 "[91, 180]"  2 "[181, 360]" 3 ">360" 4 "Avg. Est.") ///
plotregion(margin(5 7 2 2)) graphregion(margin(3 3 2 2))  ///
legend(off) scheme(sj) graphregion(c(white) fcolor(white)) name(gg4)
graph display, ysize(2.6) xsize(4.2)
graph  export "Strontium_`g'`b'_model 10.pdf", as(pdf) replace

local i 3
local t first
mylabels -0.008(0.002)0.008, format(%04.3f) clean local(labels)
twoway (rspike int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium)  mcolor(black)) ///
(rcap int_v`i'down int_v`i'up time_`t', sort msize(medium) mlwidth(medium) lwidth(medium) mcolor(black)) ///
(scatter v`i' time_`t' if time_`t' < 4, sort lc(black) lp(shortdash) msize(medium) mfcolor(white) mlcolor(black) mlwidth(medium) lwidth(medium) msymbol(circle) ) /// 
 (scatter v`i' time_`t' if time_`t' == 4 , sort lc(black) lp(shortdash) msize(medium) mfcolor(maroon) mlcolor(black) mlwidth(vthin) lwidth(medium) msymbol(circle) ) , ///
yline(0, lwidth(thin) lc(black)) ///
xline(3.5, lwidth(thin) lc(black) lp(dash) ) ///
text( 0.008 -3 "D", placement(c) margin(l+1 t+1 b+1 r+1) fcolor(white) ) ///
ylabel(`labels', labsize(small) nogrid    angle(horizontal)   ) ytick(#10)  /// format(%04.3f)
yscale(range(-0.008(0.002)0.008)) ///
ytitle("Strontium (ug/l)", size(small) height(3))  ///
xtitle("Time window", size(small) height(6)) ///
xlabel(#7,labsize(small)) ///
xlabel(-3 "<-180" -2 "[-180, -91]"  -1 "[-90, 0]"  0 "[1, 90]"  1 "[91, 180]"  2 "[181, 360]" 3 ">360" 4 "Avg. Est.") ///
plotregion(margin(5 7 2 2)) graphregion(margin(3 3 2 2))  ///
legend(off) scheme(sj) graphregion(c(white) fcolor(white))  name(g4)
graph display, ysize(2.6) xsize(4.2)
graph  export "Strontium_`g'`b'_model 12.pdf", as(pdf) replace
}
}


graph combine gg1 gg2 gg3 gg4, graphregion(c(white) fcolor(white)) xcommon  iscale(.6)
graph display, ysize(10.4) xsize(16.8)
graph  export "Combined_Updated_NEW3b_`g'`b'_model 10.pdf", as(pdf) replace

graph combine g1 g2 g3 g4, graphregion(c(white) fcolor(white)) xcommon  iscale(.6)
graph display, ysize(10.4) xsize(16.8)
graph  export "Combined_Updated_NEW3b_`g'`b'_model 12.pdf", as(pdf) replace
