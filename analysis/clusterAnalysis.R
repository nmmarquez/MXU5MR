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
               stringr, gridExtra, reldist, leaflet)

setwd("~/Documents/MXU5MR/analysis/outputs/")
load("./uncertainty_draws.Rdata")
load("../../IHMEanlaysis/adjust.Rdata")
load("../../IHMEanlaysis/df_mxstate.RData")
U1state <- rename(U1state, YEAR=year)
U5state <- rename(U5state, YEAR=year)
DT <- fread("./model_phi_full.csv") %>% as.data.frame
nDraw <- dim(q0array)[3]

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

DFpoptot <- DFpop %>%
    group_by(GEOID, YEAR) %>%
    summarize(Population=sum(Population)) %>%
    ungroup %>%
    right_join(unique(select(DFpop, GEOID, YEAR)))

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
        "Hi", "Lo")) %>%
    mutate(Cluster=ifelse(pSig, Cluster, NA)) %>%
    mutate(pAlpha=ifelse(pSig, .4, .35)) %>%
    mutate(Cluster=as.factor(Cluster)) %>%
    mutate(Cluster=relevel(Cluster, "Lo"))

lisaDelta <- DF5q0_delta %>%
    left_join(subset(DFpoptot, YEAR==2015)) %>%
    ggplot(aes(x=fqz_diff, y=laggedFQZDiff, color=Cluster)) + 
    geom_point(aes(size=Population/max(Population)), alpha=.45) + 
    labs(title="", 
         x="Change in 5q0", y="Lagged Change in 5q0") + 
    geom_hline(yintercept=0, linetype=2, alpha=.6) + 
    geom_vline(xintercept=0, linetype=2, alpha=.6) +
    theme_classic() + 
    scale_size_continuous(guide=FALSE) +
    theme(axis.title=element_text(size=20),
          axis.text=element_text(size=16),
          legend.text=element_text(size=16),
          legend.title=element_text(size=20))

mapDelta <- DF5q0_delta %>% left_join(tidymap, by="GEOID") %>% 
    ggplot(aes(x=long, y=lat)) +
    theme_classic() + 
    geom_polygon(aes(group=group, fill = Cluster)) + 
    theme(axis.line = element_blank(),
          legend.title=element_blank(), axis.text=element_blank(),
          axis.ticks=element_blank(), axis.title=element_blank()) + 
    labs(title="") +
    scale_fill_discrete(guide=FALSE) +
    labs(title="Clusters of Change: 2000-2015") +
    theme(plot.title=element_text(size=24))


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

lisa2015 <- DF5q0_2015 %>%
    left_join(DFpoptot)%>%
    ggplot(aes(x=fqz, y=laggedFQZ, color=Cluster)) + 
    geom_point(aes(size=Population/max(Population)), alpha=.45) + 
    labs(title="", 
         x="5q0", y="Lagged 5q0") + 
    geom_hline(yintercept=.0145, linetype=2, alpha=.6) + 
    geom_vline(xintercept=.0145, linetype=2, alpha=.6) + 
    theme_classic() +
    scale_size_continuous(guide=FALSE) +
    theme(axis.title=element_text(size=20),
          axis.text=element_text(size=16),
          legend.text=element_text(size=16),
          legend.title=element_text(size=20))
    

map2015 <- DF5q0_2015 %>% left_join(tidymap, by="GEOID") %>%
    ggplot(aes(x=long, y=lat)) +
    theme_classic() + 
    geom_polygon(aes(group=group, fill = Cluster)) + 
    theme(axis.line = element_blank(),
          legend.title=element_blank(), axis.text=element_blank(),
          axis.ticks=element_blank(), axis.title=element_blank()) + 
    scale_fill_discrete(guide=FALSE) +
    labs(title="2015 5q0 Clusters") +
    theme(plot.title=element_text(size=24))

ggsave("../plots/lisaplot.png",
    grid.arrange(mapDelta, lisaDelta, map2015, lisa2015))


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

