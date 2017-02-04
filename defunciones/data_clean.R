################################################################################
# Clean birth data to use for  preliminary exploritory analysis and then 
# analaysis of population estimates to be used in U5MR model
################################################################################
rm(list=ls())
pacman::p_load(foreign, data.table, ggplot2, INSP, dplyr, plotly)

### 1) load in the data
data_home <- "~/Documents/MXU5MR/defunciones/data/"
years <- as.character(2012:2015)
abv_year <- sapply(strsplit(years, ""), function(x) paste0(x[3], x[4]))
fpaths <- paste0(data_home, "defunc", years, "/DEFUN", abv_year, ".dbf")

births <- rbindlist(lapply(fpaths, function(x) read.dbf(x, as.is=TRUE)))