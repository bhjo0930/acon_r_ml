install.packages("party")
library(party)
library(datasets)
head(airquality)
air_ctree <- ctree(Temp~Solar.R + Wind + Ozone,data=airquality)
air_ctree
plot(air_ctree)



airquality %>% filter(Ozone > 37) %>% count()
air1 <- airquality %>% filter(Ozone > 37)
air1 %>% filter(Ozone > 65) %>% arrange(desc(Ozone))
idx <- sample(1:nrow(iris),nrow(iris)*0.7)  # 샘플링
train <- iris[idx,]
test <- iris[-idx,]
formula <- Species ~ Sepal.Length + Sepal.Width + Petal.Length + Petal.Width
iris_ctree <- ctree(formula, data=train)
plot(iris_ctree)
pred <- predict(iris_ctree, test) 
table(pred, test$Species)
(12+15+14)/now(test)
t <- sample(1:nrow(mpg),nrow(mpg)*0.7)
train <- mpg[t,]
test <- mpg[-t,]
train$drv <- factor(train$drv)
formula <- hwy ~ displ+cyl+drv
hwy_ctree <- ctree(formula,data=train) 
plot(hwy_ctree)