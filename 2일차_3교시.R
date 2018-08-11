install.packages("randomForest")
library(randomForest)
model <- randomForest(Species ~., data=iris)
model
model2 <- randomForest(Species~., data=iris,ntree=300,mtry=4, na.action=na.omit)
model2
model3 <- randomForest(Species ~., data=iris, importance=T, na.aciton=na.omit )

importance(model3)
varImpPlot(model3,main="varImpPlot of iris")




data1 <- read.table("브랜드_수입.txt",header=T,sep="\t")
head(data1,3)
data1.tree <- randomForest(data=data1[,-1],brand~.,na.action=na.omit)
importance(data1.tree)

View(data1)


## 
creditset <- read.table("creditset.csv",header=T,sep=",")
creditset<-creditset[,-1]

idx <- sample(1:nrow(creditset),nrow(creditset)*0.7)
train <- creditset[idx,]
test  <- creditset[-idx,]

w_model <- glm(data=train,default10yr ~ .,family='binomial')
pred <- predict(w_model,newdata=test,type="response")
result_pred <- ifelse(pred >= 0.5,1,0)
head(result_pred)

a <- table(result_pred, test$default10yr)
a      
(a[1,1]+a[2,2])/sum(a)




## 
sp500_tm <- read.table("sp500_tm.csv",header=T,sep=",",stringsAsFactors=FALSE)
head(sp500_tm)

idx <- sample(1:nrow(sp500_tm),nrow(sp500_tm)*0.7)
train <- sp500_tm[idx,]
test  <- sp500_tm[-idx,]

w_model <- glm(data=train,Direction ~ .,family='binomial')
pred <- predict(w_model,newdata=test,type="response")
result_pred <- ifelse(pred >= 0.5,1,0)
head(result_pred)

b <- table(result_pred, test$Direction)
b      
(b[1,1]+b[2,2])/sum(b)

model<-randomForest(Direction ~., data=sp500_tm,ntree=15,mtry=2)
#importance(model)
plot(model)
rf_pred = predict(model, test)
result_pred <- ifelse(rf_pred >= 0.5,1,0)
#install.packages("caret")
#library(caret)
confusionMatrix(table(result_pred, test$Direction))

