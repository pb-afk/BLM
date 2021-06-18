#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#

#%%%%%%%%%%%%%%%   UChicago    %%%%%%%%%%%%%%%#     
#%%%%%%%%%%%%       Booth          %%%%%%%%%%%#                   
#%%%%%%%%%%%                       %%%%%%%%%%%#
#%%%%%%%  Programmer: Igor Kuznetsov   %%%%%%%#

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%# 
# R version 4.0.3 (2020-10-10) 
# Platform: x86_64-w64-mingw32/x64 (64-bit)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%# 


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%# 
# PURPOSE:
#   1) Create Figures 2 & 4 as forest plots 
#     combining tables and box plots 
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%# 


##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
######### Step 0. Environment setup ######### 
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


rm(list = ls())
set.seed(17)

# set wd to data location
setwd("C:/Users/pbonetti/Dropbox (IESE)/fracking wqs analysis/Fracking to clean")

# options(error = utils::recover)
options(error = NULL)
options(scipen=999)  # turn off scientific notation like 1e+06
options(digits=10) #  controls the number of significant

# Install all packages needed to run this example
# Packages used: 
# data.table v. 1.13.4
# tidyverse v. 1.3.0
# RColorBrewer v. 1.1-2
# forestplot v. 1.10.1
PackageList =c('data.table','tidyverse','RColorBrewer','forestplot')
NewPackages=PackageList[!(PackageList %in% 
                            installed.packages()[,"Package"])]
if(length(NewPackages)) install.packages(NewPackages,repos = "http://cran.us.r-project.org")
lapply(PackageList,require,character.only=TRUE)#array function


`%notin%` <- Negate(`%in%`)


##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
####    Step 1 Loading data #######
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


dt1 <- fread("/data figures/Figure2.csv")
setDT(dt1)

dt1imp <- fread("/data figures/Figure2_impact.csv")
setDT(dt1imp)


dtt3 <- fread("/data figures/Figure4.csv")
setDT(dtt3)

dt3imp <- fread("/data figures/Figure4_impact.csv",
                colClasses = c("character", "character", "numeric", "numeric"),  stringsAsFactors = FALSE)
setDT(dt3imp)



##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
####    Step 2 Processing data for Fig 2   #######
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


dt5 <- setNames(data.table(matrix(nrow = 0, ncol = 10)), c("chem","mean", "lower","upper", "sd", "rsquared",
                                                          "size","source","model","modelhuc"))


  for (i in seq(3,15,4)) {
  for (i2 in c(1,2)) {
    for (i1 in c("pa", "all")) {
    j = i-2
      k = i -1
      f = i+1
      aa <- c(paste0("model_",i1,"_",i2))
      dtpa <- data.table(chem=dt1[i,chem],
                         mean =  dt1[j, .SD , .SDcols = aa][[1]] * 1000,
                         lower =  (dt1[j, .SD , .SDcols = aa][[1]] -  1.65 * dt1[k, .SD , .SDcols = aa][[1]]) * 1000,
                         upper =  (dt1[j, .SD , .SDcols = aa][[1]] +  1.65 * dt1[k, .SD , .SDcols = aa][[1]]) * 1000,
                         sd = dt1[k, .SD , .SDcols = aa][[1]],
                         rsquared = dt1[f, .SD , .SDcols = aa][[1]],
                         size = dt1[i, .SD , .SDcols = aa][[1]],
                         source = paste0(i1,"_",i2),
                         modelhuc = i2,
                         model = i1)
      dt5 <- rbind(dt5,dtpa )
    }
  }
}


dt5imp <- setNames(data.table(matrix(nrow = 0, ncol = 8)), c("chem","impact_mean","impact_median", 
                                                              "concentration_mean","concentration_median",
                                                             "well_n_mean","well_n_median","source"))

