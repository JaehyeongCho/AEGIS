GIS.calc2 <- function(tcid, ocid)
mapdf <- data.frame()
for(i in 1:length(countdf_level$id)){
  countdf_level$prop_count[i] <- (countdf_level$outcome_count[i] / countdf_level$target_count[i])*fraction
  countdf_level$smi[i] <-(countdf_level$outcome_count[i] / countdf_level$target_count[i]) /
    (sum(countdf_level$outcome_count) / sum(countdf_level$target_count))
  idx<-as.numeric(as.character(countdf_level$id[i]))
  polygon <- gadm@polygons[[idx]]
  for(j in 1:length(polygon@Polygons)){
    #if(polygon@Polygons[[j]]@area<GIS.size)
    #  next
    tempdf <- fortify(polygon@Polygons[[j]])
    tempdf$id <- idx
    tempdf$group <- as.numeric(paste0(idx,".",j))
    mapdf <- rbind(mapdf, tempdf)
  }
}
