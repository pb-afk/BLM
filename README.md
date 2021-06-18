# Public Repository for "Large-Sample Evidence on the Impact of Unconventional Oil and Gas Development on Surface Waters"

To perform the analyses presented in the manuscript, we first merged and processed data from several sources referenced in the Acknowledgements and Supplemental Materials. The data from WellDatabase and Enverus (formerly Drillinginfo) were obtained from these companies via license agreements for non-commercial use. The other raw data were downloaded from the respective sources for free. The Stata code in (1) produces two merged datasets (2) and (3), based on which the analyses are performed. The Stata code in (4) produces the tables and coefficient estimates, based on which we construct the figures presented in the manuscript. We used Stata MP – Parallel Edition 14.2 to perform the analyses.

The directory additional_materials contains:

1) Stata code that converts the raw data into the merged datasets (2) and (3): “0.do” – “5.do”

2) Merged Stata dataset: “id_geo_estimation_sample_T_spud_date_augmented_ALL_bis.dta”

 	- The analyses presented in Table S4 and Table S8 based on which we construct Figure 2 and Figure 3 are performed using this dataset.
  
3) Merged Stata dataset (zipped): “paired_sample.dta”

	- The analyses presented in Table S12 based on which we construct Figure 4 are performed using this dataset.
  
4) Stata code that uses the two merged datasets (2) and (3) to generate the main tables and corresponding figures: “Figure 2 est_Table S4.do”, “Figure 3 est_Table S8.do”, “Figure 4 est_Table S12.do”

	- The estimates in Tables S4, S8 and S12 are used to construct Figures 2, 3 and 4.

5) R code that generates Figure 2 and Figure 4 (“Figures_2_and_4.R”). Figure 3 is produced in Stata.

6) Four Excel files with the inputs from the analyses above (“Figure 2 est_Table S4.do” and “Figure 4 est_Table S12.do”): “Figure2.csv”, “Figure2_impact.csv”, “Figure4.csv”, “Figure4_impact.csv”

 	- We use these Excel files to compute the HUC10 impact estimates presented in Figure 2 and Figure 4.


The authors


Pietro Bonetti, Christian Leuz, Giovanna Michelon
