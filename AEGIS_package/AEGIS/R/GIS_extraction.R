schema <- "NHIS_NSC"
targettab <- "cohort"
startdt <- "2002-01-01"
enddt <- "2013-12-31"
distinct <- ""
tcdi <- "403"
ocdi <- "438"

GIS.extraction<-function(connectionDetails, schema, targettab="cohort", startdt, enddt, distinct,
                         tcdi, ocdi){
  connectionDetails <- connectionDetails
  connection <- DatabaseConnector::connect(connectionDetails)
  tcdi <- tcdi
  ocdi <- ocdi
  cdmDatabaseSchema <- paste0(schema,".dbo")
  targettab <- targettab
  cdmVersion <- "5"
  #Sys.setlocale(category = "LC_ALL", locale = "us")
  Sys.setlocale(category="LC_CTYPE", locale="C")


    sql <-"
    SELECT o.gadm_id, count(o.subject_id) as count_target --GADM_ID, count
    FROM
    (
    SELECT @distinct a.subject_id, a.cohort_definition_id, a.cohort_start_date, a.cohort_end_date, b.location_id, c.fact_id_1 as gadm_id
    FROM @cdmDatabaseSchema.@targettab a
    LEFT JOIN @cdmDatabaseSchema.person b
    ON a.subject_id = b.person_id
    LEFT JOIN @cdmDatabaseSchema.fact_relationship c
    ON b.location_id = c.fact_id_2
    WHERE a.cohort_definition_id = @tcdi
    ) o
    where '@startdt' <= o.cohort_start_date
    AND '@enddt' >= o.cohort_end_date
    GROUP BY o.gadm_id
    "
    sql <- SqlRender::renderSql(sql,
                                cdmDatabaseSchema=cdmDatabaseSchema,
                                targettab=targettab,
                                startdt=startdt,
                                enddt=enddt,
                                distinct=distinct,
                                tcdi=tcdi)$sql
    sql <- SqlRender::translateSql(sql,
                                   targetDialect=connectionDetails$dbms)$sql
    cohort_count <- DatabaseConnector::querySql(connection, sql)
    colnames(cohort_count) <- tolower(colnames(cohort_count))
    countdf_count <- na.omit(cohort_count)


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

    SELECT a.gadm_id, a.target_count as proportion_target, b.outcome_count as proportion_outcome
    FROM
    (
    SELECT c.fact_id_1 AS gadm_id, count(a.subject_id) AS target_count
    FROM @cdmDatabaseSchema.@targettab a LEFT JOIN
    @cdmDatabaseSchema.person b ON a.subject_id = b.person_id LEFT JOIN @cdmDatabaseSchema.fact_relationship c ON b.location_id = c.fact_id_2
    WHERE cohort_definition_id = @tcdi
    GROUP BY c.fact_id_1
    ) A
    LEFT JOIN
    (
    SELECT c.fact_id_1 as gadm_id, count(a.subject_id) AS outcome_count
    FROM #including_cohort a
    LEFT JOIN
    @cdmDatabaseSchema.person b ON a.subject_id = b.person_id LEFT JOIN @cdmDatabaseSchema.fact_relationship c ON b.location_id = c.fact_id_2
    GROUP BY c.fact_id_1
    ) B
    ON a.gadm_id = b.gadm_id
    GROUP BY a.gadm_id, a.target_count, b.outcome_count
    ORDER BY a.gadm_id

    DROP TABLE #including_cohort
    DROP TABLE #target_cohort
    DROP TABLE #outcome_cohort
    "
    sql <- SqlRender::renderSql(sql,
                                cdmDatabaseSchema=cdmDatabaseSchema,
                                targettab=targettab,
                                startdt=startdt,
                                enddt=enddt,
                                distinct=distinct,
                                tcdi=tcdi,
                                ocdi=ocdi)$sql
    sql <- SqlRender::translateSql(sql,
                                   targetDialect=connectionDetails$dbms)$sql
    cohort_proportion <- DatabaseConnector::querySql(connection, sql)
    colnames(cohort_proportion) <- tolower(colnames(cohort_proportion))
    countdf <- na.omit(cohort_proportion)

    cohort <- dplyr::left_join(cohort_count, cohort_proportion, by = c("gadm_id", "gadm_id"))
    cohort$proportion <- cohort$proportion_outcome / cohort$proportion_target
    return(cohort)
  }



cohort <- GIS.extraction(connectionDetails, schema, targettab="cohort", startdt, enddt, distinct,
                         tcdi, ocdi)




connectionDetails <- DatabaseConnector::createConnectionDetails(dbms="sql server",
                                                                server="128.1.99.53",
                                                                schema="NHIS_NSC",
                                                                user="JHCho",
                                                                password="Survival12")


head(cohort)