for (i in seq(1,19,6)) {
  for (i2 in c(1,2)) {
    for (i1 in c("pa", "all")) {
      aa <- c(paste0("model_",i1,"_",i2))
      dtpa <- data.table(chem=dt1imp[i,chem],
                         impact_mean =  dt1imp[i, .SD , .SDcols = aa][[1]],
                         impact_median =  dt1imp[i+1, .SD , .SDcols = aa][[1]],
                         concentration_mean =  dt1imp[i+2, .SD , .SDcols = aa][[1]],
                         concentration_median = dt1imp[i+3, .SD , .SDcols = aa][[1]],
                         well_n_mean = dt1imp[i+4, .SD , .SDcols = aa][[1]],
                         well_n_median = dt1imp[i+5, .SD , .SDcols = aa][[1]],
                         source = paste0(i1,"_",i2) )
      dt5imp <- rbind(dt5imp,dtpa )
    }
  }
}


dt5 <- merge(dt5,dt5imp, by=c("chem","source" ))  # [,.(chem,source,impact_mean,concentration_mean)]

dt5[model == "pa" , model:="PA"]
dt5[model == "all" , model:="ALL"]

dt5[,chem2 := factor(chem,levels = c('Bromide','Chloride','Barium','Strontium'), 
                     labels=c('Bromide','Chloride','Barium','Strontium')) ]

setorder(dt5, chem2, -model, modelhuc)

cols = c("impact_mean","impact_median", "concentration_mean","concentration_median","well_n_mean","well_n_median")
dt5[,(cols) := lapply(.SD, function(x) round(x,2)),  .SDcols= cols ]


dt5_1 <-  dt5[modelhuc == 1,.(chem,model, mean,lower,upper,rsquared, impact_mean,impact_median) ]
dt5_2 <-  dt5[modelhuc == 2,.(chem,model, mean,lower,upper,rsquared,impact_mean,impact_median, 
                              concentration_mean,concentration_median,well_n_mean,well_n_median) ]
setnames(dt5_1, c("impact_mean","impact_median") ,    
         c("impact_mean4","impact_median4")  )

setnames(dt5_2, c("mean"  , "lower" , "upper"    , "chem"   ,"model","rsquared",
                  "impact_mean","impact_median", "concentration_mean","concentration_median","well_n_mean","well_n_median") , 
         c("mean_2"  , "lower_2" , "upper_2", "chem_2",  "model_2" ,"rsquared_2",
           "impact_mean8","impact_median8", "concentration_mean8","concentration_median8","well_n_mean8","well_n_median8") )

dt5_1 <- merge(dt5_1,dt5_2, by.x=c("chem"   ,"model"), by.y=c("chem_2",  "model_2"), sort = FALSE )


dt5_bold <- dt5_1[,.(chem, model, lower, lower_2) ]

dt5_bold[ ,':='(impact_mean4 =lower , impact_mean8 =lower_2) ]


dt5_bold_median <- dt5_1[,.(chem, model, lower, lower_2) ]

dt5_bold_median[ ,':='(impact_median4 =lower , impact_median8 =lower_2) ]


dt5_beta <- rbind(data.table(mean = c(NA,NA)  , lower = c(NA,NA), upper    = c(NA,NA),
                             mean_2 = c(NA,NA) , lower_2 = c(NA,NA), upper_2= c(NA,NA), chem  = c(NA,NA) ,
                             model=c(NA,NA), impact_mean4 = c(NA,NA),  impact_mean8 = c(NA,NA)),
                  dt5_1[,.(mean,lower,upper,mean_2,lower_2,upper_2,chem,model,impact_mean4,impact_mean8 )] )


cols = c( "mean","lower","upper","rsquared","impact_mean4" ,"impact_median4",
          "mean_2", "lower_2", "upper_2", "rsquared_2", "impact_mean8", "impact_median8",
          "concentration_mean8" , "concentration_median8", "well_n_mean8" , "well_n_median8"   )
dt5_1[,(cols) := lapply(.SD, function(x) as.character( formatC(round(x,2), format="f",digits=2, big.mark=",") )),  .SDcols= cols ]


##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
####    Step 3 Generating Fig 2   #######
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


dt5_bold_concentration <- copy(dt5_bold[,c("chem"   ,  "model" ,  "impact_mean4" ,"impact_mean8"  )])
dt5_bold_concentration[,  ":="(concentration_mean8 =100000, well_n_mean8 =100000  ) ]
setcolorder(dt5_bold_concentration, c("chem"   ,  "model" ,"concentration_mean8" , "well_n_mean8",  "impact_mean4" ,"impact_mean8"  ))

