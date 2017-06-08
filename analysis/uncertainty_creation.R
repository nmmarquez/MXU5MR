rm(list=ls())

pacman::p_load(INLA, TMB, data.table, ggplot2, dplyr, dtplyr, ineq, INSP, surveillance)

setwd("~/Documents/MXU5MR/analysis/outputs/")
load("./ospv_pop1.Rdata")
load("model_covs_full.Rdata")
source("~/Documents/MXU5MR/utilities/utilities.R")

DT <- fread("./model_phi_full.csv")

plugs <- list()
plugs["year_start"] <- min(DT$YEAR)
plugs["year_end"] <- max(DT$YEAR)
plugs["IHME_value"] <- ".0154 (.0117-.0200)"
plugs["UN_value"] <- ".0132"
plugs["aad_u5mr_est"] <- round(abs(ospv$m1[2] - ospv$m2[2]) / (length(unique(DT$GEOID)) * 5 * 4 * .8), 3)

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
DT[YEAR == 2015, POPULATION2:=subset(DT, YEAR == 2014)$POPULATION]
apply(MRdraws, 2, function(x) x * DT$POPULATION2)
Ddraws <- apply(MRdraws, 2, function(x) x * DT$POPULATION2)
Ddraws <- as.data.table(Ddraws)
Ddraws[,POPULATION:=DT$POPULATION2]
Ddraws[,EDAD:=DT$EDAD]
Ddraws[,YEAR:=DT$YEAR]

natdraws <- subset(Ddraws[,lapply(.SD, sum), by=list(EDAD, YEAR)], YEAR >= 2004)
cols <- names(Ddraws)[grepl("sample", names(Ddraws))]
natdraws[ , (cols) := lapply(.SD, `/`, POPULATION), .SDcols = cols]
natdraws[,POPULATION:=NULL]
natdraws[,EDAD:=NULL]
natdraws <- natdraws[,lapply(.SD, function(x) 1-prod(1-x)), by=YEAR]
natdraws[,YEAR:=NULL]
m_ <- round(apply(as.matrix(natdraws), 1, mean)[nrow(natdraws)], 4)
l_ <- round(apply(as.matrix(natdraws), 1, quantile, probs=.025)[nrow(natdraws)], 4)
h_ <- round(apply(as.matrix(natdraws), 1, quantile, probs=.975)[nrow(natdraws)], 4)

plugs["model_value"] <- paste0(m_, " (", l_, ", ", h_, ")")
write_plugs(plugs)

jpeg("~/Documents/MXU5MR/analysis/plots/logmortalitymuni.jpg")
ggplot(DT[YEAR == 2015,], aes(x=EDAD+1, y=log(Ratem1pop1), group=GEOID)) +
    geom_line(alpha=.1) + 
    labs(x="Age", y="Log Mortality Rate", title="Mortality by Municipality") + 
    theme_set(theme_gray(base_size = 28))
dev.off()

jpeg("~/Documents/MXU5MR/analysis/plots/poperrors.jpg")
ggplot(DT[YEAR!=2015], aes(x=POPULATION, y=sterror, color=EDAD, group=EDAD)) + 
    geom_point(alpha=.4) + labs(x="Population", title="Demographics & error",
                                y=expression(M[x]~std.~err.), color="Age")
dev.off()

jpeg("~/Documents/MXU5MR/analysis/plots/logpoperrors.jpg")
ggplot(DT[YEAR!=2015], aes(x=log(POPULATION+1), y=sterror, color=EDAD, group=EDAD)) + 
    geom_point(alpha=.4) + labs(x="Log Population", title="Demographics & error",
                        y=expression(M[x]~std.~err.), color="Age") + 
    theme_set(theme_gray(base_size = 28))
dev.off()

jpeg("~/Documents/MXU5MR/analysis/plots/morterrors.jpg")
ggplot(DT[YEAR!=2015], aes(x=Ratem1pop1, y=sterror, color=log(POPULATION+1), 
                           group=log(POPULATION+1))) + 
    geom_point(alpha=.3) + labs(x=expression(M[x]), title="Demographics & error",
                                y=expression(M[x]~std.~err.), color="Log Pop") +
    scale_color_gradientn(colors=rainbow(5))
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


hivals <- apply(q0array, c(2,3), quantile, .99)
lovals <- apply(q0array, c(2,3), quantile, .01)
relineq <- hivals / lovals
apply(relineq, 1, mean)
apply(relineq, 1, quantile, probs=.975)
apply(relineq, 1, quantile, probs=.025)

DTineq <- data.table(year=ystart:yend, relineq=apply(relineq, 1, mean),
                     relineqlow=apply(relineq, 1, quantile, probs=.025),
                     relineqhi=apply(relineq, 1, quantile, probs=.975))
ggplot(DTineq, aes(x=year, y=relineq)) + geom_line() + 
    geom_ribbon(aes(x=year, ymin=relineqlow, ymax=relineqhi), alpha=.25) + 
    labs(x="Year", y="Relative Inequality", title="5Q0 Inequality")

ineqDT <- expand.grid(Year=as.factor(c(ystart, yend)), draw=1:1000,
                      measure=as.factor(c("Relative", "Absolute")))
ineqDT <- as.data.table(ineqDT)
ineqDT[,ineq:=c(c(hivals / lovals), c(hivals - lovals))]

1 - mean(apply(hivals / lovals, 2, function(x) x[2] -x[1]) > 0)
1 - mean(apply(hivals - lovals, 2, function(x) x[2] -x[1]) > 0)

jpeg("~/Documents/MXU5MR/analysis/plots/ineqpars.jpg")
ggplot(ineqDT, aes(x=ineq, fill=Year, color=Year)) + geom_density(alpha=.5) +
    labs(x="Inequality Estimate", y="Density", title="Parameter Density") +
    facet_wrap(~measure, scales="free")
dev.off()

graph <- poly2adjmat(mx.sp.df)
DT[,neigh:=rep(rowSums(graph), length(unique(DT$EDAD))*length(unique(DT$YEAR)))]

DT[,edgey:=YEAR == ystart | YEAR == yend]
DT[,edgea:=EDAD == 0]

lm_var <- lm(sterror ~ Ratem1pop1 * log(POPULATION+1) * EDAD * neigh,
             data=DT[YEAR!=2015])
summary(lm_var)
anovasd <- anova(lm_var)
varexpl <- anovasd$`Sum Sq` / sum(anovasd$`Sum Sq`)
names(varexpl) <- row.names(anovasd)
print(varexpl * 100)
print(summary(lm_var))
print(anovasd)

sum(varexpl[c("Ratem1pop1", "log(POPULATION + 1)", "Ratem1pop1:log(POPULATION + 1)")])

mean(apply(q0array[,4,], 1, mean) < .016)
mean(apply(q0array[,4,], 1, quantile, probs=.95) < .016)
sort(table(substring(sprintf("%05d", unique(DT$GEOID)),1,2)[which(apply(q0array[,4,], 1, quantile, probs=.95) < .016)]))
sort(table(substring(sprintf("%05d", unique(DT$GEOID)),1,2)))