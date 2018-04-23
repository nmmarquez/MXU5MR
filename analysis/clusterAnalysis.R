rm(list=ls())

### Questions to answe in this script
# Where are the significant clusters of change
# How do they Compare to clusters of little change
# Where are the high Values in 2015 
# How do they compare in there temporal trend to low values
# Examination of clusters looks like there are hi values in 2015 that were also 
# hi in 2000, is there a way to test signficant change of placement
# What counties have had the greatest impact in the change


pacman::p_load(INLA, TMB, raster, data.table, ggplot2, dplyr, dtplyr, ineq, 
               INSP, surveillance, clusterPower, rvest, spdep, plotly, tidyr,
               stringr)

setwd("~/Documents/MXU5MR/analysis/outputs/")
load("./uncertainty_draws.Rdata")
load("../../IHMEanlaysis/adjust.Rdata")
load("../../IHMEanlaysis/df_mxstate.RData")
U1state <- rename(U1state, YEAR=year)
U5state <- rename(U5state, YEAR=year)
DT <- fread("./model_phi_full.csv") %>% as.data.frame

DFName <- mx.sp.df@data %>%
    mutate(GEOID=as.numeric(GEOID)) %>%
    left_join(rename(df_mxstate, CVE_ENT=region)) %>%
    rename(Municipality=NOM_MUN, State=state_name_official) %>%
    select(GEOID, Municipality, State)

DFpop <- DT %>%
    filter(POPULATION != 0) %>%
    select(GEOID, YEAR, EDAD, POPULATION) %>%
    group_by(GEOID, EDAD) %>%
    summarize(Zpop=min(POPULATION)) %>%
    right_join(subset(DT, select=c(GEOID, EDAD, YEAR, POPULATION, DEATHS))) %>%
    mutate(POPULATION=ifelse(POPULATION == 0, Zpop, POPULATION)) %>%
    select(-Zpop) %>%
    ungroup %>%
    mutate(ENT_RESID=as.numeric(str_sub(sprintf("%05d", GEOID), 1, 2))) %>%
    mutate(RateAdj=apply(MRdraws, 1, mean)) %>%
    left_join(subset(U1state, select=c(ENT_RESID, YEAR, U1AdjPop))) %>% 
    left_join(subset(U5state, select=c(ENT_RESID, YEAR, U5AdjPop))) %>%
    mutate(AdjPop=ifelse(EDAD==0, U1AdjPop, U5AdjPop)) %>%
    mutate(Population=POPULATION * AdjPop) %>%
    select(GEOID, EDAD, YEAR, Population, RateAdj) %>%
    mutate(RateAdjL=apply(MRdraws, 1, quantile, probs=.025)) %>%
    mutate(RateAdjH=apply(MRdraws, 1, quantile, probs=.975)) %>%
    as.data.frame

MEXlistw <- poly2nb(mx.sp.df, queen=TRUE) %>% nb2listw

tidymap <- fortify(mx.sp.df) %>% mutate(id=as.numeric(id)) %>%
    left_join(mx.sp.df@data %>% mutate(id=0:(nrow(mx.sp.df)-1)), by="id") %>%
    mutate(GEOID=as.numeric(GEOID))

DF5q0_delta <- mx.sp.df@data %>%
    select(GEOID) %>%
    mutate(GEOID=as.numeric(GEOID)) %>%
    left_join(DF5q0_diff, by="GEOID") %>%
    mutate(pLocal=localmoran(fqz_diff, MEXlistw)[,"Pr(z > 0)"]) %>% 
    mutate(pSig=pLocal < .05) %>%
    mutate(laggedFQZDiff=lag.listw(MEXlistw, fqz_diff)) %>% 
    mutate(Neighbors=sapply(MEXlistw$weights, length)) %>%
    mutate(Cluster=ifelse(
        fqz_diff < mean(fqz_diff) & laggedFQZDiff < mean(fqz_diff), 
        "Great Change", "Little Change")) %>%
    mutate(Cluster=ifelse(pSig, Cluster, NA)) %>%
    mutate(pAlpha=ifelse(pSig, .4, .35))

