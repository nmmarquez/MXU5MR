################################################################################
# Age, year, municipality specific model with aggregated sexes. Not all units 
# have a population so their data will not be incorporated into the likelihood &
# will be trated as a missing observation. No covariates will be used initially
# however support will be added for covariate inclusion.
################################################################################
rm(list=ls())
pacman::p_load(INSP, data.table, dplyr, surveillance, TMB, Matrix, INLA, rgeos)

DT <- subset(fread("~/Documents/MXU5MR/defunciones/outputs/demog.csv"), EDADV==1)
DT[,GEOID:=sprintf("%05d", GEOID)]
DT[,EDAD:=EDADN]
agedf <- fread("~/Documents/MXU5MR/nacimientos/outputs/age_groups.csv")

# create data table with all combinations of geoid, age, and year
summary(DT$DEATHS > DT$POPULATION)
summary(DT$DEATHS > DT$POPULATION2)
DT[YEAR == 2015, POPULATION:=0]
DT[YEAR == 2011, POPULATION2:=0]

### build spde

### Build model structure


model_run <- function(DT, pinsamp=1, verbose=FALSE, option=1, seed=123, pop=1:2,
                      ffoption=0, ageversion=1){
    setwd("~/Documents/MXU5MR/analysis/")
    model <- "u5mr"
    mesh <- gCentroid(mx.sp.df, byid=T) %>% inla.mesh.create
    spde <- inla.spde2.matern(mesh)
    graph <- poly2adjmat(mx.sp.df)
    geoid <- unique(DT$GEOID)
    year <- unique(DT$YEAR)
    age <- unique(DT$EDAD)
    N_l <- ifelse(option == 1, length(geoid), nrow(spde$param.inla$M1))
    dim_len <- c(length(geoid), length(age), length(year))
    dim_len_phi <- c(N_l, length(age), length(year))
    set.seed(seed)
    Data <- list(yobs=array(DT$DEATHS, dim=dim_len), option=option,
                 offset=array(c(DT$POPULATION, DT$POPULATION2), 
                              dim=c(dim_len, 2))[,,,pop,drop=FALSE],
                 Wstar=Matrix(diag(rowSums(graph)) - graph, sparse=T),
                 lik=array(rbinom(nrow(DT), 1, pinsamp), dim=dim_len),
                 G0=spde$param.inla$M0, G1=spde$param.inla$M1, 
                 G2=spde$param.inla$M2, ffoption=ffoption, 
                 agep=subset(agedf, EDADV == ageversion)$MP)
    Params <- list(phi=array(0, dim=dim_len_phi), log_sigma=c(0, 0),
                   logit_rho=c(0, 0), beta=0, beta_age=rep(0, length(age)-1),
                   spparams=c(0, 0))
    dyn.load(dynlib(model))
    Obj <- MakeADFun(data=Data, parameters=Params, DLL=model, random="phi",
                     silent=!verbose)
    Obj$env$tracemgc <- verbose
    Obj$env$inner.control$trace <- verbose
    print(system.time(Opt <- nlminb(start=Obj$par, objective=Obj$fn, 
                                    gradient=Obj$gr,
                                    control=list(eval.max=1e4, iter.max=1e4))))
    Report <- Obj$report()
    Report$convergence <- Opt$convergence
    dyn.unload(dynlib(model))
    Report
}

# ospv <- list(m1=model_run(pinsamp=.8)$nll, 
#              m2=model_run(pinsamp=.8, option=2, verbose=TRUE)$nll)
# 
# save(ospv, file="~/Documents/MXU5MR/analysis/outputs/ospv_pop1.Rdata")

DT[,Ratem1pop1:=c(model_run(DT, pinsamp=1., option=1, pop=1)$RR)]
DT[,Ratem1pop2:=c(model_run(DT, pinsamp=1., option=1, pop=2)$RR)]
DT[,Ratem1:=c(model_run(DT, pinsamp=1., option=1, pop=1:2)$RR)]



fwrite(DT, "~/Documents/MXU5MR/analysis/outputs/model_phi2.csv")