dt5_bold_concentration <-  lapply(as.data.frame(t(as.matrix(dt5_bold_concentration))),function(x) fifelse(as.numeric(x) >=0 & as.numeric(x) <10000,
                                                                                            list(gpar(fontface = "bold")), list(gpar(fontface = "plain")), 
                                                                                            na = list(gpar(fontface = "plain"))) )

tabletext_concentration  <-  rbind( data.table( chem=c(NA,"Ions"),model =c(NA,"Sample"),
                                                concentration_mean8 = c(NA,"Mean Concentration"),
                                                well_n_mean8 = list(NA,expression(bold("Cum. #") ~ bold("Wells") ) ),
                                                impact_mean4 = list(NA,expression("HUC4 Model"))  ,
                                                impact_mean8 = list(NA,expression("HUC8 Model") ) ),
                             dt5_1[, .(chem,model,concentration_mean8,well_n_mean8, impact_mean4,impact_mean8)]   )


setcolorder(tabletext_concentration, c("chem","model","concentration_mean8","well_n_mean8","impact_mean4","impact_mean8" ))

tabletext_concentration[, gr1:=seq(1,.N), by = chem  ]
tabletext_concentration[gr1 == 2,chem:="" ]
tabletext_concentration[,gr1 := NULL ]

xticks <-  seq(-1.5, 2, 0.5)
xtlab <- rep(c(TRUE,TRUE), length.out = length(xticks))
attr(xticks, "labels") <- xtlab

pdf(file = 'Fig2.pdf', paper = "USr", width = 10) 
plot.new()
forestplot(tabletext_concentration, 
           graph.pos = 4,
           mean = cbind(dt5_beta$mean,dt5_beta$mean_2), 
           lower = cbind(dt5_beta$lower, dt5_beta$lower_2),
           upper = cbind(dt5_beta$upper, dt5_beta$upper_2),
           hrzl_lines = list("3" = gpar(lty = 1)), 
           is.summary = c(TRUE,TRUE,rep(FALSE,8)),
           graphwidth = unit(55,"mm"),
           lineheight=unit(1.5,"cm"),
           colgap = unit(5,"mm"),
           txt_gp = fpTxtGp(label = dt5_bold_concentration ,ticks=gpar(cex=0.75),xlab=gpar(cex=0.75)),
           boxsize = 0.2,
           line.margin = .25,
           fn.ci_norm = c(fpDrawCircleCI, fpDrawCircleCI),
           clip = c(-2, 4),
           vertices = TRUE,
           xticks = xticks ,
           col = fpColors(box = c("darkred", "red2"),
                          line = c("black", "black")),
           xlab = expression("Coefficient estimates x" ~ 10^3))

legend(x = 0.33, y = 0.10,
       legend= c(expression(beta  ~ "(HUC4)"), expression(beta  ~ "(HUC8)")),
       box.lwd=2,cex = 0.75, pt.cex = 1.6, y.intersp=1.4,
       col=c("darkred", "red2"), pch=16,bty = "n") 

grid.text(expression(bold("HUC10 Impact" ~ (mu*g/l) )), .87, .85, gp = gpar(fontsize=13, font = 4))
dev.off() 




##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
####    Step 4 Processing data for Fig 4   #######
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


dt7 <- setNames(data.table(matrix(nrow = 0, ncol = 8)), c("chem","mean", "lower","upper", "sd", "rsquared",
                                                           "size","model"))


