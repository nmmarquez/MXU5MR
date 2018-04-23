rm(list=ls())

pacman::p_load(INLA, TMB, data.table, ggplot2, dplyr, dtplyr, ineq, INSP, 
               surveillance, clusterPower, tidyverse)

setwd("~/Documents/MXU5MR/analysis/outputs/")
load("./ospv_pop1.Rdata")
load("model_covs_full.Rdata")
load("../../IHMEanlaysis/adjust.Rdata")
source("~/Documents/MXU5MR/utilities/utilities.R")

DT <- fread("./model_phi_full.csv")
DT[,ENT_RESID:=as.numeric(str_sub(sprintf("%05d", GEOID), 1, 2))]
DT <- left_join(
    as.data.frame(DT), 
    subset(rename(U1state, YEAR=year), select=c(ENT_RESID, YEAR, U1Adj)))
DT <- left_join(
    DT, 
    subset(rename(U5state, YEAR=year), select=c(ENT_RESID, YEAR, U5Adj)))

DT <- DT %>%
    mutate(ADJ=ifelse(EDAD==0, U1Adj, U5Adj)) %>%
    as.data.table

# plug the quick stuff
plugs <- list()
plugs["year_start"] <- min(DT$YEAR)
plugs["year_end"] <- max(DT$YEAR)
plugs["IHME_value"] <- ".0154 (.0117-.0200)"
plugs["UN_value"] <- ".0132"
plugs["aad_u5mr_est"] <- round(abs(ospv$m1[2] - ospv$m2[2]) / 
                                   (length(unique(DT$GEOID)) * 5 * 4 * .8), 3)
plugs["oosnllM"] <- ospv$m1[2]
plugs["oosnlllcar"] <- ospv$m2[2]

# plug the param values
fixidx <- which(row.names(mods$Ratem1pop1$prec) != "phi")
sds <- diag(MASS::ginv(as.matrix(mods$Ratem1pop1$prec[fixidx, fixidx])))**.5 * 1.98
names(sds) <- row.names(mods$Ratem1pop1$prec)[fixidx]

rhomax <- expit(logit(mods$Ratem1pop1$rho) + sds[names(sds) == "logit_rho"])
rhomax <- c(rhomax, expit(logit(mods$Ratem1pop1$sprho) + sds[names(sds) == "spparams"][1]))
rhomin <- expit(logit(mods$Ratem1pop1$rho) - sds[names(sds) == "logit_rho"])
rhomin <- c(rhomin, expit(logit(mods$Ratem1pop1$sprho) - sds[names(sds) == "spparams"][1]))

plugs["rhoa"] <- format_uncert(mods$Ratem1pop1$rho[1], rhomin[1], rhomax[1])
plugs["rhot"] <- format_uncert(mods$Ratem1pop1$rho[2], rhomin[2], rhomax[2])
plugs["rhol"] <- format_uncert(mods$Ratem1pop1$sprho, rhomin[3], rhomax[3])

# lets take the precision of just the random effects since the random effects
# and fixed effects are independent from one another

phiidx <- which(row.names(mods$Ratem1pop1$prec) == "phi")
Q_phi <- mods$Ratem1pop1$prec[phiidx, phiidx]

# we can simulate from this matrix 1000 times for unceratinty 
system.time(phidraws <- c(mods$Ratem1pop1$phi) + inla.qsample(n = 1000L, Q_phi))

b_age <- mods$Ratem1pop1$par.vals[names(mods$Ratem1pop1$par.vals)=="beta_age"]
b_age_abs <- c(mods$Ratem1pop1$beta, mods$Ratem1pop1$beta + b_age) 

MRdraws <- exp(b_age_abs[DT$EDAD + 1] + phidraws) * DT$ADJ
DT[,sterror:=apply(MRdraws, 1, sd)]
DT[,lwr:=apply(MRdraws, 1, function(x) quantile(x, probs=.025))]
DT[,upr:=apply(MRdraws, 1, function(x) quantile(x, probs=.975))]
# DT[YEAR == 2015 & EDAD == 0, 
#    POPULATION2:=subset(DT, YEAR == 2014 & EDAD==0)$POPULATION]

Ddraws <- apply(MRdraws, 2, function(x) x * DT$POPULATION2)
Ddraws <- as.data.table(Ddraws)
Ddraws[,POPULATION:=DT$POPULATION2]
Ddraws[,EDAD:=DT$EDAD]
Ddraws[,YEAR:=DT$YEAR]

natdraws <- Ddraws[,lapply(.SD, sum), by=list(EDAD, YEAR)]
cols <- names(Ddraws)[grepl("sample", names(Ddraws))]
natdraws[ , (cols) := lapply(.SD, `/`, POPULATION), .SDcols = cols]
natdraws[,POPULATION:=NULL]
natdraws[,EDAD:=NULL]
natdraws <- natdraws[,lapply(.SD, function(x) 1-prod(1-x)), by=YEAR]
natdraws[,m_:=apply(as.matrix(subset(natdraws, select=cols)), 1, mean)]
natdraws[,l_:=apply(as.matrix(subset(natdraws, select=cols)), 1, quantile, probs=.025)]
natdraws[,h_:=apply(as.matrix(subset(natdraws, select=cols)), 1, quantile, probs=.975)]

