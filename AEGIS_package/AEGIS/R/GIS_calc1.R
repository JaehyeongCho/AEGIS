MAX.leve <- 2
GIS.distribution <- "count"

GIS.calc1 <- function(MAX.level, GIS.distribution){
  for (i in max.level:0){
      switch(GIS.distribution,
             count={
                temp <- paste0("select id_",i," as id_",i,", sum(outcome_count) as outcome_count from countdf group by id_",i, " order by id_",i)
                temp_df <- sqldf::sqldf(temp)
                #working path?
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

GIS.calc1(MAX.level, GIS.distribution)

gadm <- raster::getData('GADM', country='KOR', level=2)

head(gadm)

gadm$feature


raster_gadm <- raster::raster(gadm@polygons[[20]])

str(raster_gadm)

plot(raster_gadm)



library(raster)

p<-gadm

gadm@data



p <- p[p$ISO=="KOR", ]
p$value <- c(1:5)
data.frame(p)

par(mai=c(0,0,0,0))
plot(p, col=2:7)
xy <- coordinates(p)
points(xy, cex=6, pch=20, col='white')
text(p, 'ID_2', cex=1.5)