for (i in seq(3,15,4)) {
    for (i1 in c("pa", "all")) {
      j = i-2
      k = i -1
      f = i+1
      aa <- c(paste0("model_",i1,"_1"))
      dtpa <- data.table(chem=dtt3[i,chem],
                         mean =  dtt3[j, .SD , .SDcols = aa][[1]] * 1000,
                         lower =  (dtt3[j, .SD , .SDcols = aa][[1]] -  1.65 * dtt3[k, .SD , .SDcols = aa][[1]]) * 1000,
                         upper =  (dtt3[j, .SD , .SDcols = aa][[1]] +  1.65 * dtt3[k, .SD , .SDcols = aa][[1]]) * 1000,
                         sd = dtt3[k, .SD , .SDcols = aa][[1]],
                         rsquared = dtt3[f, .SD , .SDcols = aa][[1]],
                         size = dtt3[i, .SD , .SDcols = aa][[1]],
                         model = i1)
      dt7 <- rbind(dt7,dtpa )
    }
  }



dt7imp <- setNames(data.table(matrix(nrow = 0, ncol = 8)), c("chem","impact_mean","impact_median", 
                                                             "concentration_mean","concentration_median",
                                                             "well_n_mean","well_n_median","model"))

for (i in seq(1,19,6)) {
    for (i1 in c("pa", "all")) {
      aa <- c(paste0("model_",i1))
      dtpa <- data.table(chem=dt3imp[i,chem],
                         impact_mean =  dt3imp[i, .SD , .SDcols = aa][[1]],
                         impact_median =  dt3imp[i+1, .SD , .SDcols = aa][[1]],
                         concentration_mean =  dt3imp[i+2, .SD , .SDcols = aa][[1]],
                         concentration_median = dt3imp[i+3, .SD , .SDcols = aa][[1]],
                         well_n_mean = dt3imp[i+4, .SD , .SDcols = aa][[1]],
                         well_n_median = dt3imp[i+5, .SD , .SDcols = aa][[1]],
                         model = i1 )
      dt7imp <- rbind(dt7imp,dtpa )
    }
  }



dt7 <- merge(dt7,dt7imp, by=c("chem","model" ))  # [,.(chem,source,impact_mean,concentration_mean)]

dt7[model == "pa" , model:="PA"]
dt7[model == "all" , model:="ALL"]

dt7[,chem2 := factor(chem,levels = c('Bromide','Chloride','Barium','Strontium'), 
                     labels=c('Bromide','Chloride','Barium','Strontium')) ]

setorder(dt7, chem2, -model)


cols = c("impact_mean","impact_median", "concentration_mean","concentration_median","well_n_mean","well_n_median")
dt7[,(cols) := lapply(.SD, function(x) as.character( formatC(round(x,2), format="f",digits=2, big.mark=",") )),  .SDcols= cols ]
dt7[chem == "Bromide", (cols) :=  "-" ]


dt7_1 <-  dt7[model == "PA",.(chem, mean,lower,upper, rsquared, impact_mean,impact_median) ]
dt7_2 <-  dt7[model == "All",.(chem, mean,lower,upper,rsquared,impact_mean,impact_median, 
                               concentration_mean,concentration_median,well_n_mean,well_n_median) ]

setnames(dt7_1, c("impact_mean","impact_median") ,    
         c("impact_meanpa","impact_medianpa")  )

setnames(dt7_2, c("mean"  , "lower" , "upper"    , "chem"   ,"rsquared",
                  "impact_mean","impact_median", "concentration_mean","concentration_median","well_n_mean","well_n_median") , 
         c("mean_2"  , "lower_2" , "upper_2", "chem_2",  "rsquared_2",
           "impact_meanall","impact_medianall", "concentration_meanall","concentration_medianall","well_n_meanall","well_n_medianall") )

dt7_1 <- merge(dt7_1,dt7_2, by.x=c("chem" ), by.y=c("chem_2"), sort = FALSE )




dt7_bold <- dt7_1[,.(chem,  lower, lower_2) ]

dt7_bold[ ,':='(impact_meanpa =lower , impact_meanall =lower_2) ]




dt7_bold_median <- dt7_1[,.(chem, lower, lower_2) ]

dt7_bold_median[ ,':='(impact_medianpa =lower , impact_medianall =lower_2) ]


dt7_beta <- rbind(data.table(mean = c(NA,NA)  , lower = c(NA,NA), upper    = c(NA,NA),
                             mean_2 = c(NA,NA) , lower_2 = c(NA,NA), upper_2= c(NA,NA), chem  = c(NA,NA) ,
                             impact_meanpa = c(NA,NA),  impact_meanall = c(NA,NA)),
                  dt7_1[,.(mean,lower,upper,mean_2,lower_2,upper_2,chem,impact_meanpa,impact_meanall )] )





