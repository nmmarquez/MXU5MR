rm(list=ls())
pacman::p_load(Hmisc, data.table)

vars <- c("fech.nach", "fech.cert", "ent.res",  "mpo.res", "atendio", "sexoh")
files <- list.files("~/Documents/MXU5MR/nacimientos/data/dgis/", pattern=".mdb",
                    full.names=TRUE)


DT <- rbindlist(lapply(files, function(x) 
    mdb.get(x, "NACIMIENTO", TRUE, stringsAsFactors=TRUE)[, vars]))

DT[,ano:=sapply(strsplit(as.character(fech.nach), "/"), function(x) 
    as.integer(x[[length(x)]]))]
DT[,ano.regis:=sapply(strsplit(as.character(fech.cert), "/"), function(x) 
    as.integer(x[[length(x)]]))]
DT[,regis.diff:=ano.regis - ano]
DT[,ent.res:=sprintf("%02d", ent.res)]
DT[,mpo.res:=sprintf("%03d", mpo.res)]
DT[,GEOID:=paste0(ent.res, mpo.res)]

fwrite(DT, "~/Documents/MXU5MR/nacimientos/outputs/mdbirthsdgis.csv")
