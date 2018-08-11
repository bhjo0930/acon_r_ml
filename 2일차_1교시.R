(1) 데이터 가져오기

weather <- read.csv("weather.csv",stringsAsFactors=F)
str(weather)

dim(weather)

(2) chr 컬럼, Date, RainToday 컬럼 제거

w_df <- weather[,c(-1,-6,-8,-14)]

str(w_df)


(3) y 변수(RainTomorrow)의 로짓 변환 : 더미변수(0,1)로 변경

w_df$RainTomorrow[w_df$RainTomorrow=='Yes'] <- 1
w_df$RainTomorrow[w_df$RainTomorrow=='No'] <- 0

str(w_df$RainTomorrow)
w_df$RainTomorrow <- as.numeric(w_df$RainTomorrow)

(4) 학습데이터와 검정데이터 생성(7:3 비율)

idx <- sample(1:nrow(w_df),nrow(w_df)*0.7)

train <- w_df[idx,]
test  <- w_df[-idx,]


(5) 로지스틱 회귀모델 생성

w_model <- glm(data=train,RainTomorrow~.,family='binomial')  #summary(w_model)


(6) 로지스틱 회귀모델 예측치 생성  (0 ~ 1 사이로 1에 가까울 수록 비 올 확률이 높음)

pred <- predict(w_model,newdata=test,type="response")
pred
4          10          12          13          20 
0.012609233 0.009134209 0.036869457 0.015307117 0.064880550

:
  
  (7) 예측치를 이항형으로 변환 : 예측치가 0.5 이상이면 1 아니면 0

result_pred <- ifelse(pred >= 0.5,1,0)
result_pred
4  10  12  13  20  22  25  27  28  38  39  40  42  43  44  46 
0   0   0   0   0   1   0   0   0   0   0   0   0   0   0   1 


:
  
  (8) 모델평가 : 분류정확도 계산

a <- table(result_pred, test$RainTomorrow)

a      
result_pred  0   1
0 80   7
1  8  14



(9) 확인

per <- (a[1,1]+a[2,2])/sum(a)
per
[1] 0.8896552




(해설) 모델의 예측치와 검정데이터의 y 변수를 이용하여 혼돈 매트릭스를 생성하고, 이를 토대로 
모델의 분류정확도(86%)를 계산할 수 있다.  (80+14) / (80+14+8+7) = 0.8623853





weather_1.csv     (비 X)

weather_2.csv     (비 O)

weather_3.csv



weather_1 <- read.csv("c:/r_temp/weather_1.csv",header=TRUE)






★ (추가연습) 검정데이터 비율을 0.6이나 0.5로 바꾸어 실습한다.







♣ 실습 - 교재 예제 473P



-  꽃 종류 중 2개만 선택하여 로지스틱 모델을 작성한다.



(1) 종의 종류별 개수 출력

table(iris$Species)
setosa versicolor  virginica 
50           50           50 



(2) 꽃 2종류만 선택
iris2 <- subset(iris, Species == 'versicolor' | Species == 'virginica')
str(iris2)



(3) 로지스틱 모델 생성

iris_model <- glm(Species ~., data=iris2, family = 'binomial')

iris_model

(4) fitted 함수를 이용하여 지정된(1~5,51~55)행에 모델을 적용해 본다.  

# 예측 값 출력 , # 예측 값이 0.5 보다 크면 verrsicolor , 작으면 virginica 로 정한다.


fitted(iris_model)[c(1:5,51:55)]
51                      52                      53                     54                   55         

1.171672e-05    4.856237e-05   1.198626e-03   4.220049e-05   1.408470e-03
101                   102                     103                    104                 105 
1.000000e+00  9.996139e-01    9.999990e-01  9.997188e-01   9.999999e-01 


(5) fitted 함수를 전체에 적용하여 f 변수를 만든다. 

f <- fitted(iris_model)
iris2$Species2<-as.numeric(iris2$Species)
[1] 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2
[73] 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2


(6)  f 변수와 numeric 처리된 d$Species 를 비교한다.  

ifelse(f > .5,2,1) == as.numeric(iris2$Species2) - 1

is_correct <- ifelse(f>.5,1,0) == as.numeric(d$Species) - 1
is_correct <- ifelse(f > .5,2,1) == as.numeric(iris2$Species2) - 1

(7) true 처리된 것들의 개수를 구하고 비율 처리한다.    # sum 함수는 TRUE:1, FALSE:0 으로 인식하여 계산한다.

sum(is_correct)
[1] 98
sum(is_correct)/NROW(is_correct)
[1] 0.98

(8) 예측함수를 이용하여 입력된 인자 값에 맞는 예상치를 출력시킨다.

predict(m,newdata=d[c(1,10,55),], type="response")
51           60          105 
1.171672e-05 1.481064e-05 9.999999e-01 



(이해돕기)

sum(c(TRUE,TRUE))
[1] 2
sum(c(TRUE,FALSE))
[1] 1
sum(c(FALSE,FALSE))
[1] 0




♣ 실습

Smarket라는 주식거래 데이터 이용

이 데이터들은 2001~2005년, 총1250일 동안의  S%P 주가지수에 대한 수익율로 나타나있다.


(변수설명)
Year : 2001 ~ 2005

Lag1 ~ Lag5 : Previous 1~5 days

Volume : 이전날의 주식거래량

Today : 충당해야할 그날의 수익률

Direction : Up&Down(수익률의 방향)


install.packages("ISLR")
library(ISLR)
head(Smarket)
cor(Smarket[-9])

train <- subset(Smarket,Year < 2005)

test <- subset(Smarket,Year >= 2005)

stock_model <- glm(Direction ~ Lag1+Lag2+Lag3+Lag4+Lag5+Volume, data=train, family=binomial)

pred <- predict(stock_model,newdata=test,type="response")

result_pred <- ifelse(pred >= 0.5,"UP","Down")

a <- table(result_pred,test$Direction)
a       
result_pred Down Up
Down   77 97
UP     34 44

(77+44)/sum(a)
[1] 0.4801587



install.packages("broom")
library(broom)
data.table(train)
tidy(stock_model)
augment(stock_model)
glance(stock_model)

tidy(train)





▣ 다항 로지스틱 회귀 분석





library(nnet)
m <- multinom(Species~., data=iris)


head(fitted(m))  # 각 행의 데이터가 각 분류에 속할 확률
setosa   versicolor    virginica
1      1 3.129827e-19 2.028491e-49
2      1 1.396405e-15 3.571116e-44


# 모델 생성 시 type의 기본값은 class이므로 생략 가능.

predict(m, newdata=iris[c(1:6),], type="class")
[1] setosa setosa setosa setosa setosa setosa


head(iris$Species)
[1] setosa setosa setosa setosa setosa setosa

pred <- predict(m, newdata=iris) # 전체에 모델을 적용한다.

sum(pred == iris$Species)/NROW(pred)
[1] 0.9866667

xtabs(~ pred + iris$Species)
iris$Species
pred      setosa versicolor virginica     
setosa         50          0         0
versicolor      0         49         1
virginica       0          1        49



(해설)

표를 통해 2개의 예측이 잘못되었고, versicolor를 virginica로 예측한 경우가 1건,

virginica를 versicolor로 예측한 경우가 1건 있었음. 



devtools::install_github("lionel-/vdiffr")
install.packages("freetypeharfbuzz", type = "source")
library(freetypeharfbuzz)