dt7_bold_new <- dt7[,.(chem, model, lower) ]

dt7_bold_new[ ,impact_mean := lower ]


dt7_bold_median_new <- copy(dt7_bold_new)
setnames(dt7_bold_median_new,"impact_mean","impact_median" )


dt7_beta_new <- rbind(data.table(mean = c(NA,NA)  ,model  = c(NA,NA), lower = c(NA,NA), upper    = c(NA,NA),
                              chem  = c(NA,NA) , impact_mean = c(NA,NA)),  
                  dt7[,.(mean,lower,upper,chem,model,impact_mean )] )





##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
####    Step 5 Generating Fig 4   #######
##%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


dt7_bold_concentration <- copy(dt7_bold_new[,c("chem"  ,"model"  , "impact_mean"   )])
dt7_bold_concentration[, ":="(concentration_mean =100000, well_n_mean =100000  )]
setcolorder(dt7_bold_concentration, c("chem" ,"model"  ,"concentration_mean" , "well_n_mean",  "impact_mean" ))


dt7_bold_concentration <-  lapply(as.data.frame(t(as.matrix(dt7_bold_concentration))),
                                  function(x) fifelse(as.numeric(x) >=0 & as.numeric(x) <100000,
                                                      list(gpar(fontface = "bold")), list(gpar(fontface = "plain")), 
                                                      na = list(gpar(fontface = "plain"))) )


tabletext_concentration  <-  rbind( data.table( chem=c(NA,"Ions"),
                                                model = c(NA, "Sample"),
                                                concentration_mean = c(NA,"Mean Concentration"),
                                                well_n_mean = list(NA,expression(bold("Mean # Wells/Year") ) ),
                                                impact_mean = c(NA, list(expression(bold("Impact" ~ (mu*g/l) )  ) ))  ) ,
                                    dt7[, .(chem,model,concentration_mean,well_n_mean, impact_mean)]   )


setcolorder(tabletext_concentration, c("chem","model","concentration_mean","well_n_mean","impact_mean" ))

# Revoing each second chemical label
tabletext_concentration[, gr1:=seq(1,.N), by = chem  ]
tabletext_concentration[gr1 == 2,chem:="" ]
tabletext_concentration[,gr1 := NULL ]

xticks <-  seq(-40, 60, 20)
xtlab <- rep(c(TRUE,TRUE), length.out = length(xticks))
attr(xticks, "labels") <- xtlab

pdf(file = 'Fig4.pdf', paper = "USr", width = 10) 
plot.new()

forestplot(tabletext_concentration, 
           graph.pos = 4,
           mean = dt7_beta_new$mean, 
           lower = dt7_beta_new$lower,
           upper = dt7_beta_new$upper, 
           hrzl_lines = list("3" = gpar(lty = 1)), 
           is.summary = c(TRUE,TRUE,rep(FALSE,8)),
           graphwidth = unit(55,"mm"),
           lineheight=unit(1.5,"cm"),
           colgap = unit(5,"mm"),
           align = c("c", "c", "c"),
           txt_gp = fpTxtGp(label = dt7_bold_concentration ,ticks=gpar(cex=0.75),xlab=gpar(cex=0.75) ),
           boxsize = 0.2,
           line.margin = .25,
           fn.ci_norm = fpDrawCircleCI,
           clip = c(-30, 60),
           vertices = TRUE,
           col = fpColors(box =  "red2",
                          line = "black"),
           xlab = expression("Coefficient estimates x" ~ 10^3),
          xticks = xticks)



legend(x = 0.38, y = 0.05,legend= c(expression(beta  ~ "(HUC8)")), box.lwd=1.5, pt.cex = 1.6,
       col="red2",cex = 0.75, pch=16,bty = "n") # 
grid.text(expression(bold("360-day HUC10" )), .89, .845, gp = gpar(fontsize=13, font = 4))
dev.off() 

