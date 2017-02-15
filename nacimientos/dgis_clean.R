rm(list=ls())
pacman::p_load(Hmisc, data.table)

vars <- c("fech.nach", "fech.cert", "ent.res",  "mpo.res", "atendio", "sexoh")
files <- list.files("~/Documents/MXU5MR/nacimientos/data/dgis/", pattern=".mdb",
                    full.names=TRUE)


data <- rbindlist(lapply(files, function(x) mdb.get(x, "NACIMIENTO", T)[,vars]))
