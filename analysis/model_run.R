################################################################################
# Age, year, municipality specific model with aggregated sexes. Not all units 
# have a population so their data will not be incorporated into the likelihood &
# will be trated as a missing observation. No covariates will be used initially
# however support will be added for covariate inclusion.
################################################################################
rm(list=ls())
pacman::p_load(INSP, data.table, dplyr, surveillance, TMB, Matrix, INLA, rgeos)

demog <- fread("~/Documents/MXU5MR/defunciones/outputs/demog.csv")
demog[,GEOID:=sprintf("%05d", GEOID)]

geoid <- as.character(mx.sp.df@data$GEOID)
age <- sort(unique(demog$EDAD))
year <- sort(unique(demog$YEAR))

# create data table with all combinations of geoid, age, and year
DT <- as.data.table(expand.grid(GEOID=geoid, EDAD=age, YEAR=year))
DT <- as.data.table(left_join(DT, demog))
DT[is.na(POPULATION), POPULATION:=0]
DT[YEAR == 2015, POPULATION:=0]
DT[is.na(POPULATION2), POPULATION2:=0]
DT[is.na(DEATHS), DEATHS:=0]
summary(DT$DEATHS > DT$POPULATION)
summary(DT$DEATHS > DT$POPULATION2)

### build spde
mesh <- gCentroid(mx.sp.df, byid=T) %>% inla.mesh.create
spde <- inla.spde2.matern(mesh)
N_l <- nrow(mx.sp.df@data)
all(mesh$idx$loc[1:(N_l -1)] + 1 == mesh$idx$loc[2:N_l])

### Build model structure
setwd("~/Documents/MXU5MR/analysis/")

model <- "u5mr"
#if (file.exists(paste0(model, ".so"))) file.remove(paste0(model, ".so"))
#if (file.exists(paste0(model, ".o"))) file.remove(paste0(model, ".o"))
#if (file.exists(paste0(model, ".dll"))) file.remove(paste0(model, ".dll"))
compile(paste0(model, ".cpp"))

model_run <- function(pinsamp=1, verbose=FALSE, option=1, seed=123, pop=1:2){
    graph <- poly2adjmat(mx.sp.df)
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
                 G2=spde$param.inla$M2)
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
    # user   system  elapsed 
    # 1128.412   10.468 1140.782 
    Report <- Obj$report()
    Report$convergence <- Opt$convergence
    Report
}

# ospv <- list(m1=model_run(pinsamp=.8)$nll, 
#              m2=model_run(pinsamp=.8, option=2, verbose=TRUE)$nll)
# 
# save(ospv, file="~/Documents/MXU5MR/analysis/outputs/ospv_pop1.Rdata")

DT[,Ratem1pop1:=c(model_run(pinsamp=1., option=1, pop=1)$RR)]
DT[,Ratem1pop2:=c(model_run(pinsamp=1., option=1, pop=2)$RR)]
DT[,Ratem1:=c(model_run(pinsamp=1., option=1, pop=1:2)$RR)]



fwrite(DT, "~/Documents/MXU5MR/analysis/outputs/model_phi.csv")
