pacman::p_load(RJSONIO)

write_plugs <- function(named_list){
  f_ <- "./Results/plugs.json"
  json_data <- as.list(fromJSON(f_))
  for(i in 1:length(named_list)){
    json_data[[names(named_list)[i]]] <- named_list[[i]]
  }
  exportJson <- toJSON(json_data)
  write(exportJson, f_)
}

format_uncert <- function(mean, min, max, sig=4){
    paste0(round(mean, sig), " (", round(min, sig), "-", round(max, sig), ")")
}
