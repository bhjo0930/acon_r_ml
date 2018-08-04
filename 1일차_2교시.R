#install.packages("corrgram")
library(corrgram)
library(dplyr)

names(iris)

cor(iris[-5])

X11() # 별도의 화면으로 출력
corrgram(iris, upper.panel = panel.conf)


save(gData, file = "gData.RData")

gData.a<-is.na.data.frame(gData)

attach(gData)

names(gData)

plot(overall~rides,col="red")

corrgram(gData, upper.panel = panel.cor)
X11(); corrgram(gData, lower.panel=panel.pts, upper.panel=panel.cor,
         diag.panel=panel.density)

gData.cor<-cor(gData[,4:8])

library(dplyr)
result <- filter(cor(gData[,4:8]),data$three == 11)

#install.packages("corrplot")
library(corrplot)

gData.cor<-cor(gData[,4:8])

corrplot(gData.cor)

data <- read_csv("cleanDescriptive.csv", locale = locale(encoding = "euc-kr"))

install.packages("gmodels")
library(gmodels)
library(ggplot2)


x<-data$level2
y<-data$pass2

result<-data.frame(level=x, pass=y)

?CrossTable(table(result))


survey<-MASS::survey
table(survey$W.Hnd)
chisq.test(table(survey$W.Hnd),p=c(.3,.7))



