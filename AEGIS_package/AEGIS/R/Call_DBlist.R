Call.DB<-function(server, ip, usr, pw, schema, targettab="cohort", cdmVersion="5"){
connectionDetails<<-DatabaseConnector::createConnectionDetails(dbms=server,
                                                               server=ip,
                                                               schema=schema,
                                                               user=usr,
                                                               password=pw)
schema_dbo <- paste0(schema,".dbo")
cdmDatabaseSchema <- schema_dbo
targettab <- targettab
cdmVersion <- cdmVersion
connection <<- DatabaseConnector::connect(connectionDetails)
}
