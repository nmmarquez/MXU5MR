rm(list=ls())
pacman::p_load(data.table, LifeTables)

setwd("~/Documents/MXU5MR/analysis/")

DT <- fread("./outputs/model_phi.csv")
DT[,DEATHS_m1p1:=Ratem1pop1 * POPULATION]
DT[,DEATHS_m1p2:=Ratem1pop2 * POPULATION2]

ya_df <- DT[,lapply(list(POPULATION, POPULATION2, DEATHS, DEATHS_m1p1, DEATHS_m1p2), sum),
               by=list(YEAR, EDAD)]
setnames(ya_df, names(ya_df), c("YEAR", "EDAD", "POPULATION", "POPULATION2",
                                "DEATHS", "DEATHS_m1p1", "DEATHS_m1p2"))

ya_df[,INEGI:=DEATHS/(POPULATION - .5 * DEATHS) * 1000]
ya_df[,SINAC:=DEATHS/(POPULATION2 - .5 * DEATHS) * 1000]
ya_df[,m1p1:=DEATHS_m1p1/(POPULATION - .5 * DEATHS_m1p1) * 1000]
ya_df[,m1p2:=DEATHS_m1p2/(POPULATION2 - .5 * DEATHS_m1p2) * 1000]
subset(ya_df, EDAD == 0)

u5 <- DT[,lapply(list(POPULATION, POPULATION2, DEATHS, DEATHS_m1p1, DEATHS_m1p2), sum),
            by=list(YEAR)]
setnames(u5, names(u5), c("YEAR", "POPULATION", "POPULATION2", "DEATHS",
                          "DEATHS_m1p1", "DEATHS_m1p2"))
u5[,INEGI:=DEATHS/(POPULATION - .5 * DEATHS) * 1000]
u5[,SINAC:=DEATHS/(POPULATION2 - .5 * DEATHS) * 1000]
u5[,m1p1:=DEATHS_m1p1/(POPULATION - .5 * DEATHS_m1p1) * 1000]
u5[,m1p2:=DEATHS_m1p2/(POPULATION2 - .5 * DEATHS_m1p2) * 1000]
u5

(1 - prod(1 - (subset(ya_df, YEAR == 2015)$m1p2 / 1000))) * 1000
