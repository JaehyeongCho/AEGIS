Call.DB<-function(ip, usr, pw){
  DatabaseConnector::connection<-connect(connectionDetails)
  sql <- "SELECT name FROM sys.databases"
  sql <- renderSql(sql)$sql
  sql <- translateSql(sql,
                      targetDialect=connectionDetails$dbms)$sql
  DBlist <- querySql(connection, sql)
  return(DB.name)
}

###########

connectionDetails<<-DatabaseConnector::createConnectionDetails(dbms="sql server",
                                                               server="128.1.99.53",
                                                               schema="Camel_db",
                                                               user="jhcho",
                                                               password="Survival12")
connection<<-DatabaseConnector::connect(connectionDetails)



cdmDatabaseSchema <<- schema_dbo
targettab <<- "cohort"
cdmVersion <<- "5"


