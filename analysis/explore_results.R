rm(list=ls())

pacman::p_load(INLA, TMB, data.table, ggplot2, dplyr, dtplyr, ineq, INSP, 
               surveillance, clusterPower, rvest)

setwd("~/Documents/MXU5MR/analysis/outputs/")
load("./uncertainty_draws.Rdata")
DT <- fread("./model_phi_full.csv")

DT[,sterror:=apply(MRdraws, 1, sd)]
DT[,lwr:=apply(MRdraws, 1, function(x) quantile(x, probs=.025))]
DT[,upr:=apply(MRdraws, 1, function(x) quantile(x, probs=.975))]

popreq <- 1000
prGEOID <- DT %>% filter(YEAR==2014 & EDAD == 0 & POPULATION > popreq) %>%
    select(GEOID) %>% unlist

highest2015 <- subset(DF5q0, YEAR == 2015 & GEOID %in% prGEOID) %>% 
    arrange(-fqz) %>% select(GEOID) %>% unlist %>% head(12)

lowest2015 <- DF5q0 %>% filter(YEAR == 2000 | YEAR == 2015) %>%
    filter(GEOID %in% prGEOID) %>%
    group_by(GEOID) %>% summarize(deltafqz=nth(fqz, 2) - nth(fqz, 1)) %>% 
    arrange(deltafqz) %>% select(GEOID) %>% unlist %>% head(12)

DF5q0 %>% filter(GEOID %in% highest2015) %>%
    ggplot(aes(x=YEAR, y=fqz, ymin=fqzl, ymax=fqzh)) + 
    geom_line() + geom_ribbon(alpha=.3) + facet_wrap(~GEOID)

high_ref <- 8050
high_ref_name <- mx.sp.df@data[mx.sp.df@data$muni == high_ref, "NOM_MUN"] %>% 
    as.character %>% paste0(", Chihuahua")

DF5q0 %>% filter(GEOID %in% lowest2015) %>%
    ggplot(aes(x=YEAR, y=fqz, ymin=fqzl, ymax=fqzh)) + 
    geom_line() + geom_ribbon(alpha=.3) + facet_wrap(~GEOID)

low_ref <- 21110
low_ref_name <- mx.sp.df@data[mx.sp.df@data$muni == low_ref, "NOM_MUN"] %>% 
    as.character %>% paste0(", Puebla")


natdraws <- Ddraws[,lapply(.SD, sum), by=list(EDAD, YEAR)]
cols <- names(Ddraws)[grepl("sample", names(Ddraws))]
natdraws[ , (cols) := lapply(.SD, `/`, POPULATION), .SDcols = cols]
natdraws[,POPULATION:=NULL]
natdraws[,EDAD:=NULL]
natdraws <- natdraws[,lapply(.SD, function(x) 1-prod(1-x)), by=YEAR]
natdraws[,m_:=apply(as.matrix(subset(natdraws, select=cols)), 1, mean)]
natdraws[,l_:=apply(as.matrix(subset(natdraws, select=cols)), 1, 
                    quantile, probs=.025)]
natdraws[,h_:=apply(as.matrix(subset(natdraws, select=cols)), 1, 
                    quantile, probs=.975)]

state_ids <- DT$GEOID %>% substr(. , 1, nchar(.)-3) %>% as.numeric

samps <- paste0("sample", 1:1000)

state_draws <- Ddraws %>% data.frame %>%
    mutate(GEOID=state_ids) %>%
    group_by(GEOID, EDAD, YEAR) %>% summarise_all(sum) %>% ungroup %>%
    mutate_at(grep("sample", names(.), value=T), function(x) x/.$POPULATION) %>%
    group_by(GEOID, YEAR) %>% summarise_all(function(x) 1 - prod(1-x)) %>% 
    select(-POPULATION, -EDAD)

state_draws$fqz <- state_draws[, samps] %>% rowMeans
state_draws$fqzl <- apply(state_draws[, samps], 1, quantile, probs=.025)
state_draws$fqzh <- apply(state_draws[, samps], 1, quantile, probs=.975)

state_draws <- state_draws %>% select(GEOID, YEAR, fqzl, fqz, fqzh) %>% ungroup

state_draws %>%
    ggplot(aes(x=YEAR, y=fqz, ymin=fqzl, ymax=fqzh)) + 
    geom_line() + geom_ribbon(alpha=.3) + facet_wrap(~GEOID)

DF5q0 %>% filter(GEOID>=10000 & GEOID<11000) %>%
    ggplot(aes(x=YEAR, y=fqz, ymin=fqzl, ymax=fqzh)) + 
    geom_line() + geom_ribbon(alpha=.3) + facet_wrap(~GEOID)

all_level_5q0 <- natdraws %>% select(m_, l_, h_, YEAR) %>%
    rename("fqz"="m_", "fqzl"="l_", "fqzh"="h_") %>% 
    select(YEAR, fqz, fqzl, fqzh) %>%
    mutate(GEOID=0) %>% rbind(state_draws) %>% rbind(DF5q0) %>% as.data.frame

# https://github.com/diegovalle/mxmaps/blob/master/data/df_mxstate.RData?raw=true
load("~/Downloads/df_mxstate.RData")

DFstate <- df_mxstate %>% select(state_name, region) %>% 
    rename("CVE_ENT"="region", "state"="state_name")
save(all_level_5q0, mx.sp.df, DFstate, file="all_level_5q0.Rdata")

labs <- c("Nacional", "Nuevo Casas Grandes\nChihuahua", 
          "Palmar de Bravo\nPuebla")

jpeg("~/Documents/MXU5MR/analysis/plots/compare5q0natmuni.jpg")
natdraws %>% select(m_, l_, h_, YEAR) %>% 
    rename("fqz"="m_", "fqzl"="l_", "fqzh"="h_") %>% 
    mutate(loc="Nacional", GEOID=0) %>%
    rbind(DF5q0 %>% filter(GEOID == high_ref) %>% mutate(loc=high_ref_name)) %>%
    rbind(DF5q0 %>% filter(GEOID == low_ref) %>% mutate(loc=low_ref_name)) %>%
    ggplot(aes(x=YEAR, y=fqz, ymin=fqzl, ymax=fqzh, 
               group=loc, color=loc, fill=loc)) + 
    geom_line() + geom_ribbon(alpha=.3) + 
    scale_fill_discrete(name="Location", labels=labs) + 
    scale_color_discrete(name="Location", labels=labs) + 
    labs(y="Year", x="5q0", title="Temporal Change in 5q0")
dev.off()
