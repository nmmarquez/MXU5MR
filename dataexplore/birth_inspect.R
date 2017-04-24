rm(list=ls())
pacman::p_load(data.table, INSP, ggplot2, dplyr, dtplyr, plotly)

# lets only load in data from one version type and just births since they are 
# all the same at this point
demog <- subset(fread("~/Documents/MXU5MR/defunciones/outputs/demog.csv"), 
                EDADV==1 & YEAR > 2011)
demog[,GEOID:=sprintf("%05d", GEOID)]

# first thing we wanna do is look at how birth population differes at nat lvl


nat <- demog[,list(pop=sum(POPULATION), pop2=sum(POPULATION2), 
                   death=sum(DEATHS)), by=list(YEAR, EDAD)]
nat[,psa:=1 - (death / pop)]
nat[,psa2:=1 - (death / pop2)]
# compare this to the viz tool on mortality
nat[,list(q5=1-prod(psa), q52=1-prod(psa2)), by=YEAR]
nat

state <- demog[,list(pop=sum(POPULATION), pop2=sum(POPULATION2), 
                   death=sum(DEATHS)), by=list(YEAR, EDAD, ENT_RESID)]
state[,psa:=1 - (death / pop)]
state[,psa2:=1 - (death / pop2)]
# compare this to the viz tool oin mortality
state5q0 <- state[,list(q5=1-prod(psa), q52=1-prod(psa2)), by=list(YEAR, ENT_RESID)]
summary(state5q0)

ihme5q0 <- fread("/home/j/WORK/02_mortality/04_outputs/02_results/gbd2015 final results/final_with_shock/as_withshock.csv")
ihme5q0 <- subset(ihme5q0, sex_id == 3 & location_id >= 4643 & age_group_id == 1 &
                           location_id <= 4674 & year_id %in% 2012:2015)
ihme5q0[,YEAR:=year_id]
ihme5q0[,ENT_RESID:=1 + location_id - min(location_id)]
ihme5q0

mexnames <- fread("~/Downloads/mexnames.csv")
all5q0 <-as.data.table(left_join(left_join(ihme5q0, state5q0), mexnames))



ggplotly(ggplot(subset(all5q0, YEAR != 2015), aes(x=qx_mean, y=q5)) + 
             geom_point(aes(text=paste0("Loc: ", location_name,
                                        "<br>qx: ", qx_mean, "<br>qx_low: ", 
                                        qx_lower, "<br>qx_upper: ", qx_upper, 
                                        "<br> inegi: ", q5))) + geom_abline())


ggplotly(ggplot(subset(all5q0), aes(x=qx_mean, y=q52)) + 
             geom_point(aes(text=paste0("Loc: ", location_name,
                                        "<br>qx: ", qx_mean, "<br>qx_low: ", 
                                        qx_lower, "<br>qx_upper: ", qx_upper, 
                                        "<br>SINAC: ", q5))) + geom_abline())
