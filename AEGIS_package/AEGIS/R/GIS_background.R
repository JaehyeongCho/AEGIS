GIS.background<-function(bbox){
map <- ggmap(get_map(location = bbox, maptype='roadmap') )
return(map)
}
