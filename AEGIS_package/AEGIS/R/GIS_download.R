GIS.download <- function(country, MAX.level){
  GADM.name <- paste0("GADM_2.8_",country,"_adm_total")
  GADM.file <- paste0("GADM_2.8_",country,"_adm_total.rds")
  x <- list()
      if(!file.exists(GADM.file)){
            for(i in 0:MAX.level){
              file.name <- paste0("GADM_2.8_",country,"_adm",i,".rds")
                if(file.exists(file.name)){
                  nam <- paste0("GADM_2.8_",country,"_adm",i)
                  assign(nam, raster::getData("GADM", country=country, level=i))
                  x[[i]] <- nam
                  next
                }
                else
                {
                  nam <- paste0("GADM_2.8_",country,"_adm",i)
                  assign(nam, raster::getData("GADM", country=country, level=i))
                  x[[i]] <- nam
                }
            }
        GADM.list <-
        temp <- list()
        return(GADM.name)
  }
  else
  {
    return(GADM.name)
  }
}


#--------- 여기부터 다시 수정 하지~


GIS.download <- function(country, MAX.level){
  GADM.file <- paste0("GADM_2.8_",country,"_adm_total.rds")
  temp_list <- list()
  if(!file.exists(GADM.file)){
    for(i in 0:MAX.level){
      file.name <- paste0("GADM_2.8_",country,"_adm",i,".rds")
      if(file.exists(file.name)){
        nam <- paste0("GADM_2.8_",country,"_adm",i)
        assign(nam, raster::getData("GADM", country=country, level=i))
        x[[i]] <- nam
        next
      }
      else
      {
        nam <- paste0("GADM_2.8_",country,"_adm",i)
        assign(nam, raster::getData("GADM", country=country, level=i))
        x[[i]] <- nam
      }
    }
    GADM.list <-
      temp <- list()
    return(GADM.name)
  }
  else
  {
    return(GADM.name)
  }
}
