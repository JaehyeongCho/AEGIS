GIS.calc1 <- function(MAX.level, GIS.distribution){
  for (i in MAX.level:0){
      switch(GIS.distribution,
             count={
                temp <- paste0("select id_",i," as id_",i,", sum(outcome_count) as outcome_count from countdf group by id_",i, " order by id_",i)
                temp_df <- sqldf::sqldf(temp)
                GADM_list[[i]]@data <- temp_df
               },
             proportion={
               temp <- paste0("select id_",i, " as id_",i,", sum(outcome_count) as outcome_count, sum(target_count) as target_count from countdf group by id_",i," order by id_",i)
               temp_df <- sqldf::sqldf
               #working path?
               },
             SIR={
               temp <- paste0("select id_",i, " as id_",i,", sum(outcome_count) as outcome_count, sum(target_count) as target_count from countdf group by id_",i," order by id_",i)
               temp_df <- sqldf::sqldf
               #working path?
             },
             stop("Unknown error")
            )
        }
}


MAX.level <- 3
temp <- GIS.download(country, MAX.level)

i<-0

temp2 <- paste0("select id_",i," as id_",i,", sum(outcome_count) as outcome_count from countdf group by id_",i, " order by id_",i)
j<-i+1
temp_df <- sqldf::sqldf(temp)
GADM_list[[i]]@data <- temp_df
