rm(list=ls())

pacman::p_load(INLA, TMB, data.table, ggplot2, dplyr, dtplyr, ineq)

setwd("~/Documents/MXU5MR/analysis/outputs/")
load("model_covs.Rdata")

DT <- fread("./model_phi3.csv")

head(row.names(mods$Ratem1pop1$prec), n=15)
tail(row.names(mods$Ratem1pop1$prec), n=15)

# lets take the precision of just the random effects since the random effects
# and fixed effects are independent from one another

phiidx <- which(row.names(mods$Ratem1pop1$prec) == "phi")
Q_phi <- mods$Ratem1pop1$prec[phiidx, phiidx]

# we can simulate from this matrix 1000 times for unceratinty 
system.time(phidraws <- c(mods$Ratem1pop1$phi) + inla.qsample(n = 1000L, Q_phi))

b_age <- mods$Ratem1pop1$par.vals[names(mods$Ratem1pop1$par.vals)=="beta_age"]
b_age_abs <- c(mods$Ratem1pop1$beta, mods$Ratem1pop1$beta + b_age) 

MRdraws <- exp(b_age_abs[DT$EDAD + 1] + phidraws)
DT[,sterror:=apply(MRdraws, 1, sd)]

jpeg("~/Documents/MXU5MR/analysis/plots/poperrors.jpg")
ggplot(DT[YEAR!=2015], aes(x=POPULATION, y=sterror, color=EDAD, group=EDAD)) + 
    geom_point(alpha=.4) + labs(x="Population", title="Demographics & error",
                                y=expression(M[x]~std.~err.))
dev.off()

jpeg("~/Documents/MXU5MR/analysis/plots/logpoperrors.jpg")
ggplot(DT[YEAR!=2015], aes(x=log(POPULATION+1), y=sterror, color=EDAD, group=EDAD)) + 
    geom_point(alpha=.4) + labs(x="Log Population", title="Demographics & error",
                        y=expression(M[x]~std.~err.))
dev.off()

ystart <- min(DT$YEAR)
yend <- max(DT$YEAR)

ystartvec <- DT$YEAR == ystart
yendvec <- DT$YEAR == yend
agespecmat <- sapply(0:4, function(x) which(DT$EDAD == x))

new_dims <- c(dim(mods$Ratem1pop1$phi), 1000)
MRarray <- array(c(MRdraws), dim=new_dims)
q0array <- apply(MRarray, c(1,3,4), function(x) 1 - prod(1-x))
DF5q0 <- unique(DT[,list(GEOID, YEAR)])
DF5q0[,fqz:=c(apply(q0array, c(1,2), mean))]
DF5q0[,fqzl:=c(apply(q0array, c(1,2), quantile, probs=.025))]
DF5q0[,fqzh:=c(apply(q0array, c(1,2), quantile, probs=.975))]
summary(DF5q0)


hivals <- apply(q0array[,c(1,dim(q0array)[2]),], c(2,3), quantile, .99)
lovals <- apply(q0array[,c(1,dim(q0array)[2]),], c(2,3), quantile, .01)

ineqDT <- expand.grid(Year=as.factor(c(ystart, yend)), draw=1:1000,
                      measure=as.factor(c("Relative", "Absolute")))
ineqDT <- as.data.table(ineqDT)
ineqDT[,ineq:=c(c(hivals / lovals), c(hivals - lovals))]

jpeg("~/Documents/MXU5MR/analysis/plots/ineqpars.jpg")
ggplot(ineqDT, aes(x=ineq, fill=Year, color=Year)) + geom_density(alpha=.5) +
    labs(x="Inequality Estimate", y="Density", title="Parameter Density") +
    facet_wrap(~measure, scales="free")
dev.off()

1 - mean(apply(hivals / lovals, 2, function(x) x[2] -x[1]) > 0)
1 - mean(apply(hivals - lovals, 2, function(x) x[2] -x[1]) > 0)