p <- DF5q0_delta %>%
    ggplot(aes(x=fqz_diff, y=laggedFQZDiff, alpha=pAlpha, color=Cluster)) + 
    geom_point() + 
    labs(title="Lisa Examination of Clusters", 
         x="Change in 5q0", y="Lagged Change in 5q0") + 
    scale_alpha_continuous(guide=F) +
    geom_hline(yintercept=mean(DF5q0_delta$fqz_diff), linetype=2, alpha=.6) + 
    geom_vline(xintercept=mean(DF5q0_delta$fqz_diff), linetype=2, alpha=.6)

ggplotly(p)

p2 <- DF5q0_delta %>% left_join(tidymap, by="GEOID") %>% 
    ggplot(aes(x=long, y=lat)) +
    theme_classic() + 
    geom_polygon(aes(group=group, fill = Cluster)) + 
    theme(axis.line = element_blank(),
          legend.title=element_blank(), axis.text=element_blank(),
          axis.ticks=element_blank(), axis.title=element_blank(),
          title=element_text(size=26)) + 
    labs(title="Significant Cluster By Location")

p2

# 12028 and neighbors
gChange <- DF5q0_delta %>% arrange(laggedFQZDiff) %>% head(10) %>%
    filter(max(Neighbors) == Neighbors) %>% select(GEOID) %>% unlist

lChange <- DF5q0_delta %>% arrange(-laggedFQZDiff) %>% head(10) %>%
    filter(max(Neighbors) == Neighbors) %>% select(GEOID) %>% unlist


gCluster <- MEXlistw$neighbours[[which(mx.sp.df$GEOID == gChange)]] %>%
    mx.sp.df$GEOID[.] %>% as.numeric %>% c(gChange[[1]])

lCluster <- MEXlistw$neighbours[[which(mx.sp.df$GEOID == lChange)]] %>%
    mx.sp.df$GEOID[.] %>% as.numeric %>% c(lChange[[1]])

p <- DF5q0 %>% filter(GEOID %in% c(gCluster, lCluster)) %>% 
    mutate(Change=ifelse(GEOID %in% gCluster, "Great", "Little")) %>%
    as.data.frame() %>%
    ggplot(aes(x=YEAR, y=fqz, ymin=fqzl, ymax=fqzh, group=GEOID, 
               color=Change, fill=Change)) +
    geom_line() + geom_ribbon(alpha=.2, linetype=2)

p

DF5q0_2015 <- mx.sp.df@data %>%
    select(GEOID) %>%
    mutate(GEOID=as.numeric(GEOID)) %>%
    left_join(subset(DF5q0, YEAR == 2015), by="GEOID") %>%
    mutate(pLocal=localmoran(fqz, MEXlistw)[,"Pr(z > 0)"]) %>% 
    mutate(pSig=pLocal < .05) %>%
    mutate(laggedFQZ=lag.listw(MEXlistw, fqz)) %>% 
    mutate(Neighbors=sapply(MEXlistw$weights, length)) %>%
    mutate(Cluster=ifelse(
        fqz < mean(fqz) & laggedFQZ < mean(fqz), 
        "Lo 5q0", "Hi 5q0")) %>%
    mutate(Cluster=ifelse(pSig, Cluster, NA)) %>%
    mutate(pAlpha=ifelse(pSig, .4, .35))

DF5q0_2015 %>%
    ggplot(aes(x=fqz, y=laggedFQZ, alpha=pAlpha, color=Cluster)) + 
    geom_point() + 
    labs(title="Lisa Examination of Clusters", 
         x="5q0", y="Lagged 5q0") + 
    scale_alpha_continuous(guide=F) +
    geom_hline(yintercept=mean(DF5q0_2015$fqz), linetype=2, alpha=.6) + 
    geom_vline(xintercept=mean(DF5q0_2015$fqz), linetype=2, alpha=.6)

DF5q0_2015 %>% left_join(tidymap, by="GEOID") %>% 
    ggplot(aes(x=long, y=lat)) +
    theme_classic() + 
    geom_polygon(aes(group=group, fill = Cluster)) + 
    theme(axis.line = element_blank(),
          legend.title=element_blank(), axis.text=element_blank(),
          axis.ticks=element_blank(), axis.title=element_blank(),
          title=element_text(size=26)) + 
    labs(title="Significant Cluster By Location")

