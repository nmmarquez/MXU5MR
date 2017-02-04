################################################################################
# Clean birth data to use for  preliminary exploritory analysis and then 
# analaysis of population estimates to be used in U5MR model
################################################################################
rm(list=ls())
pacman::p_load(foreign, data.table, ggplot2, INSP, dplyr, plotly)

### 1) load in the data
data_home <- "~/Documents/MXU5MR/defunciones/data/"
years <- as.character(2011:2015)
abv_year <- sapply(strsplit(years, ""), function(x) paste0(x[3], x[4]))
fpaths <- paste0(data_home, "defunc", years, "/DEFUN", abv_year, ".dbf")

var_names <- c("SEXO", "ENT_RESID", "MUN_RESID", "ENT_OCURR", "MUN_OCURR", 
               "EDAD", "ANIO_REGIS", "ANIO_OCUR")

deaths <- rbindlist(lapply(fpaths, function(x) 
    subset(read.dbf(x, as.is=TRUE), select=var_names)))

head(deaths)
