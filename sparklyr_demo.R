
install.packages("sparklyr")

library(sparklyr)
spark_install(version = "2.2.0")

devtools::install_github("rstudio/sparklyr")


# spark_install_find(version = NULL, hadoop_version = NULL,
#                    installed_only = TRUE, latest = FALSE, hint = FALSE)
# 
# spark_install(version = NULL, hadoop_version = NULL, reset = TRUE,
#               logging = "INFO", verbose = interactive())
# 
# spark_uninstall("2.1.0", "2.7")
# 
# spark_install_dir()
# 
# spark_install_tar(tarfile)
# 
# spark_installed_versions()
# 
# spark_available_versions(show_hadoop = FALSE)

spark_connection_find()
spark_disconnect()

sc <- spark_connect(master = "local")

install.packages(c("nycflights13", "Lahman"))
library(dplyr)
iris_tbl <- copy_to(sc, iris)
flights_tbl <- copy_to(sc, nycflights13::flights, "flights")
batting_tbl <- copy_to(sc, Lahman::Batting, "batting")
src_tbls(sc)

flights_tbl %>% filter(dep_delay == 2)

sdf_dim(flights_tbl)

iris_tbl <- sdf_copy_to(sc, iris, name = "iris_tbl", overwrite = TRUE)

features <- c("Petal_Width", "Petal_Length", "Sepal_Length", "Sepal_Width")
ml_corr(iris_tbl, columns = features , method = "pearson")

#https://acadgild.com/blog/hadoop-data-analysis-using-sparklyr

