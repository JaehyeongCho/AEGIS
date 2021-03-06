

##install&require packages
packages<-function(x){
  x<-as.character(match.call()[[2]])
  if (!require(x,character.only=TRUE)){
    install.packages(pkgs=x,repos="http://cran.r-project.org")
    require(x,character.only=TRUE)
  }
  else
  {
    require(x,character.only=TRUE)
  }
}

options(expressions=500000)
setTimeLimit()

packages(AEGIS)
packages(raster)
packages(maps)
packages(mapdata)
packages(mapproj)
packages(ggmap)
packages(dplyr)
packages(plyr)
packages(sqldf)
packages(shiny)
packages(bindrcpp)
packages(pkgconfig)
packages(shinyjs)
packages(SqlRender)
packages(DatabaseConnector)
packages(shinydashboard)

Sys.setlocale(category = "LC_ALL", locale = "us")



shinyApp(
  # Define UI for dataset viewer application
  ui <- dashboardPage(
    dashboardHeader(title = "AEGIS"),
    dashboardSidebar(sidebarMenu(menuItem("DB Load",tabName= "db" ),
                                 menuItem("table", tabName = "table" ),
                                 menuItem("control", tabName = "control" ),
                                 menuItem("Export",tabName = "export" )

    )
    ),
    dashboardBody(tabItems(
      tabItem(tabName = "db",
              fluidRow(
                titlePanel("Database Load"),
                sidebarPanel(
                  textInput("ip","IP","")
                  ,textInput("schema","SCHEMA","")
                  ,textInput("usr","USER","")
                  ,passwordInput("pw","PASSWORD","")
                  #input text to db information
                  ,actionButton("db_load","Load DB")
                  #,hr()
                  #,uiOutput("db_conn")
                  #,actionButton("cohort_load","Load cohort")
                ),
                mainPanel(
                  verbatimTextOutput("txt"),
                  tableOutput("view")
                )
              )
      ),
      tabItem(tabName = "table",
              fluidRow(
                titlePanel("table"),
                sidebarPanel(
                  uiOutput("cohort_tcdi")
                  ,uiOutput("cohort_ocdi")
                  ,hr()
                  ,dateRangeInput(inputId = "dateRange", label = "Select Windows",  start = "2002-01-01", end = "2013-12-31")
                  ,hr()
                  ,uiOutput("country_list")
                  ,actionButton("Submit_table","Submit")
                  ),
                mainPanel(
                  #verbatimTextOutput("txt"),
                  #tableOutput("view")
                )
              )
      ),
      tabItem(tabName = "control",
              fluidRow(
                titlePanel("Plot control"),
                sidebarPanel(
                  radioButtons("GIS.level","Administrative level",choices = c("Level 1" = 0, "Level 2" = 1, "Level 3" = 2),selected = 1)
                  ,radioButtons("GIS.distribution","Select distribution options", choices = c("Count of the target cohort (n)" = "count","Propotion" = "proportion", "Standardized Incidence Ratio"="SIR"),selected = "count")
                  ,radioButtons("distinct","Select distinct options", c("Yes" = "distinct","No" = "" ),inline= TRUE)
                  ,textInput("fraction","fraction (only for proportion)",100)
                  ,textInput("title","title","")
                  ,textInput("legend","legend","")
                  ,actionButton("Submit_plot","Submit") #Draw plot button
                ),
                mainPanel(
                  verbatimTextOutput("test")
                  ,plotOutput("plot")
                  ,textOutput("text")
                )
              )
      ),



      tabItem(tabName ="export",
              fluidRow(
                titlePanel("Extraction plot & CSV file"),
                sidebarPanel(
                  downloadButton('plotex', 'plot export'),
                  br(),hr(),
                  downloadButton('csvex', 'CSV export')
                ),
                mainPanel(
                  verbatimTextOutput("ex") # extraction success or fail
                )
              )
      )
    )
    )
  ),




  server <- function(input, output,session){



    #수정 필요

    cohort_listup <- eventReactive(input$db_load, {
      connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="sql server",
                                                                      server=input$ip,
                                                                      schema=input$schema,
                                                                      user=input$usr,
                                                                      password=input$pw)
      connection <- DatabaseConnector::connect(connectionDetails)
      cohort_list <- Call.Cohortlist(connectionDetails, connection, input$schema)
      Set.wd(input$schema)
    })


    output$cohort_tcdi <- renderUI({
      cohort_list <- cohort_listup()
      selectInput("tcdi", "Select target cohort", choices = cohort_list[,1])
    })


    output$cohort_ocdi <- renderUI({
      cohort_list <- cohort_listup()
      selectInput("ocdi", "Select outcome cohort", choices = cohort_list[,1])
    })


    output$country_list <- renderUI({
      country_list <- GIS.countrylist()
      selectInput("country", "Select country", choices = country_list[,1])
    })

    output$plot <- renderPlot ({
      draw_plot()
    }, width = 1024, height = 800, res = 100)

    GIS.table <- reactive(input$Submit_table{
      country_list <- GIS.countrylist()
      country <- input$country
      MAX.level <- country_list[country_list$NAME==country,3]
      GADM <- GIS.download(country, MAX.level)


    })


    #######################################

    draw_plot <- eventReactive(input$Submit_plot,{

      #schema <- input$db
      #ip <- input$ip
      #usr <- input$usr
      #pw <- input$pw
      #GIS.level <- input$GIS.level
      #ocdi <- input$ocdi
      #tcdi <- input$tcdi
      #fraction<-as.numeric(input$fraction)
      #startdt <- input$dateRange[1]
      #enddt <- input$dateRange[2]
      #distinct <- input$distinct



      ##Load cohort
      GIS.cohort <- GIS.extraction(input$GIS.distribution)

      ##load GADM & getting map
      GADM_list <<- GIS.download(country=country, MAX.level=MAX.level)
      map <- GIS.background(GADM_list[[1]]@bbox)


      ##polygon data & proportion calc
      GIS.calc1(path$MAX.level, input$GIS.distribution)
      GIS.calc2


      #plotting on kormap

      if( input$stat == 0){j
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

    output$plotex <- downloadHandler(
      filename = function() {
        paste("MAP ", "LEVEL=",as.character(input$level)," ",as.character(Sys.time()),".png", sep="")
      },
      content = function(file) {
        ggsave(file, draw_plot(), dpi=450, width = 10, height=12, units="in")
      }
    )


    output$csvex <- downloadHandler(
      filename = function() { paste0("output.csv") },
      content = function(file)

      {
        schema <- input$db
        ip <- input$ip
        usr <- input$usr
        pw <- input$pw
        level <- input$level
        ocdi <- input$ocdi
        tcdi <- input$tcdi
        fraction<-as.numeric(input$fraction)
        startdt <- input$dateRange[1]
        enddt <- input$dateRange[2]
        distinct <- input$distinct


        ##Load cohort
        if( input$stat == 0){
          sql <-"
          SELECT o.ID_0, o.ID_1, o.ID_2, count(o.subject_id) as outcome_count
          FROM
          (
          SELECT @distinct a.subject_id, a.cohort_definition_id, a.cohort_start_date, a.cohort_end_date, b.location_id, c.ID_0, c.ID_1, c.ID_2
          FROM @cdmDatabaseSchema.@targettab a
          LEFT JOIN @cdmDatabaseSchema.person b
          ON a.subject_id = b.person_id
          LEFT JOIN gadm.dbo.gadm c
          ON b.location_id = c.location_id

          WHERE a.cohort_definition_id = @tcdi
          )
          o
          where '@startdt' <= o.cohort_start_date
          AND '@enddt' >= o.cohort_end_date
          GROUP BY o.ID_2, o.ID_1, o.ID_0
          "
          connectionDetails<-createConnectionDetails(dbms="sql server",
                                                     server=ip,
                                                     schema=schema,
                                                     user=usr,
                                                     password=pw)

          schema_dbo <- paste0(schema,'.dbo')
          cdmDatabaseSchema <- schema_dbo
          targettab <- "cohort"
          cdmVersion <- "5"
          connection<-connect(connectionDetails)

          sql <- renderSql(sql,
                           cdmDatabaseSchema=cdmDatabaseSchema,
                           targettab=targettab,
                           startdt=startdt,
                           enddt=enddt,
                           distinct=distinct,
                           tcdi=tcdi)$sql
          sql <- translateSql(sql,
                              targetDialect=connectionDetails$dbms)$sql
          cohort<- querySql(connection, sql)
        }
        else if(input$stat == 1){
          sql <-"
          SELECT t.cohort_definition_id, t.subject_id, t.cohort_start_date, t.cohort_end_date
          INTO #target_cohort
          FROM
          (
          SELECT
          @distinct subject_id,
          cohort_definition_id,
          cohort_start_date,
          cohort_end_date
          FROM
          @cdmDatabaseSchema.@targettab
          ) t
          WHERE cohort_definition_id = @tcdi
          AND '@startdt' <= t.cohort_start_date
          AND '@enddt' >= t.cohort_end_date

          --outcome cohort
          SELECT o.cohort_definition_id, o.subject_id, o.cohort_start_date, o.cohort_end_date
          INTO #outcome_cohort
          FROM
          (
          SELECT
          @distinct subject_id,
          cohort_definition_id,
          cohort_start_date,
          cohort_end_date
          FROM
          @cdmDatabaseSchema.@targettab
          ) o
          WHERE cohort_definition_id = @ocdi
          --AND '@startdt' <= o.cohort_start_date
          --AND '@enddt' >= o.cohort_end_date

          SELECT o.subject_id, o.cohort_definition_id, o.cohort_start_date, o.cohort_end_date
          INTO #including_cohort
          FROM #outcome_cohort o
          LEFT JOIN #target_cohort t
          ON t.subject_id = o.subject_id
          WHERE t.cohort_start_date <= o.cohort_start_date
          AND t.cohort_end_date >= o.cohort_start_date

          SELECT a.ID_0, a.ID_1, a.ID_2, a.target_count, b.outcome_count
          FROM
          (
          SELECT c.ID_0, c.ID_1, c.ID_2, count(a.subject_id) AS target_count
          FROM @cdmDatabaseSchema.@targettab a
          LEFT JOIN
          @cdmDatabaseSchema.person b ON a.subject_id = b.person_id LEFT JOIN gadm.dbo.gadm c ON b.location_id = c.location_id
          WHERE cohort_definition_id = @tcdi
          GROUP BY c.ID_2, c.ID_1, c.ID_0
          )
          A LEFT JOIN
          (
          SELECT c.ID_0, c.ID_1, c.ID_2, count(a.subject_id) AS outcome_count
          FROM #including_cohort a
          LEFT JOIN
          @cdmDatabaseSchema.person b ON a.subject_id = b.person_id LEFT JOIN gadm.dbo.gadm c ON b.location_id = c.location_id
          GROUP BY c.ID_2, c.ID_1, c.ID_0
          )
          B
          ON a.ID_2 = b.ID_2
          GROUP BY a.ID_2, a.ID_1, a.ID_0, a.target_count, b.outcome_count
          ORDER BY id_2

          DROP TABLE #including_cohort
          DROP TABLE #target_cohort
          DROP TABLE #outcome_cohort
          "
          connectionDetails<-createConnectionDetails(dbms="sql server",
                                                     server=ip,
                                                     schema=schema,
                                                     user=usr,
                                                     password=pw)

          schema_dbo <- paste0(schema,'.dbo')
          cdmDatabaseSchema <- schema_dbo
          targettab <- "cohort"
          cdmVersion <- "5"
          connection<-connect(connectionDetails)
          sql <- renderSql(sql,
                           cdmDatabaseSchema=cdmDatabaseSchema,
                           targettab=targettab,
                           startdt=startdt,
                           enddt=enddt,
                           distinct=distinct,
                           tcdi=tcdi,
                           ocdi=ocdi)$sql
          sql <- translateSql(sql,
                              targetDialect=connectionDetails$dbms)$sql
          cohort<- querySql(connection, sql)
        } else{
          sql <-"
          SELECT t.cohort_definition_id, t.subject_id, t.cohort_start_date, t.cohort_end_date
          INTO #target_cohort
          FROM
          (
          SELECT
          @distinct subject_id,
          cohort_definition_id,
          cohort_start_date,
          cohort_end_date
          FROM
          @cdmDatabaseSchema.@targettab
          ) t
          WHERE cohort_definition_id = @tcdi
          AND '@startdt' <= t.cohort_start_date
          AND '@enddt' >= t.cohort_end_date

          --outcome cohort
          SELECT o.cohort_definition_id, o.subject_id, o.cohort_start_date, o.cohort_end_date
          INTO #outcome_cohort
          FROM
          (
          SELECT
          @distinct subject_id,
          cohort_definition_id,
          cohort_start_date,
          cohort_end_date
          FROM
          @cdmDatabaseSchema.@targettab
          ) o
          WHERE cohort_definition_id = @ocdi
          --AND '@startdt' <= o.cohort_start_date
          --AND '@enddt' >= o.cohort_end_date

          SELECT o.subject_id, o.cohort_definition_id, o.cohort_start_date, o.cohort_end_date
          INTO #including_cohort
          FROM #outcome_cohort o
          LEFT JOIN #target_cohort t
          ON t.subject_id = o.subject_id
          WHERE t.cohort_start_date <= o.cohort_start_date
          AND t.cohort_end_date >= o.cohort_start_date

          SELECT a.ID_0, a.ID_1, a.ID_2, a.target_count, b.outcome_count
          FROM
          (
          SELECT c.ID_0, c.ID_1, c.ID_2, count(a.subject_id) AS target_count
          FROM @cdmDatabaseSchema.@targettab a
          LEFT JOIN
          @cdmDatabaseSchema.person b ON a.subject_id = b.person_id LEFT JOIN gadm.dbo.gadm c ON b.location_id = c.location_id
          WHERE cohort_definition_id = @tcdi
          GROUP BY c.ID_2, c.ID_1, c.ID_0
          )
          A LEFT JOIN
          (
          SELECT c.ID_0, c.ID_1, c.ID_2, count(a.subject_id) AS outcome_count
          FROM #including_cohort a
          LEFT JOIN
          @cdmDatabaseSchema.person b ON a.subject_id = b.person_id LEFT JOIN gadm.dbo.gadm c ON b.location_id = c.location_id
          GROUP BY c.ID_2, c.ID_1, c.ID_0
          )
          B
          ON a.ID_2 = b.ID_2
          GROUP BY a.ID_2, a.ID_1, a.ID_0, a.target_count, b.outcome_count
          ORDER BY id_2

          DROP TABLE #including_cohort
          DROP TABLE #target_cohort
          DROP TABLE #outcome_cohort
          "
          connectionDetails<-createConnectionDetails(dbms="sql server",
                                                     server=ip,
                                                     schema=schema,
                                                     user=usr,
                                                     password=pw)

          schema_dbo <- paste0(schema,'.dbo')
          cdmDatabaseSchema <- schema_dbo
          targettab <- "cohort"
          cdmVersion <- "5"
          connection<-connect(connectionDetails)
          sql <- renderSql(sql,
                           cdmDatabaseSchema=cdmDatabaseSchema,
                           targettab=targettab,
                           startdt=startdt,
                           enddt=enddt,
                           distinct=distinct,
                           tcdi=tcdi,
                           ocdi=ocdi)$sql
          sql <- translateSql(sql,
                              targetDialect=connectionDetails$dbms)$sql
          cohort<- querySql(connection, sql)

        }

        ##load GADM & getting map
        gadm <- getData('GADM', country='KOR', level=level)
        map <-ggmap(get_map(location = gadm@bbox, maptype='roadmap') )

        ##tolower column names
        colnames(cohort) <- tolower(colnames(cohort))

        ##remove NA
        countdf <- na.omit(cohort)

        ##cohort extraction by level
        if( input$stat == 0){
          if( input$level == 1){
            countdf_level <- sqldf(paste0("select id_1 as id_1, sum(outcome_count) as outcome_count from countdf group by id_1 order by id_1"))
          }
          else
          {
            countdf_level <- sqldf(paste0("select id_2 as id_2, sum(outcome_count) as outcome_count from countdf group by id_2 order by id_2"))
          }
        } else if (input$stat == 1){
          if( input$level == 1){
            countdf_level <- sqldf(paste0("select id_1 as id_1, sum(outcome_count) as outcome_count, sum(target_count) as target_count from countdf group by id_1 order by id_1"))
          }
          else
          {
            countdf_level <- sqldf(paste0("select id_2 as id_2, sum(outcome_count) as outcome_count, sum(target_count) as target_count from countdf group by id_2 order by id_2"))
          }
        } else{
          if( input$level == 1){
            countdf_level <- sqldf(paste0("select id_1 as id_1, sum(outcome_count) as outcome_count, sum(target_count) as target_count from countdf group by id_1 order by id_1"))
          }
          else
          {
            countdf_level <- sqldf(paste0("select id_2 as id_2, sum(outcome_count) as outcome_count, sum(target_count) as target_count from countdf group by id_2 order by id_2"))
          }
        }

        ##polygon data & proportion calc
        mapdf <- data.frame()
        for(i in 1:length(countdf_level$id))
        {
          countdf_level$prop_count[i] <- (countdf_level$outcome_count[i] / countdf_level$target_count[i])*fraction
          countdf_level$smi[i] <-  (countdf_level$outcome_count[i] / countdf_level$target_count[i]) /
            (sum(countdf_level$outcome_count) / sum(countdf_level$target_count))
          idx<-as.numeric(as.character(countdf_level$id[i]))
          polygon <- gadm@polygons[[idx]]
          for(j in 1:length(polygon@Polygons))
          {
            if(polygon@Polygons[[j]]@area<0.001)
              next
            tempdf <- fortify(polygon@Polygons[[j]])
            tempdf$id <- idx
            tempdf$group <- as.numeric(paste0(idx,".",j))
            mapdf <- rbind(mapdf, tempdf)
          }
        }

        #extraction csv file
        gadm_data <- gadm@data
        colnames(gadm_data) <- tolower(colnames(gadm_data))

        if( input$stat == 0){
          if( input$level == 1){
            countdf_level$id_1 <- as.numeric(countdf_level$id_1)
            output_csv <- left_join(gadm_data, countdf_level, by=c("id_1" = "id_1"))
            output_csv <- select(output_csv, -(hasc_1), -(ccn_1), -(cca_1), -(varname_1))
            colnames(output_csv) <- c("objectid", "id_1", "ISO_nation_name", "name_1", "id_2", "name_2", "region_type_local_1", "region_type_eng_1", "region_name_local_1", "count")
            #for(j in 10)
            #{
            #  for (i in 1:length(output_csv[,j]))
            #  {
            #    if(is.na(output_csv[i,j]))
            #    {
            #      output_csv[i,j] <- c(0)
            #    }
            #  }
            #}
            write.csv(output_csv, file)
          }
          else
          {
            countdf_level$id_2 <- as.numeric(countdf_level$id_2)
            output_csv <- left_join(gadm_data, countdf_level, by=c("id_2" = "id_2"))
            output_csv <- select(output_csv, -(hasc_2), -(ccn_2), -(cca_2), -(varname_2))
            colnames(output_csv) <- c("objectid", "id_1", "ISO_nation_name", "name_1", "id_2", "name_2", "id_3", "name_3", "region_type_local_2", "region_type_eng_2", "region_name_local_2", "count")
            #for(j in 10)
            #{
            #  for (i in 1:length(output_csv[,j]))
            #  {
            #    if(is.na(output_csv[i,j]))
            #    {
            #      output_csv[i,j] <- c(0)
            #    }
            #  }
            #}
            write.csv(output_csv, file)
          }
        }
        else if(input$stat ==1){
          if( input$level == 1){
            countdf_level$id_1 <- as.numeric(countdf_level$id_1)
            output_csv <- left_join(gadm_data, countdf_level, by=c("id_1" = "id_1"))
            output_csv <- select(output_csv, -(hasc_1), -(ccn_1), -(cca_1), -(varname_1))
            colnames(output_csv) <- c("objectid", "id_1", "ISO_nation_name", "name_1", "id_2", "name_2", "region_type_local_1", "region_type_eng_1", "region_name_local_1", "outcome_count", "target_count", "proportion")
            #for(j in 10:12)
            #{
            #for (i in 1:length(output_csv[,j]))
            #{
            #if(is.na(output_csv[i,j]))
            #{
            #  output_csv[i,j] <- c(0)
            #}
            #}
            #}
            for (i in 1:length(output_csv$prop_count))
            {
              output_csv$prop_count[i] <- output_csv$prop_count[i] / fraction
            }
            write.csv(output_csv, file)
          }
          else
          {
            countdf_level$id_2 <- as.numeric(countdf_level$id_2)
            output_csv <- left_join(gadm_data, countdf_level, by=c("id_2" = "id_2"))
            output_csv <- select(output_csv, -(hasc_2), -(ccn_2), -(cca_2), -(varname_2))
            colnames(output_csv) <- c("objectid", "id_1", "ISO_nation_name", "name_1", "id_2", "name_2", "id_3", "name_3", "region_type_local_2", "region_type_eng_2", "region_name_local_2", "outcome_count", "target_count", "proportion")
            #for(j in 12:14)
            #{
            #for (i in 1:length(output_csv[,j]))
            #{
            #  if(is.na(output_csv[i,j]))
            #  {
            #    output_csv[i,j] <- c(0)
            #  }
            #}
            #}
            for (i in 1:length(output_csv$prop_count))
            {
              output_csv$prop_count[i] <- output_csv$prop_count[i] / fraction
            }
            write.csv(output_csv, file)
          }
        } else {

          if( input$level == 1){
            countdf_level$id_1 <- as.numeric(countdf_level$id_1)
            output_csv <- left_join(gadm_data, countdf_level, by=c("id_1" = "id_1"))
            output_csv <- select(output_csv, -(hasc_1), -(ccn_1), -(cca_1), -(varname_1))
            colnames(output_csv) <- c("objectid", "id_1", "ISO_nation_name", "name_1", "id_2", "name_2", "region_type_local_1", "region_type_eng_1", "region_name_local_1", "outcome_count", "target_count", "proportion")
            #for(j in 10:12)
            #{
            #for (i in 1:length(output_csv[,j]))
            #{
            #  if(is.na(output_csv[i,j]))
            #  {
            #    output_csv[i,j] <- c(0)
            #  }
            #}
            #}
            for (i in 1:length(output_csv$smi))
            {
              output_csv$smi[i] <- output_csv$smi[i]
            }
            write.csv(output_csv, file)
          }
          else
          {
            countdf_level$id_2 <- as.numeric(countdf_level$id_2)
            output_csv <- left_join(gadm_data, countdf_level, by=c("id_2" = "id_2"))
            output_csv <- select(output_csv, -(hasc_2), -(ccn_2), -(cca_2), -(varname_2))
            colnames(output_csv) <- c("objectid", "id_1", "ISO_nation_name", "name_1", "id_2", "name_2", "id_3", "name_3", "region_type_local_2", "region_type_eng_2", "region_name_local_2", "outcome_count", "target_count", "proportion")
            #for(j in 12:14)
            #{
            #for (i in 1:length(output_csv[,j]))
            #{
            #  if(is.na(output_csv[i,j]))
            #  {
            #    output_csv[i,j] <- c(0)
            #  }
            #}
            #}
            for (i in 1:length(output_csv$prop_count))
            {
              output_csv$prop_count[i] <- output_csv$prop_count[i] / fraction
            }
            write.csv(output_csv, file)
          }

        }


      }
      )
  })
