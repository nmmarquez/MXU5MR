rm(list = ls())

url_ <- "http://www.dgis.salud.gob.mx/descargas/zip/BD_Nacimientos_#.zip"
url15 <- "http://www.dgis.salud.gob.mx/descargas/zip/SINAC_CIERRE_2015_SDP.zip"
save_dir <- "~/Documents/MXU5MR/nacimientos/data/dgis"
urls <- c(sapply(2008:2014, function(x) gsub("#", x, url_)), url15)

tempfiles <- sapply(1:length(urls), function(x) tempfile())
extr_dir <- tempdir()

mapply(download.file, urls, tempfiles)

# unzip los archivos
lapply(tempfiles, unzip, exdir=extr_dir)


# crear un objeto con todos los nuevo archivos
tmpdirfiles <- list.files(extr_dir, full.names=TRUE)

datafiles <- grep(".mdb", tmpdirfiles, value=TRUE)
mvloc <- gsub(extr_dir, save_dir, datafiles)

file.rename(datafiles, mvloc)