### Inequality Calulation gini
head(DFpoptot)
popArray <- array(DFpoptot$Population, dim=dim(q0array)[1:2])

giniArr <- sapply(
    1:dim(q0array)[2], function(i) sapply(1:nDraw, function(j){
        gini(q0array[,i,j], popArray[,i])
        }))

giniDF <- data.frame(
    meanGini=apply(giniArr, 2, mean),
    l_=apply(giniArr, 2, quantile, probs=.025),
    h_=apply(giniArr, 2, quantile, probs=.975),
    Year = unique(DFpop$YEAR)
)

hivals <- apply(q0array, c(2,3), quantile, .99)
lovals <- apply(q0array, c(2,3), quantile, .01)
relineq <- hivals / lovals
absineq <- hivals - lovals
relineqdiff <- relineq[nrow(relineq),] - relineq[1,]
absineqdiff <- absineq[nrow(absineq),] - absineq[1,]
DTineq <- data.table(year=2000:2015, relineq=apply(relineq, 1, mean),
                     relineqlow=apply(relineq, 1, quantile, probs=.025),
                     relineqhi=apply(relineq, 1, quantile, probs=.975),
                     absineq=apply(absineq, 1, mean),
                     absineqlow=apply(absineq, 1, quantile, probs=.025),
                     absineqhi=apply(absineq, 1, quantile, probs=.975))

ginip <- giniDF %>%
    ggplot(aes(x=Year, y=meanGini, ymin=l_, ymax=h_)) + 
    geom_line() + geom_ribbon(alpha=.3) +  
    theme_classic() +
    labs(x="Year", y="Gini Coefficient") +
    theme(axis.title=element_text(size=20),
          axis.text=element_text(size=16),
          legend.text=element_text(size=16),
          legend.title=element_text(size=20))

pineqR <- ggplot(DTineq, aes(x=year, y=relineq)) + geom_line() +
    geom_ribbon(aes(x=year, ymin=relineqlow, ymax=relineqhi), alpha=.25) +
    labs(x="", y="Relative Inequality") +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme_classic() + 
    scale_y_continuous(labels=function(l) paste0(l, ".00")) +
    theme(axis.title=element_text(size=20),
          axis.text=element_text(size=16),
          legend.text=element_text(size=16),
          legend.title=element_text(size=20))

pineqA <- ggplot(DTineq, aes(x=year, y=absineq)) + geom_line() +
    geom_ribbon(aes(x=year, ymin=absineqlow, ymax=absineqhi), alpha=.25) +
    labs(x="", y="Absolute Inequality", title="5Q0 Inequality") +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme_classic() +
    theme(plot.title=element_text(size=24)) +
    theme(axis.title=element_text(size=20),
          axis.text=element_text(size=16),
          legend.text=element_text(size=16),
          legend.title=element_text(size=20))

## Oaxaca Inequality
oaxIndx <- which(DFName$State == "Oaxaca")
giniArrOax <- sapply(
    1:dim(q0array)[2], function(i) sapply(1:nDraw, function(j){
        gini(q0array[oaxIndx,i,j], popArray[oaxIndx,i])
    }))

giniOaxDF <- data.frame(
    meanGini=apply(giniArrOax, 2, mean),
    l_=apply(giniArrOax, 2, quantile, probs=.025),
    h_=apply(giniArrOax, 2, quantile, probs=.975),
    Year = unique(DFpop$YEAR)
)

giniOaxDF %>%
    ggplot(aes(x=Year, y=meanGini, ymin=l_, ymax=h_)) + 
    geom_line() + geom_ribbon(alpha=.3) +  
    theme_classic() +
    labs(x="Year", y="Gini Coefficient") +
    theme(axis.title=element_text(size=20),
          axis.text=element_text(size=16),
          legend.text=element_text(size=16),
          legend.title=element_text(size=20))
    

