rm(list=ls())
pacman::p_load(INSP, ggplot2, data.table, dplyr, INLA, rgeos, rgdal)

latlong <- gCentroid(mx.sp.df, byid=T)
mesh <- latlong %>% inla.mesh.create
spde <- inla.spde2.matern(mesh)
plot(mesh)

points(latlong@coords[,"x"], latlong@coords[,"y"], pch=20, col="red")

sigma0 <-  .3   ## Standard deviation
range0 <- 0.2 ## Spatial range
## Convert into tau and kappa:
kappa0 <- sqrt(8)/range0
tau0 <- 1/(sqrt(4*pi)*kappa0*sigma0)

spde <- inla.spde2.matern(mesh)

Q <- inla.spde2.precision(spde, theta=c(log(tau0), log(kappa0)))

spde2 <- inla.spde2.matern(mesh, B.tau=cbind(log(tau0),1,0), 
                          B.kappa=cbind(log(kappa0),0,1),
                          theta.prior.mean=c(0,0), theta.prior.prec=c(0.1,1))
Q2 <- inla.spde2.precision(spde, theta=c(0, 0))

x <- as.vector(inla.qsample(n=1, Q))
proj <- inla.mesh.projector(mesh, xlim=c(-117, -86), ylim=c(14, 33), 
                            dims=c(800,800))


DFproj <- data.table(x=rep(proj$y, times=length(proj$x)), 
                     y=rep(proj$x, each=length(proj$y)), 
                     z=c(inla.mesh.project(proj, field=x[1:mesh$n])))
DFproj <- subset(DFproj, !is.na(z))
ggplot(DFproj, aes(x, y, z=z)) + geom_tile(aes(fill = z)) + theme_bw() + 
    scale_fill_gradientn(colours=topo.colors(10))
