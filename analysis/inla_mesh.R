rm(list=ls())
pacman::p_load(INLA, INSP, rgeos)

head(mx.sp.df@data)
centroids <- gCentroid(mx.sp.df, byid=TRUE)@coords
mesh <- inla.mesh.create(centroids)
spde <- inla.spde2.matern(mesh)

