GIS.plot <- function(GIS.distribution){
  if( input$stat == 0){
    if(input$level == 1){
      mapdf$id_1 <- mapdf$id
      mapdf <- join(mapdf,countdf_level,by = "id_1", type="inner")
    } else {
      mapdf$id_2 <- mapdf$id
      mapdf <- join(mapdf,countdf_level,by = "id_2", type="inner")
    }

    t <- max(countdf_level$outcome_count)

    plot <- map+
      geom_polygon(data=mapdf,aes(x=long,y=lat,group=group,fill=outcome_count),alpha=0.8,colour="black",lwd=0.2)+
      scale_fill_gradientn(colours = rev(heat.colors(3)), limit = c(0,t)) + labs(fill=input$legend) +
      ggtitle(input$title) + theme(plot.title=element_text(face="bold", size=30, vjust=2, color="black")) +
      theme(legend.title=element_text(size=20, face="bold")) + theme(legend.text = element_text(size=15)) + theme(legend.key.width=unit(2, "cm"), legend.key.height = unit(2,"cm"))

    plot


  }
  else if( input$stat == 1){
    if( input$level == 1){
      mapdf$id_1 <- mapdf$id
      mapdf <- join(mapdf,countdf_level,by = "id_1", type="inner")
    }
    else
    {
      mapdf$id_2 <- mapdf$id
      mapdf <- join(mapdf,countdf_level,by = "id_2", type="inner")
    }
    t <- max(countdf_level$prop_count)
    plot <- map+
      geom_polygon(data=mapdf,aes(x=long,y=lat,group=group,fill=prop_count),alpha=0.8,colour="black",lwd=0.2)+
      scale_fill_gradientn(colours = rev(heat.colors(3)), limit = c(0,t)) + labs(fill=input$legend) +
      ggtitle(input$title) + theme(plot.title=element_text(face="bold", size=30, vjust=2, color="black")) +
      theme(legend.title=element_text(size=20, face="bold")) + theme(legend.text = element_text(size=15)) + theme(legend.key.width=unit(2, "cm"), legend.key.height = unit(2,"cm"))

    plot
  } else {
    if( input$level == 1){
      mapdf$id_1 <- mapdf$id
      mapdf <- join(mapdf,countdf_level,by = "id_1", type="inner")
    }
    else
    {
      mapdf$id_2 <- mapdf$id
      mapdf <- join(mapdf,countdf_level,by = "id_2", type="inner")
    }
    t <- max(countdf_level$smi)
    plot <- map+
      geom_polygon(data=mapdf,aes(x=long,y=lat,group=group,fill=smi),alpha=0.8,colour="black",lwd=0.2)+
      scale_fill_gradientn(colours = rev(heat.colors(3)), limit = c(0,t)) + labs(fill=input$legend) +
      ggtitle(input$title) + theme(plot.title=element_text(face="bold", size=30, vjust=2, color="black")) +
      theme(legend.title=element_text(size=20, face="bold")) + theme(legend.text = element_text(size=15)) + theme(legend.key.width=unit(2, "cm"), legend.key.height = unit(2,"cm"))

    plot

  }
})
}
