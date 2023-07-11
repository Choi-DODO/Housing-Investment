*************************************************
* This code is written by Dohyeong Choi "
* Apr/11/2023
*************************************************
clear all
set more off
version 17


cd // working directory check. It is where this do file exists

//read in datasets and making these dta files
insheet using Data/new_table_21.csv, clear

global cur_inc "val_rent mn_ratio yr_inc"
global covariate "b2.ac i.gender i.marriage hmember i.col_grd i.other" 
global covariate1 "age age_sq i.gender i.marriage i.hsize i.col_grd i.other" 
global region "1.rc 2.rc 3.rc 4.rc 5.rc 6.rc 7.rc 8.rc 9.rc 10.rc 11.rc 12.rc 13.rc 14.rc 15.rc 16.rc"
global desc "val_rent mn_ratio yr_inc b2.ac i.gender i.marriage hmember i.col_grd b1.other"

*##################################### Linear Prob Model #####################################
sum $desc

* Main Model: cur_inc
regress own $cur_inc [iweight=wt_new], vce(cluster rc)
outreg2 using Results/table_main.xls,   replace se label dec(3) excel
regress own $cur_inc $covariate [iweight=wt_new], vce(cluster rc)
outreg2 using Results/table_main.xls,   append se label dec(3) excel
regress own $cur_inc $covariate $region [iweight=wt_new], vce(cluster rc)
outreg2 using Results/table_main.xls,   append se label dec(3) excel

test 1.ac 2.ac gender marriage hmember 1.edu_level other
test $region

* interaction
regress own $cur_inc $covariate c.val_rent#1.ac $region [iweight=wt_new], vce(cluster rc) //*
outreg2 using Results/table_inter.xls,   replace se label dec(3) excel
regress own $cur_inc $covariate c.val_rent#3.ac $region [iweight=wt_new], vce(cluster rc) //*
outreg2 using Results/table_inter.xls,   append se label dec(3) excel
regress own $cur_inc $covariate c.val_rent#i.gender $region [iweight=wt_new], vce(cluster rc) //*
outreg2 using Results/table_inter.xls,   append se label dec(3) excel
regress own $cur_inc $covariate c.val_rent#i.col_grd $region [iweight=wt_new], vce(cluster rc) //*
outreg2 using Results/table_inter.xls,   append se label dec(3) excel
regress own $cur_inc $covariate c.val_rent#i.other $region [iweight=wt_new], vce(cluster rc) //*
outreg2 using Results/table_inter.xls,   append se label dec(3) excel
regress own $cur_inc $covariate c.val_rent#i.nohouse $region [iweight=wt_new],vce(cluster rc)//*
outreg2 using Results/table_inter.xls,   append se label dec(3) excel


* robustness
regress own $cur_inc $covariate $region [iweight=wt_new], vce(cluster rc)
outreg2 using Results/table_robust.xls,   replace se label dec(3) excel ctitle(LPM)
regress own $cur_inc $covariate1 $region [iweight=wt_new], vce(cluster rc)
outreg2 using Results/table_robust.xls,   append se label dec(3) excel ctitle(LPM)
logit own $cur_inc $covariate $region [iweight=wt_new], vce(cluster rc) nolog
outreg2 using Results/table_robust.xls,   append se label dec(3) excel ctitle(LOGIT) addstat(R-squared, e(r2_p))
probit own $cur_inc $covariate $region [iweight=wt_new], vce(cluster rc) nolog
outreg2 using Results/table_robust.xls,   append se label dec(3) excel ctitle(PROBIT) addstat(R-squared, e(r2_p))


quietly probit own $cur_inc $covariate $region, vce(cluster rc) nolog
margins, dydx(*)
margins, dydx(val_rent mn_ratio yr_inc 1.ac 3.ac 1.gender 1.marriage hmember 1.col_grd 1.other)

quietly regress own $cur_inc $covariate1 $interaction $region, vce(cluster rc)

margins ac, dydx(val_rent)
marginsplot
margins gender, dydx(val_rent)
marginsplot
margins other, dydx(val_rent)
marginsplot



logit own $cur_inc $covariate1 c.val_rent#c.age $region, vce(cluster rc) nolog
margins, dydx(val_rent) at(age = (20(10)80))
marginsplot

quietly logit own $cur_inc $covariate c.val_rent#1.gender $region, vce(cluster rc) nolog
margins gender, dydx(val_rent)
marginsplot

quietly logit own $cur_inc $covariate c.val_rent#1.col_grd $region, vce(cluster rc) nolog
margins col_grd, dydx(val_rent)
marginsplot

quietly logit own $cur_inc $covariate c.val_rent#1.other $region, vce(cluster rc) nolog
margins other, dydx(val_rent)
marginsplot






* stepwise significance test
quietly regress own $per_inc $covariate $interaction, vce(cluster rc)
test $interaction
quietly regress own $per_inc $covariate $interaction $region, vce(cluster rc)
test $region

* vif check
quietly regress own $per_inc $covariate c.val_rent#1.edu_level c.val_rent#1.other, vce(cluster rc)
vif

* etc
regress own $per_inc $covariate 1.other, vce(cluster rc)
regress own $per_inc $covariate 1.other c.val_rent#1.other, vce(cluster rc)
