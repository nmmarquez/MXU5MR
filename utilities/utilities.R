rm(list=ls())
pacman::p_load(RJSONIO)

write_plugs <- function(named_list){
    f_ <- "~/Documents/MXU5MR/paper/plugs.json"
    json_data <- as.list(fromJSON(f_))
    for(i in 1:length(named_list)){
        json_data[[names(json_data)[i]]] <- json_data[i] 
    }
    exportJson <- toJSON(json_data)
    write(exportJson, f_)
}