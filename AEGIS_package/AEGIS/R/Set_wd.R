Set.wd<-function(){
  if(exists("~/AEGIS")==FALSE){
    dir.create("~/AEGIS", showWarnings = FALSE)
    setwd("~/AEGIS")
  }
  else
  {
    setwd("~/AEGIS")
  }
}
