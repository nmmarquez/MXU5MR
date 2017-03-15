################################################################################
# create the age group sets information metadata                               #
################################################################################

rm(list=ls())
library(data.table)

DF <- data.table(EDADV=1, EDADN=0:4, LENGTH=1, MP=0:4 + .5, ADV=1)
DF <- rbind(DF, data.table(EDADV=2, EDADN=0:5, LENGTH=c(1/12, 11/12, rep(1,4)), 
                           MP=c(1/24, (1/12 + 1) / 2, 1:4 + .5), 
                           ADV=c(0, rep(1, 5))))
DF <- rbind(DF, data.table(EDADV=3, EDADN=0:15, 
                           LENGTH=c(rep(1/12, 12), rep(1,4)), 
                           MP=c((0:11 / 12) + 1/24, 1:4 + .5), 
                           ADV=c(rep(0, 11), rep(1,5))))
DF

fwrite(DF, file="~/Documents/MXU5MR/nacimientos/outputs/age_groups.csv")
