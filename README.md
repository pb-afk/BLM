# Public Repository for "Large-Sample Evidence on the Impact of Unconventional Oil and Gas Development on Surface Water Quality"

To perform the analyses presented in the manuscript, we first merged raw data from several sources referenced in the Acknowledgements and Supplemental Materials. Data from WellDatabase and Enverus (formerly Drillinginfo) were obtained from these companies by license agreements for non-commercial use. The other data can be downloaded for free. The Stata code provided under 1) below produces two merged datasets based on which the analyses are performed. The Stata code provided under 4) below produces the estimates and tables, based on which we construct the figures presented in the manuscript. We used Stata MP – Parallel Edition 14.2 to perform the analyses.

The Github folder contains:

1) Stata code converting the raw data into the datasets 2) and 3) (“0.do” – “5.do”)

2) “id_geo_estimation_sample_T_spud_date_augmented_ALL_bis.dta”

 	- The analyses presented in Table S4 based on which we construct Figure 2 and Figure 3 are performed on this merged Stata dataset.
  
3) “paired_sample.dta”

	 - The analyses presented in Table S12 based on which we construct Figure 4 are performed using this merged Stata dataset.
  
4) Stata code performing the analyses based on the two merged datasets above, generating the Tables S4, S8 and S12 with the coefficient estimates used to compute the magnitudes reported in Figure 2, Figure 3, and Figure 4 (“Figure 2 est_Table S4.do”, “Figure 3 est_Table S8.do”, “Figure 4 est_Table S12.do”).

5) R code used to generate Figure 2 and Figure 4 (“Figures_2_and_4.R”)

6) Four Excel files with the inputs from the analyses above (“Figure 2 est_Table S4.do” and “Figure 4 est_Table S12.do”). We use these Excel files to compute the HUC10 impact estimates presented in Figure 2 and Figure 4.

 	- “Figure2.csv” and “Figure2_impact.csv”
  
	 - “Figure4.csv” and “Figure4_impact.csv”

The authors
