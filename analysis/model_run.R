################################################################################
# Age, year, municipality specific model with aggregated sexes. Not all units 
# have a population so their data will not be incorporated into the likelihood &
# will be trated as a missing observation. No covariates will be used initially
# however support will be added for covariate inclusion.
################################################################################
rm(list=ls())
pacman::p_load(INSP, data.table, dplyr, surveillance, TMB, Matrix)

demog <- fread("~/Documents/MXU5MR/defunciones/outputs/demog.csv")
demog[,GEOID:=sprintf("%05d", GEOID)]

geoid <- as.character(mx.sp.df@data$GEOID)
age <- sort(unique(demog$EDAD))
year <- sort(unique(demog$YEAR))

# create data table with all combinations of geoid, age, and year
DT <- as.data.table(expand.grid(GEOID=geoid, EDAD=age, YEAR=year))
DT <- as.data.table(left_join(DT, demog))
DT[is.na(POPULATION), POPULATION:=0]
DT[is.na(DEATHS), DEATHS:=0]
summary(DT$DEATHS > DT$POPULATION)

# DTA <- DT[,lapply(list(DEATHS, POPULATION), sum), by=list(EDAD)]
# DTA[,ASDR:=V1 / V2]
# DTA
# 
# DT[,SDR:=sum(DT$DEATHS) / sum(DT$POPULATION)]
DT[,offset:=POPULATION]
DT

### Build model structure
setwd("~/Documents/MXU5MR/analysis/")

model <- "u5mr"
if (file.exists(paste0(model, ".so"))) file.remove(paste0(model, ".so"))
if (file.exists(paste0(model, ".o"))) file.remove(paste0(model, ".o"))
if (file.exists(paste0(model, ".dll"))) file.remove(paste0(model, ".dll"))
compile(paste0(model, ".cpp"))

model_run <- function(pinsamp=1,rectime=T, verbose=F){
    graph <- poly2adjmat(mx.sp.df)
    dim_len <- c(length(geoid), length(age), length(year))
    Data <- list(yobs=array(DT$DEATHS, dim=dim_len), option=1, 
                 offset=array(DT$offset, dim=dim_len),
                 Wstar=Matrix(diag(rowSums(graph)) - graph, sparse=T),
                 lik=array(rbinom(nrow(DT), 1, pinsamp), dim=dim_len))
    Params <- list(phi=array(0, dim=dim_len), log_sigma=c(0, 0, 0),
                   logit_rho=c(0, 0, 0), beta=0, beta_age=rep(0, length(age)-1))
    dyn.load(dynlib(model))
    Obj <- MakeADFun(data=Data, parameters=Params, DLL=model, random="phi",
                     silent=!verbose)
    Obj$env$tracemgc <- verbose
    Obj$env$inner.control$trace <- verbose
    system.time(Opt <- nlminb(start=Obj$par, objective=Obj$fn, gradient=Obj$gr))
    # user   system  elapsed 
    # 1128.412   10.468 1140.782 
    Report <- Obj$report()
    Report$convergence <- Opt$convergence
    Report
}

ospv <- model_run(pinsamp=.8)$nll
print(ospv)
Report <- model_run(pinsamp=1.)

DT[,RR:=c(Report$phi)]
DT[,Rate:=c(Report$RR)]
DT[,B0:=ReportOS$beta]

fwrite(DT, "~/Documents/MXU5MR/analysis/outputs/model_phi.csv")