rm(list=ls())
home <- paste0("http://www.beta.inegi.org.mx/contenidos/proyectos/registros/",
               "vitales/mortalidad/microdatos/defunciones")

syf <- paste0(home, "/%y%/defunciones_base_datos_%y%_dbf.zip")
myf <- paste0(home, "/datos/defunciones_generales_base_datos_%s%_%e%_dbf.zip")

sy <- sapply(2010:2015, function(x) gsub("%y%", x, syf))
my <- sapply(seq(1990, 2005, 5), function(x) 
    gsub("%e%", x+4, gsub("%s%", x, myf)))
urls <- c(sy, my)

tempfiles <- sapply(1:length(urls), function(x) tempfile())
extr_dir <- "~/Downloads/tmp"
save_dir <- "~/Documents/MXU5MR/defunciones/data/inegi/"

mapply(download.file, urls, tempfiles)

# unzip los archivos
lapply(tempfiles, unzip, exdir=extr_dir)


# crear un objeto con todos los nuevo archivos
tmpdirfiles <- list.files(extr_dir, full.names=TRUE, recursive=TRUE)

datafiles <- grep("DEFUN", tmpdirfiles, value=TRUE)
exts <- sapply(datafiles, function(x) 
    strsplit(x, "/")[[1]][length(strsplit(x, "/")[[1]])])
exts <- gsub(".DBF", ".dbf", exts)
mvloc <- paste0(save_dir, exts)

file.rename(datafiles, mvloc)

sapply(tempfiles, unlink)
unlink(extr_dir)
