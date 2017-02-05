################################################################################
# Preliminary simulation run and analysis to see if its possible to to
# 1) Simulate correlations for all 2k+ munis, 5 ages, and 4-10 years of data
# 2) Write a model that mimics the simulation process in TMB
# 3) Get a rough estimate of run time for a model with over 50k+ parameters
################################################################################
rm(list=ls())
set.seed(123)
pacman::p_load(ar.matrix, data.table, ggplot2, INSP, dplyr, leaflet,
               surveillance, sparseMVN, TMB)

# get unique demographic indicators iqnoring sex for now
spdf <- mx.sp.df

geoid <- as.character(spdf@data$GEOID)
age <- 0:4
year <- 2009:2014

length(geoid) * length(age) * length(year)

# create data table with all combinations of geoid, age, and year
DT <- as.data.table(expand.grid(GEOID=geoid, age=age, year=year))

# Create three precision matricies for each demographic then combine with kron
sigmas <- list(A=.2, T=.2, L=.3)
rhos <- list(A=.98, T=.99, L=.90)
N <- list(L=poly2adjmat(spdf), A=length(age), T=length(year))
funcs <- list(L=Q.lCAR, A=Q.AR1, T=Q.AR1)
Qlist <- lapply(c(L="L", A="A", T="T"), function(x)
    funcs[[x]](N[[x]], sigmas[[x]], rhos[[x]], sparse=TRUE))
#Qlat <- kronecker(kronecker(Qlist$T, Qlist$A), Qlist$L)
Qlat <- kronecker(kronecker(Qlist$T, Qlist$A), Qlist$L)

# check the dims
cat("1. check the dim size \n")
print(dim(Qlat))

# using the chol decomp generate random data with the covar specification of
# Qlat^-1
cat("3. run time of generating random draws")
system.time(DT[,yobs:=c(sim.AR(1, Qlat)) + rnorm(nrow(Qlat), sd=.1)])

#mx.sp.df@data <- left_join(mx.sp.df@data, subset(DT, age==0 & year==2011))
spdf@data <- left_join(spdf@data, subset(DT, age==0 & year==2011))

spdf2leaf(spdf, "yobs")

subdf <- subset(DT, GEOID %in% sample(unique(DT$GEOID), 12))
ggplot(data=subdf, aes(x=year, y=yobs, group=age, color=age)) + geom_line() +
    facet_wrap(~GEOID)

# Run TMB model
setwd("~/Documents/MXU5MR/simulation/")

model <- "u5mr"
# if (file.exists(paste0(model, ".so"))) file.remove(paste0(model, ".so"))
# if (file.exists(paste0(model, ".o"))) file.remove(paste0(model, ".o"))
# if (file.exists(paste0(model, ".dll"))) file.remove(paste0(model, ".dll"))
compile(paste0(model, ".cpp"))

dyn.load(dynlib(model))
dim_len <- c(length(geoid), N$A, N$T)
Data <- list(yobs=array(DT$yobs, dim=dim_len), option=1,
             Wstar=Matrix(diag(rowSums(N$L)) - N$L, sparse=T))
Params <- list(phi=array(0, dim=dim_len), log_sigma=c(0, 0, 0),
               logit_rho=c(0, 0, 0), beta=0, log_sig_eps=0)
#Map <- list(log_sigma=factor(c(NA, NA, NA)), logit_rho=factor(c(NA, NA, NA)),
            #phi=factor(array(NA, dim=dim_len)))

Obj <- MakeADFun(data=Data, parameters=Params, DLL=model, random="phi",
                 silent=TRUE)#, map=Map)
Obj$env$tracemgc <- FALSE
Obj$env$inner.control$trace <- FALSE
system.time(Opt <- nlminb(start=Obj$par, objective=Obj$fn, gradient=Obj$gr))
# Yay!
# user   system  elapsed
# 1524.724    8.648 1533.261
Opt$convergence
Report <- Obj$report()
names(Report)
Report$beta
mean(DT$yobs)
dyn.unload(dynlib(model))
Report$rho
Report$sigma

