http://blog.daum.net/chohs12

https://github.com/rstudio/cheatsheets





install.packages("sparklyr")

library(sparklyr)
library(dplyr)

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


library(DBI)
iris_preview <- dbGetQuery(sc, "SELECT * FROM iris_tbl LIMIT 10")
iris_preview

iris_tbl
ml_chisquare_test(x, features, label)

iris_tbl <- sdf_copy_to(sc, iris, name = "iris_tbl", overwrite = TRUE)

features <- c("Petal_Width", "Petal_Length", "Sepal_Length", "Sepal_Width")

ml_chisquare_test(iris_tbl, features = features, label = "Species")

barplot(as.matrix(iris))

################

s_weather <- copy_to(sc, weather)
src_tbls(sc)

s_df <- s_weather %>% 
  select(c(-1,-6,-8,-14))

s_df <- mutate(s_df, RainTomorrow = case_when(RainTomorrow=='Yes' ~ 1, 
                                      RainTomorrow=='No' ~ 0))

s_df <- mutate(s_df, RainTomorrow = as.numeric(RainTomorrow))
    

partitions <- s_df %>%
  sdf_partition(training = 0.7, test = 0.3)

#print(partitions$training)

s_df.training <- partitions$training
s_df.test <- partitions$test

s_df.training<-na.omit(s_df.training)
s_df.test<-na.omit(s_df.test)

View(s_df.training)

s_df %>%
  select(RainTomorrow)

#w_model <- glm(data=train,RainTomorrow~.,family='binomial')  #summary(w_model)
#s_model <- glm(RainTomorrow ~ ., family = binomial, data = partitions$training)

s_model <- s_df.training %>% 
  ml_logistic_regression(RainTomorrow ~ .)

summary(s_model)

pred <- sdf_predict(s_df.test, s_model)

ml_binary_classification_evaluator(pred,metric = "areaUnderROC")

pred.dt<-as.data.table(pred)
View(pred.dt)



#result_pred <- ifelse(pred.dt$probability_0_0 >= 0.5,1,0)
#result_pred

table(pred.dt$prediction, pred.dt$label)

summary(pred.dt$predicted_label)

#########################
# 
# mtcars_tbl <- sdf_copy_to(sc, mtcars, name = "mtcars_tbl", overwrite = TRUE)
# 
# partitions <- mtcars_tbl %>%
#   sdf_partition(training = 0.7, test = 0.3, seed = 1111)
# 
# mtcars_training <- partitions$training
# mtcars_test <- partitions$test
# 
# lr_model <- mtcars_training %>%
#   ml_logistic_regression(am ~ gear + carb)
# 
# pred <- sdf_predict(mtcars_test, lr_model)
# 
# ml_binary_classification_evaluator(pred)




ctree

#Temp~Solar.R + Wind + Ozone,data=airquality
s_airquality <- sdf_copy_to(sc, airquality, name = "s_airquality", overwrite = TRUE)

s_airquality<-na.omit(s_airquality)
is.na.data.frame(airquality)
partitions <- s_airquality %>%
  sdf_partition(training = 0.9, test = 0.1, seed = 1111)

s_airquality_training <- partitions$training
s_airquality_test <- partitions$test

dt_model <- s_airquality_training %>%
  ml_decision_tree(Temp ~ Solar_R + Wind + Ozone)

pred <- sdf_predict(s_airquality_test, dt_model)

#ml_multiclass_classification_evaluator(pred, label='prediction')

pred.dt<-as.data.table(pred)

#class(pred)

plot(pred.dt$Temp,as.numeric(pred.dt$prediction))

sdf_mutate(pred)

select(pred, Day)

pred %>% filter(Temp>70) %>% summarise(mean=avg(Temp))
