GIS.addgadmlv <- function(MAX.level){
   #for (i in MAX.level:0) {
    j<-i+1

    cohort$id_i <- sqldf::sqldf(left join (GADM_list[[j]]@data$id_i , join gadm_id=id_MAX.level))

    cohort$id_i <- id_i , GADM_list[[j]]@data$id_i
   }
}
