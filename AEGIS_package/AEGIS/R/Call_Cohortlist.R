Call.Cohortlist<-function(ip, usr, pw, schema){
  schema_dbo <- paste0(schema,'.dbo')

  connectionDetails<<-DatabaseConnector::createConnectionDetails(dbms="sql server",
                                                                 server=ip,
                                                                 schema=schema,
                                                                 user=usr,
                                                                 password=pw)
  cdmDatabaseSchema <<- schema_dbo
  targettab <<- "cohort"
  cdmVersion <<- "5"
  connection<<-DatabaseConnector::connect(connectionDetails)

  sql <- "SELECT distinct cohort_definition_id FROM @cdmDatabaseSchema.@targettab order by cohort_definition_id"
  sql <- SqlRender::renderSql(sql,
                              cdmDatabaseSchema=cdmDatabaseSchema,
                              targettab=targettab)$sql
  sql <- SqlRender::translateSql(sql,
                                 targetDialect=connectionDetails$dbms)$sql
  Cohortlist<-DatabaseConnector::querySql(connection, sql)
  return(Cohortlist)
}