jpeg("~/Documents/MXU5MR/analysis/plots/nat5q0.jpg")
ggplot(natdraws, aes(x=YEAR, y=m_)) + geom_line() + 
    geom_ribbon(aes(x=YEAR, ymin=l_, ymax=h_), alpha=.25) + 
    labs(x="Year", y="5Q0", title="National Estimates of 5Q0") + 
    theme(plot.title = element_text(hjust = 0.5))
dev.off()

natdraws[,YEAR:=NULL]
m_ <- round(apply(as.matrix(natdraws), 1, mean)[nrow(natdraws)], 4)
l_ <- round(apply(as.matrix(natdraws), 1, quantile, probs=.025)[nrow(natdraws)], 4)
h_ <- round(apply(as.matrix(natdraws), 1, quantile, probs=.975)[nrow(natdraws)], 4)

plugs["model_value"] <- paste0(m_, " (", l_, ", ", h_, ")")

# 
plugs["u5mrsd"] <- sd(with(subset(DT, POPULATION2 != 0), DEATHS / POPULATION2))
plugs["crude"] <- sd(with(subset(DT, POPULATION2 != 0), Ratem1pop1))


jpeg("~/Documents/MXU5MR/analysis/plots/logmortalitymuni.jpg")
ggplot(DT[YEAR == 2015,], aes(x=EDAD+1, y=Ratem1pop1, group=GEOID)) +
    coord_trans(y="log") +
    geom_line(alpha=.1) + 
    labs(x="Age", y="Log Mortality Rate", title="Mortality by Municipality") + 
    theme_set(theme_gray(base_size = 28))
dev.off()

jpeg("~/Documents/MXU5MR/analysis/plots/logpoperrors.jpg")
ggplot(DT[YEAR!=2015], aes(x=(POPULATION+1), y=sterror, color=EDAD, group=EDAD)) + 
    geom_point(alpha=.4) + labs(x="Population", title="Demographics & error",
                        y=expression(M[x]~std.~err.), color="Age") +
    coord_trans(x="log") +
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
absineq <- hivals - lovals
relineqdiff <- relineq[nrow(relineq),] - relineq[1,]
absineqdiff <- absineq[nrow(absineq),] - absineq[1,]

plugs["relineq"] <- format_uncert(mean(relineq), quantile(relineq, probs=.025),
                                  quantile(relineq, probs=.975))
plugs["absineq"] <- format_uncert(mean(absineq), quantile(absineq, probs=.025),
                                  quantile(absineq, probs=.975))


DTineq <- data.table(year=ystart:yend, relineq=apply(relineq, 1, mean),
                     relineqlow=apply(relineq, 1, quantile, probs=.025),
                     relineqhi=apply(relineq, 1, quantile, probs=.975),
                     absineq=apply(absineq, 1, mean),
                     absineqlow=apply(absineq, 1, quantile, probs=.025),
                     absineqhi=apply(absineq, 1, quantile, probs=.975))

jpeg("~/Documents/MXU5MR/analysis/plots/relineqtimeseries.jpg")
ggplot(DTineq, aes(x=year, y=relineq)) + geom_line() + 
    geom_ribbon(aes(x=year, ymin=relineqlow, ymax=relineqhi), alpha=.25) + 
    labs(x="Year", y="Relative Inequality", title="5Q0 Inequality") + 
    theme(plot.title = element_text(hjust = 0.5))
dev.off()

jpeg("~/Documents/MXU5MR/analysis/plots/absineqtimeseries.jpg")
ggplot(DTineq, aes(x=year, y=absineq)) + geom_line() + 
    geom_ribbon(aes(x=year, ymin=absineqlow, ymax=absineqhi), alpha=.25) + 
    labs(x="Year", y="Absolute Inequality", title="5Q0 Inequality") + 
    theme(plot.title = element_text(hjust = 0.5))
dev.off()

summary(relineq[16,] - relineq[12,])

#ineqDT <- expand.grid(Year=as.factor(c(ystart, yend)), draw=1:1000,
#                      measure=as.factor(c("Relative", "Absolute")))
#ineqDT <- as.data.table(ineqDT)
#ineqDT[,ineq:=c(c(hivals / lovals), c(hivals - lovals))]

#1 - mean(apply(hivals / lovals, 2, function(x) x[2] -x[1]) > 0)
#1 - mean(apply(hivals - lovals, 2, function(x) x[2] -x[1]) > 0)

#jpeg("~/Documents/MXU5MR/analysis/plots/ineqpars.jpg")
#ggplot(ineqDT, aes(x=ineq, fill=Year, color=Year)) + geom_density(alpha=.5) +
#    labs(x="Inequality Estimate", y="Density", title="Parameter Density") +
#    facet_wrap(~measure, scales="free")
#dev.off()

graph <- poly2adjmat(mx.sp.df)
DT[,neigh:=rep(rowSums(graph), length(unique(DT$EDAD))*length(unique(DT$YEAR)))]

