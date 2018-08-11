install.packages("h2o")
install.packages("RMariaDB")

library(RMariaDB)

con <- dbConnect(
  drv = RMariaDB::MariaDB(), 
  username = NULL,
  password = NULL, 
  host = localhost, 
  port = 3306
)

install.packages("RSQLite")

library(DBI)
# Create an ephemeral in-memory RSQLite database
con <- dbConnect(RSQLite::SQLite(), ":memory:")

dbListTables(con)


dbWriteTable(con, "mtcars", mtcars)
dbListTables(con)
dbListFields(con, "mtcars")
dbReadTable(con, "mtcars")

res <- dbSendQuery(con, "SELECT * FROM mtcars WHERE cyl = 4")
dbFetch(res)


dbClearResult(res)

# Or a chunk at a time
res <- dbSendQuery(con, "SELECT * FROM mtcars WHERE cyl = 4")
while(!dbHasCompleted(res)){
  chunk <- dbFetch(res, n = 5)
  print(nrow(chunk))
}