iggsave("../plots/ineq.png",
       grid.arrange(pineqA, pineqR, ginip))

Ddraws[,POPULATION:=DFpop$Population]
Ddraws[,GEOID:=DT$GEOID]

natdraws <- Ddraws[,lapply(.SD, sum), by=list(EDAD, YEAR)]
cols <- names(Ddraws)[grepl("sample", names(Ddraws))]
natdraws[ , (cols) := lapply(.SD, `/`, POPULATION), .SDcols = cols]
natdraws[,POPULATION:=NULL]
natdraws[,EDAD:=NULL]
natdraws <- natdraws[,lapply(.SD, function(x) 1-prod(1-x)), by=YEAR]
natdraws[,m_:=apply(as.matrix(subset(natdraws, select=cols)), 1, mean)]
natdraws[,l_:=apply(as.matrix(subset(natdraws, select=cols)), 1, quantile, probs=.025)]
natdraws[,h_:=apply(as.matrix(subset(natdraws, select=cols)), 1, quantile, probs=.975)]

pNat <- ggplot(natdraws, aes(x=YEAR, y=m_)) + geom_line() +
    geom_ribbon(aes(x=YEAR, ymin=l_, ymax=h_), alpha=.25) +
    labs(x="Year", y="5Q0", title="National Estimates of 5Q0") +
    theme(plot.title = element_text(hjust = 0.5)) +
    theme_classic()
pNat

## 5q0 Map 
df <- mx.sp.df
df@data$GEOID <- as.numeric(df@data$GEOID)
col <- "fqz"
df@data <- left_join(df@data, subset(DF5q0, YEAR == 2015)) %>%
    left_join(DFpop %>%
                  group_by(GEOID, YEAR) %>%
                  summarize(Pop=round(sum(Population)))) %>%
    left_join(DFName)

df@data %>% left_join(tidymap, by="GEOID") %>%
    ggplot(aes(x=long, y=lat)) +
    theme_classic() + 
    geom_polygon(aes(group=group, fill=fqz)) + 
    theme(axis.line = element_blank(),
          legend.title=element_text("Test"), axis.text=element_blank(),
          axis.ticks=element_blank(), axis.title=element_blank(),
          legend.justification=c(1,2.9),legend.position=c(.3, .45))+
    scale_fill_distiller(palette="Spectral", name="5q0")

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

pTimeCor <- DFCompDelta %>%
    ggplot(aes(x=fqz_2000, y=fqz_2015)) +
    geom_point(alpha=.22) +
    theme_classic() +
    xlab("2000 5q0") + ylab("2015 5q0") +
    ggtitle("Mexico Municipalities Change in 5q0") +
    lims(x=c(0, .125), y=c(0, .125)) +
    geom_abline(linetype=2)

pTimeCor

pDecomp <- with(DFCompDelta,
                data.frame(Population=cumsum(Population_2015),
                           Contribution=cumsum(totI) /sum(totI))) %>%
    ggplot(aes(x=Population, y=Contribution)) +
    geom_line() +
    labs(y="Contribution to Total Change",
         title="Population Contribution to Percent Total Change") +
    geom_abline(linetype=2) +
    theme_classic() +
    theme(plot.title=element_text(size=24)) +
    theme(axis.title=element_text(size=20),
          axis.text=element_text(size=16),
          legend.text=element_text(size=16),
          legend.title=element_text(size=20))

ggsave("../plots/contribDelta.png",
       pDecomp)

## Oaxaca
nrow(filter(DFName, State == "Oaxaca")) / nrow(DFName)

countN <- 30

arrange(DF5q0_2015, fqz) %>% left_join(DFName) %>% 
    head(n=countN) %>% filter(State=="Oaxaca") %>% 
    nrow %>% `/`(countN)

arrange(DF5q0_2015, -fqz) %>% left_join(DFName) %>% 
    head(n=countN) %>% filter(State=="Oaxaca") %>% 
    nrow %>% `/`(countN)