p4 <- DF5q0_2015 %>% arrange(fqz) %>%
    filter(row_number() %in% 1:5 | row_number() %in% (n()-4):(n())) %>%
    select(GEOID, Cluster) %>%
    left_join(DF5q0) %>%
    left_join(summarize(group_by(DFpop, GEOID, YEAR), Pop=sum(Population))) %>%
    left_join(DFName) %>%
    ggplot(aes(x=YEAR, y=fqz, ymin=fqzl, ymax=fqzh, group=GEOID, 
               color=Cluster, fill=Cluster,
               text=paste("State: ", State, "\n",
                          "Municiplaity: ", Municipality, "\n",
                          "Population: ", Pop, "\n",
                          "FQZ: ", fqz, "\n",
                          "Year: ", YEAR))) +
    geom_line() + geom_ribbon(alpha=.2, linetype=2)

ggplotly(p4, tooltip="text")

DFCompDelta <- DFpop %>% as.data.frame %>%
    group_by(GEOID, YEAR) %>%
    summarize(Population=sum(Population)) %>%
    filter(YEAR %in% c(2000, 2015)) %>%
    left_join(as.data.frame(DF5q0), by=c("GEOID", "YEAR")) %>%
    select(-fqzl, -fqzh) %>%
    gather(variable, value, -(GEOID:YEAR)) %>%
    unite(temp, variable, YEAR) %>%
    spread(temp, value) %>%
    ungroup %>%
    mutate(Population_2000=Population_2000/sum(Population_2000)) %>%
    mutate(Population_2015=Population_2015/sum(Population_2015)) %>%
    mutate(grossI=(fqz_2015+fqz_2000)*.5*(Population_2015-Population_2000)) %>%
    mutate(residI=(Population_2015+Population_2000)*.5*(fqz_2015-fqz_2000)) %>%
    mutate(totI=grossI + residI) %>%
    arrange(totI/Population_2015) %>%
    left_join(subset(DFName, select=c(GEOID, State, Municipality)))

summary(DFCompDelta)
tots <- sum(DFCompDelta$residI) + sum(DFCompDelta$grossI)
sum(DFCompDelta$residI) / tots
sum(DFCompDelta$grossI) / tots

DFCompDelta %>% filter(residI>0) %>% arrange(-totI) %>% head(n=20)
hiImpact <- DFCompDelta$GEOID[1:20][DFCompDelta$GEOID[1:20] %in% 
          (DF5q0_delta %>% filter(Cluster=="Great Change"))$GEOID][1]
iCluster <- MEXlistw$neighbours[[which(mx.sp.df$GEOID == hiImpact)]] %>%
    mx.sp.df$GEOID[.] %>% as.numeric %>% c(hiImpact)

with(DFCompDelta, data.frame(Population=cumsum(Population_2015),
                             Contribution=cumsum(totI) /sum(totI))) %>%
    ggplot(aes(x=Population, y=Contribution)) + 
    geom_line() + 
    geom_abline(linetype=2) + 
    theme_classic()

DFCompDelta %>%
    ggplot(aes(x=fqz_2000, y=fqz_2015, color=State)) + geom_point() +
    lims(x=c(0, .126), y=c(0, .126))

DFCompDelta %>%
    mutate(fqzScale_2000=scale(fqz_2000), fqzScale_2015=scale(fqz_2015)) %>%
    ggplot(aes(x=fqzScale_2000, y=fqzScale_2015, color=State)) + 
    geom_point()

DFCompDelta %>%
    mutate(fqzScale_2000=scale(fqz_2000), fqzScale_2015=scale(fqz_2015)) %>%
    with(cor(fqzScale_2000, fqzScale_2015))

DFCompDelta %>%
    with(cor(fqz_2000, fqz_2015))

corDist <- apply(q0array[,c(1,16),], c(2,3), scale) %>% 
    apply(3, function(x) cor(x[,1], x[,2]))
summary(corDist)

corReal <- q0array[,c(1,16),] %>%
    apply(3, function(x) cor(x[,1], x[,2]))

summary(corReal)

apply(q0array[,c(1,16),], c(1,2), median) %>% 
    as.data.frame %>%
    with(cor(V1, V2))
z