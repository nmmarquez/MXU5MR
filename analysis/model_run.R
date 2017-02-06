################################################################################
# Age, year, municipality specific model with aggregated sexes. Not all units 
# have a population so their data will not be incorporated into the likelihood &
# will be trated as a missing observation. No covariates will be used initially
# however support will be added for covariate inclusion.
################################################################################

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

DT[,c("age_pop", "age_deaths"):=lapply(list(POPULATION, DEATHS), sum), by=EDAD]
DT[,ASDR:=age_deaths/age_pop]
DT[,offset:=ASDR * POPULATION]
DT

### Build model structure
setwd("~/Documents/MXU5MR/analysis/")

model <- "u5mr"
if (file.exists(paste0(model, ".so"))) file.remove(paste0(model, ".so"))
if (file.exists(paste0(model, ".o"))) file.remove(paste0(model, ".o"))
if (file.exists(paste0(model, ".dll"))) file.remove(paste0(model, ".dll"))
compile(paste0(model, ".cpp"))

graph <- poly2adjmat(mx.sp.df)

dim_len <- c(length(geoid), length(age), length(year))
Data <- list(yobs=array(DT$DEATHS, dim=dim_len), option=1, 
             offset=array(DT$offset, dim=dim_len),
             Wstar=Matrix(diag(rowSums(graph)) - graph, sparse=T))
Params <- list(phi=array(0, dim=dim_len), log_sigma=c(0, 0, 0),
               logit_rho=c(0, 0, 0), beta=0)

dyn.load(dynlib(model))
Obj <- MakeADFun(data=Data, parameters=Params, DLL=model, random="phi",
                 silent=FALSE)
#Obj$env$tracemgc <- FALSE
#Obj$env$inner.control$trace <- FALSE
system.time(Opt <- nlminb(start=Obj$par, objective=Obj$fn, gradient=Obj$gr))
Opt$convergence
Report <- Obj$report()
Report$beta
Report$sigma
Report$rho

DT[,RR:=c(Report$RR)]

fwrite(DT, "~/Documents/MXU5MR/analysis/outputs/model_phi.csv")
