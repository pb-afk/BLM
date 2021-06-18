clear
set more off
global dir1 "C:\Users\pbonetti\Dropbox (IESE)\fracking wqs analysis\Fracking to clean"
cd "$dir1"

*************************************
* 1. CLEANING OF WATER QUALITY DATA *
*************************************

cd "$dir1"
do "do file/1.do"

***************************
* 2. CLEANING OF HF WELLS *
***************************

	***********************
	* 2.1.1. DrillingInfo *
	***********************

	***********************
	* 2.1.2. WellDatabase *
	***********************

	****************
	* 2.1.3. PADEP *
	****************

cd "$dir1"
do "do file/2.do"

***********************************************************
* 3. MERGE WATER DATA w/ PRECIPITATION / TEMPERATURE DATA *
***********************************************************

****************************************************
* 3.1.1 FURTHER CLEANING OF THE WATER QUALITY DATA *
****************************************************

cd "$dir1"
do "do file/3.do"

*********************
* 4. FINAL ASSEMBLY *
*********************

**************************
* 4.1. APPEND WELL FILES *
**************************

*******************************
* 4.2. merge PADEP, WD AND DI *
*******************************

*************************************************
* 4.3. Generate Cumulative well counts by HUC10 *
*************************************************

***********************************************************
* 4.4. Assembly HF wells data with the water quality data *
***********************************************************

***********************************************************
* 4.5 Create well count variables for Figure 3 (Table S8) *
***********************************************************

*****************************************************
* 4.6 Define final Sample For Figure 2 and Figure 3 *
*****************************************************

cd "$dir1"
do "do file/4.do"

********************
* 5. Paired-Sample *
********************

cd "$dir1"
do "do file/5.do"

*********************************
* Figure 2 Estimates [Table S4] *
*********************************

cd "$dir1"
do "do file/Figure 2 est_Table S4.do"

*********************************
* Figure 3 Estimates [Table S8] *
*********************************

cd "$dir1"
do "do file/Figure 3 est_Table S8.do"

**********************************
* Figure 4 Estimates [Table S12] *
**********************************

cd "$dir1"
do "do file/Figure 4 est_Table S12.do"