DT[,edgey:=YEAR == ystart | YEAR == yend]
DT[,edgea:=EDAD == 0]

lm_var <- lm(sterror ~ Ratem1pop1 * log(POPULATION+1) * EDAD * neigh,
             data=DT[YEAR!=2015])
lm_var2 <- lm(sterror ~ Ratem1pop1 * log(POPULATION+1), data=DT[YEAR!=2015])

plugs["lmr2"] <- round(summary(lm_var)$r.squared, 4)
plugs["lmr2sub"] <- round(summary(lm_var2)$r.squared, 4)
plugs["abineq"] <- plugs[["absineq"]]


plugs["hi2015"] <- round(max(DF5q0[YEAR==2015, fqz]), 4)
plugs["lo2015"] <- round(min(DF5q0[YEAR==2015, fqz]), 4)
plugs["mean_time"] <- ".6"
plugs["sd_time"] <- ".4"
plugs["chiapas_hi_reg"] <- "2.8"
plugs["rezmoransi"] <- "(p < .01)"
plugs["ttrmoransi"] <- "(p < .01)"
plugs["kfold"] <- "10"
plugs["kpercent"] <- "20%"
plugs["n_u5_deaths"] <- "PLUG ME"

mean(apply(q0array[,4,], 1, mean) < .016)
sum(apply(q0array[,4,], 1, mean) < .016)
mean(apply(q0array[,4,], 1, quantile, probs=.975) < .016)
sum(apply(q0array[,4,], 1, quantile, probs=.975) < .016)
mean(apply(q0array[,4,], 1, quantile, probs=.025) > .016)
sum(apply(q0array[,4,], 1, quantile, probs=.025) > .016)
sort(table(substring(sprintf("%05d", unique(DT$GEOID)),1,2)[which(apply(q0array[,4,], 1, quantile, probs=.95) < .016)]))
sort(table(substring(sprintf("%05d", unique(DT$GEOID)),1,2)))

write_plugs(plugs)
DF5q0 %>% filter(YEAR == 2000 | YEAR == 2015) %>%
    mutate(YEAR=as.factor(YEAR)) %>%
    ggplot(aes(x=fqz, group=YEAR, fill=YEAR, alpha=.5)) +
    geom_density() + 
    scale_alpha(guide=FALSE) + 
    labs(x="5q0", title="5q0 Density across Municipalities")

for(i in 2000:2015){
    plot_i <- DF5q0 %>% filter(YEAR == i) %>%
        mutate(YEAR=as.factor(YEAR)) %>%
        ggplot(aes(x=fqz, group=YEAR, fill=YEAR, alpha=.5)) +
        geom_density() + 
        scale_alpha(guide=FALSE) + 
        labs(x="5q0", title="5q0 Density across Municipalities") + 
        lims(x=c(0, .1), y=c(0, 95))
    print(plot_i)
}

DF5q0_diff <- DF5q0 %>% filter(YEAR == 2000 | YEAR == 2015) %>% 
    group_by(GEOID) %>% summarise(fqz_diff=nth(fqz, 2) - nth(fqz, 1)) %>%
    arrange(fqz_diff)
    
DF5q0_diff %>% ggplot(aes(x=fqz_diff, fill=1, alpha=.5)) +
    geom_density() + 
    scale_alpha(guide=FALSE) + scale_fill_continuous(guide=FALSE) + 
    labs(x="5q0 Change over 15 years", 
         title="5q0 Change across Municipalities")

DT %>% filter(GEOID %in% head(DF5q0_diff$GEOID, 9)) %>%
    ggplot(aes(x=YEAR, y=log(Ratem1*ADJ), group=EDAD, color=EDAD, fill=EDAD,
               ymin=log(lwr), ymax=log(upr))) + 
    geom_line() + geom_ribbon(alpha=.3) + facet_wrap(~GEOID)

DT %>% filter(GEOID %in% tail(DF5q0_diff$GEOID, 9)) %>%
    ggplot(aes(x=YEAR, y=log(Ratem1*ADJ), group=EDAD, color=EDAD, fill=EDAD,
               ymin=log(lwr), ymax=log(upr))) + 
    geom_line() + geom_ribbon(alpha=.3) + facet_wrap(~GEOID)

DF5q0 %>% filter(GEOID %in% head(DF5q0_diff$GEOID, 9)) %>%
    ggplot(aes(x=YEAR, y=fqz, ymin=fqzl, ymax=fqzh)) + 
    geom_line() + geom_ribbon(alpha=.3) + facet_wrap(~GEOID)

DF5q0 %>% filter(GEOID %in% tail(DF5q0_diff$GEOID, 9)) %>%
    ggplot(aes(x=YEAR, y=fqz, ymin=fqzl, ymax=fqzh)) + 
    geom_line() + geom_ribbon(alpha=.3) + facet_wrap(~GEOID)

save(MRarray, MRdraws, DF5q0, DF5q0_diff, q0array, Ddraws, 
     file="~/Documents/MXU5MR/analysis/outputs/uncertainty_draws.Rdata")
