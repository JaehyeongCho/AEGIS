GIS.calc1 <- function(MAX.level, GIS.distribution){
  for (i in MAX.level:0){
      switch(GIS.distribution,
             count={
                j<-i+1
                temp <- paste0("select id_",i," as id_",i,", sum(outcome_count) as outcome_count from countdf group by id_",i, " order by id_",i)
                temp_df <- sqldf::sqldf(temp)
                dplyr::left_join(GADM_list[[j]]@data, temp_df, by = c("id_2", "id_2"))
               },
             proportion={
               j<-i+1
               temp <- paste0("select id_",i, " as id_",i,", sum(outcome_count) as outcome_count, sum(target_count) as target_count from countdf group by id_",i," order by id_",i)
               temp_df <- sqldf::sqldf
               dplyr::left_join(GADM_list[[j]]@data, temp_df, by = c("id_2", "id_2"))
             },
             SIR={
               j<-i+1
               temp <- paste0("select id_",i, " as id_",i,", sum(outcome_count) as outcome_count, sum(target_count) as target_count from countdf group by id_",i," order by id_",i)
               temp_df <- sqldf::sqldf
               dplyr::left_join(GADM_list[[j]]@data, temp_df, by = c("id_2", "id_2"))
             },
             stop("Unknown error")
            )
        }
}
