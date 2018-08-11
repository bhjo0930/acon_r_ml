library(h2o)
library(RSQLite)

install.packages("RSQLite")
devtools::install_github("rstats-db/RSQLite")

library(DBI)
con <- dbConnect(RSQLite::SQLite(), ":memory:")

dbListTables(con)
dbWriteTable(con, "mtcars", mtcars)
dbListTables(con)
dbListFields(con, "mtcars")
dbReadTable(con, "mtcars")
res <- dbSendQuery(con, "SELECT * FROM mtcars WHERE cyl = 4")
dbFetch(res)
dbClearResult(res)

res <- dbSendQuery(con, "SELECT * FROM mtcars WHERE cyl = 4")
while(!dbHasCompleted(res)){
  chunk <- dbFetch(res, n = 5)
  print(nrow(chunk))
}

dbClearResult(res)

dbDisconnect(con)

#connection_url <- "jdbc:mariadb://172.16.2.178:3306/ingestSQL?&useSSL=false"
#username <- "root"
#password <- "abc123"

# Whole Table:
table <- "citibike20k"
my_citibike_data <- h2o.import_sql_table(connection_url, table, username, password)

# SELECT Query:
select_query <-  "SELECT  bikeid  FROM citibike20k"
my_citibike_data <- h2o.import_sql_select(connection_url, select_query, username, password)


