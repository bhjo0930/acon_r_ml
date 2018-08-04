# install.packages("dplyr")
# install.packages("ggplot2")
# install.packages("data.table")
# install.packages("googleVis")
library(dplyr)
library(ggplot2)
library(data.table)
library(googleVis)


## Install package (library) if not installed
usePackage <- function(p) {
    if (!is.element(p, installed.packages()[,1]))
        install.packages(p, dep = TRUE)
    require(p, character.only = TRUE)
}

#devtools::install_github("Stan125/limoaddin")
#library(limoaddin)

pckg = c("dplyr", "ggplot2")
usePackage(pckg)

da1<-read.csv("descriptive.csv", header = TRUE)
head(da1)

dim(da1)
#pass 1: pass, 2:fail
summary(da1)

da1 %>% filter(is.na(resident)) %>% count()
subset(da1, resident=="NA")
table(da1)

#da2<-as.data.table(da1)
#da2<-da2[is.na(resident)==FALSE]
#table(da2$gender)
#da2[, by=gender]

da1<-subset(da1, da1$gender==1|da1$gender==2)
x<-table(da1$gender)
barplot(x)

plot(gvisBarChart(da1))


prop.table(x)
x2<-prop.table(x)
round(x2*100,2)


x3<-table(da1$level)
barplot(x3)

s1<-da1$survey
head(s1)

summary(s1)

s1<-subset(s1, !is.na(s1))
summary(s1)

s1_tb1<-table(s1)
barplot(s1_tb1)


#devtools::install_github('rstudio/DT')
#devtools::install_github("csgillespie/addinmanager")
#addinmanager::addin_manager()


#4.
table(da1$cost)
length(da1$cost)
summary(da1$cost)
plot(da1$cost)
hist(da1$cost)
da1<-subset(da1, da1$cost>=1&da1$cost<=10)

#install.packages("radiant", repos = "https://radiant-rstats.github.io/minicran/")
#Once all packages are installed, select Start radiant from the Addins menu in Rstudio or use the command below to launch the app:
#radiant::radiant()
#radiant::radiant_viewer()
#radiant::radiant_window()
#install.packages("radiant.update", repos = "https://radiant-rstats.github.io/minicran/")
#radiant.update::radiant.update()
#save.image("C:/r_temp/acon_r_ml/demo.RData")
save(da1, file = "C:/r_temp/acon_r_ml/demo.RData")

x<-da1$cost
length(x)
x.t<-table(x)
class(x.t)
max(x.t)

x.df<-data.frame(x.t)
names(x.df)
head(x.df)

x.df %>% filter(Freq==max(Freq))

x.df<-subset(x.df,Freq==max(Freq))
head(x.df)

#연속형 변수의 범주화
summary(da1)


da1$cost2 <- ifelse(da1$cost >= 7, 3, ifelse(da1$cost >= 4, 2, ifelse(da1$cost >= 1, 1, 0)))
head(da1$cost2)
c2<-table(da1$cost2)

barplot(c2)
