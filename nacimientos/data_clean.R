################################################################################
# Clean birth data to use for  preliminary exploritory analysis and then
# analaysis of population estimates to be used in U5MR model
################################################################################
rm(list=ls())
pacman::p_load(foreign, data.table, ggplot2, INSP, dplyr, plotly, sp, spdep, leaflet, rgdal)

### 1) load in the data
data_home <- "~/Documents/MXU5MR/nacimientos/data/inegi/"
years <- as.character(1985:2015)
abv_year <- sapply(strsplit(years, ""), function(x) paste0(x[3], x[4]))
#fpaths <- paste0(data_home, "natalidad", years, "/NACIM", abv_year, ".dbf")
fpaths <- paste0(data_home, "/NACIM", abv_year, ".dbf")
var_names <- c("SEXO", "ANO_REG", "ANO_NAC", "ENT_RESID", "MUN_RESID",
               "ENT_REGIS", "MUN_REGIS")
births <- rbindlist(lapply(fpaths, function(x)
    subset(read.dbf(x, as.is=TRUE), select=var_names)))
births <- subset(births, ANO_NAC <= 2015 & ANO_NAC >= 2000)

births[,ENT_REGIS:=sprintf("%02d", as.integer(ENT_REGIS))]
births[,ENT_RESID:=sprintf("%02d", as.integer(ENT_RESID))]
births[,MUN_REGIS:=sprintf("%03d", as.integer(MUN_REGIS))]
births[,MUN_RESID:=sprintf("%03d", as.integer(MUN_RESID))]
births[,REGIS_DIFF:=ANO_REG != ANO_NAC]
births[,REGIS_DIFFN:=ANO_REG - ANO_NAC]
births[,GEOID:=paste0(ENT_RESID, MUN_RESID)]

### graph some of teh anomilies in the data
# 1) for a given year of data what are the years of births
ggplot(data=births, aes(x=ANO_NAC, fill=as.factor(ANO_NAC))) + geom_bar() +
    facet_wrap(~ANO_REG) + theme(legend.position="none")

# 2) How many munis are missing by state(is there state bias?)
ggplot(data=births, aes(x=(MUN_RESID != "999"))) + geom_bar() +
    facet_wrap(~ENT_REGIS, scales="free") + labs(x="Has Resid Muni Data")

# 3) map some of the interesting geographic variables
missdf <- births[, mean(REGIS_DIFFN), by=GEOID]
setnames(missdf, names(missdf), c("GEOID","REG_DIFFN"))
logdf <-  births[,log(.N),by=GEOID]
setnames(logdf, names(logdf), c("GEOID","log_birth"))

mx.sp.df@data <- left_join(mx.sp.df@data, missdf)
mx.sp.df@data <- left_join(mx.sp.df@data, logdf)
mx.sp.df@data <- left_join(mx.sp.df@data, births[,.N,by=GEOID])

#spdf2leaf(mx.sp.df, col="REG_DIFFN", label="Registration <br>Time (Years)")
#spdf2leaf(mx.sp.df, col="N", label="Birth<br>Count")
#spdf2leaf(mx.sp.df, col="log_birth", label="Log Birth<br>Count")

# 4) Correlation between delay in registering birth and pop count in an area
gg1 <- ggplot(data=mx.sp.df@data,
              aes(x=log_birth, y=REG_DIFFN, label=NOM_MUN)) +
    geom_point(alpha=.6, color="maroon4") +
    stat_smooth(method="glm", method.args=list(family="Gamma"), color="black")
ggplotly(gg1)


# save data
fwrite(births, file="~/Documents/MXU5MR/nacimientos/outputs/mdbirths.csv")
