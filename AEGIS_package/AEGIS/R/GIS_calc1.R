GIS.calc1 <- function(MAX.level, GIS.distribution){
  for (i in max.level:0){
      switch(GIS.distribution,
             count={
                temp <- paste0("select id_",i," as id_",i,", sum(outcome_count) as outcome_count from countdf group by id_",i, " order by id_",i)
                temp_df <- sqldf::sqldf(temp)
                #working path? max 기준으로 만들고 row level별로 aggregation 해야 하나?
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
