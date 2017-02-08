################################################################################
# Code to download mortality and birth data from inegi website. Creates a 
# temporary directory to unzip file into and extracts only the corresponding
# data file leaving all others behind
################################################################################
rm(list=ls())

# Cambia esta linea por el lugar queres guardar los datos
save_dir <- "~/Downloads/lesson4"

# Cambia el lugar por el codigo para correr
setwd(save_dir)

# pone los anos queres descargar
years <- 2014:2015 # el primero ano ques es possible es 2011 el ultimo es 2015

# inegi home url
home <- "http://www.beta.inegi.org.mx/contenidos/proyectos/registros/vitales/"

# extension para defunciones
murl <- "mortalidad/microdatos/defunciones/#/defunciones_base_datos_#_dbf.zip"
# extension para nacimientos
nurl <- "natalidad/microdatos/#/natalidad_base_datos_#_dbf.zip"

# combinar el extension con el home url
urlbase <- sapply(c(murl, nurl), function(x) paste0(home,x))

# crear un vector con todo de los urls
urls <- sapply(urlbase, function(y) sapply(years, function(x) gsub("#", x, y)))
urls <- c(urls)

# crear espacio para descargar los archivos
tempfiles <- sapply(1:length(urls), function(x) tempfile())
extr_dir <- tempdir()

# DOWNLOAD FILES ESTE PARTE TOMA IN TIEMPO LARGO Y NECCESITA UN BIEN 
# CONNEXION CON LA RED
mapply(download.file, urls, tempfiles)

# unzip los archivos
lapply(tempfiles, unzip, exdir=extr_dir)

# crear un objeto con todos los nuevo archivos
tmpdirfiles <- list.files(extr_dir, full.names=TRUE)

# solo guardar los archivos que tienen la palabrs NACIM o DEFUN
datafiles <- grep("/NACIM|/DEFUN", tmpdirfiles, value=TRUE)

# mover los archivos en el `save_dir`
mvloc <- gsub(extr_dir, save_dir, datafiles)
mvloc <- gsub(".DBF", ".dbf", mvloc)
file.rename(datafiles, mvloc)

# elminar los archivos temporal
sapply(tempfiles, unlink)
unlink(extr_dir)
