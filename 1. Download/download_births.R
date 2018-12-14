rm(list = ls())

base <- "http://www.beta.inegi.org.mx/contenidos/proyectos/registros/vitales/"
url_ <- paste0(base, "natalidad/microdatos/#/natalidad_base_datos_#_dbf.zip")
save_dir <- "./Data/births/"
urls <- sapply(1985:2016, function(x) gsub("#", x, url_))

tempfiles <- sapply(1:length(urls), function(x) tempfile())
extr_dir <- tempdir()

mapply(download.file, urls, tempfiles)

# unzip los archivos
lapply(tempfiles, unzip, exdir=extr_dir)


# crear un objeto con todos los nuevo archivos
tmpdirfiles <- list.files(extr_dir, full.names=TRUE)

datafiles <- grep("\\.dbf", tmpdirfiles, value=TRUE)
(mvloc <- gsub(extr_dir, save_dir, datafiles))

file.rename(datafiles, mvloc)

sapply(tempfiles, unlink)
unlink(extr_dir)
