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

h2o.init()

h_weather<-as.h2o(weather)



library(h2o)
h2o.init()
df = h2o.importFile("http://s3.amazonaws.com/h2o-public-test-data/smalldata/airlines/allyears2k_headers.zip")
model = h2o.gbm(model_id = "model",
                training_frame = df,
                x = c("Year", "Month", "DayofMonth", "DayOfWeek", "UniqueCarrier"),
                y = "IsDepDelayed",
                max_depth = 3,
                ntrees = 5)
h2o.download_mojo(model, getwd(), FALSE)

java -cp h2o.jar hex.genmodel.tools.PrintMojo --tree 0 -i model.zip -o model.gv
dot -Tpng model.gv -o model.png


h2o.shutdown()
