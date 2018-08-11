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



weather <- read.csv("weather.csv",stringsAsFactors=F)
str(weather)



install.packages("cvTools")
library(cvTools)
cvFolds(10, K=5,R=1,type="random")

cv<-cvFolds(NROW(iris),K=3,R=2)
#head(cv$subsets)

idx<-cv$subset[which(cv$which==1),1]
train<-iris[idx,]
test<-iris[-idx,]
#head(train)
#library(party)
model<-ctree(Species ~ .,data = train)
pred<-predict(model,test)
table(pred, test$Species)

K<-1:3
R<-1:2
cv<-cvFolds(NROW(iris),K=max(K),R=max(R))

CNT<-0
ACC<-0

for(r in R){
  cat('\n\n R=', r, '\n')
  for(k in K){
    idx<-cv$subset[which(cv$which==k),r]
    train<-iris[idx,]
    test<-iris[-idx,]
    model<-ctree(Species ~ .,data = train)
    pred<-predict(model,test)
    t<-table(pred, test$Species)
#    cat('\n----------------------\n')
#    cat('train:',nrow(train),'\n')
#    cat('test:',nrow(test),'\n')
#    print(t)
    CNT<-CNT+1
    ACC[CNT]<-(t[1,1]+t[2,2]+t[3,3])/ sum(t)
#    cat('\n----------------------\n')
  }
}

ACC
#[1] 0.93 0.92 0.89 0.93 0.92 0.97

cv$subset[which(cv$which==1),2]

for(r in R){
  for(k in K){
    cat('R=', r, 'K=',k,'\n')
  }
}

result <- foreach(g = 1:NROW(grid), .combine = rbind) %do% {
  foreach(r = 1:R, .combine = rbind) %do% {
    foreach(k = 1:K, .combine = rbind) %do% {
      validation_idx <- cv$subsets[which(cv$which == k), r]
      train <- iris[-validation_idx, ]
      validation <- iris[validation_idx, ]
      # training
      m <- randomForest(Species ~ ., data = train, ntree = grid[g, "ntree"], 
                        mtry = grid[g, "mtry"])
      # prediction
      predicted <- predict(m, newdata = validation)
      
      # estimating performance
      precision <- sum(predicted == validation$Species)/NROW(predicted)
      return(data.frame(g = g, precision = precision))
    }
  }
}










