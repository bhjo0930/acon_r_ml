join13= read.csv("join13.csv", header = F ,sep = "|",stringsAsFactors =
                   F )
colnames(join13)[3] = "프로세스"
head(join13,1)
library(slqdf)
단독_신축신고 = sqldf(' select 접수번호,프로세스,등록일시,보완마감일 from
                join13 where 주용도 ="단독주택" and 민원상세유형 ="신축신고" order by
                접수번호, 일련번호 asc ')
a = 단독_신축신고
단독_신축신고 = a
str(단독_신축신고)
단독_신축신고$등록일시 = as.character(as.numeric(단독_신축신고$등록일시))
단독_신축신고$보완마감일 = as.character(as.numeric(단독_신축신고$보완마감일))
단독_신축신고$보완마감일 <- as.POSIXlt(단독_신축신고$보완마감일,
                                   format = '%Y%m%d',
                                   origin = "1970-01-01",
                                   tz ="UTC") # UTC : universal time
단독_신축신고$보완마감일 = as.Date(as.character(단독_신축신고$보완마감일))
단독_신축신고$등록일시 <- as.POSIXlt(단독_신축신고$등록일시,
                                  format = '%Y%m%d%H%M%S',
                                  origin = "1970-01-01",
                                  tz ="UTC") # UTC : universal time
단독_신축신고$등록일시 = as.Date(as.character(단독_신축신고$등록일시))
str(단독_신축신고)
colnames(단독_신축신고)[1] = "CaseID"
colnames(단독_신축신고)[2] = "Activity"
colnames(단독_신축신고)[3] = "Time stamp"
colnames(단독_신축신고)[4] = "Time stamp1"
write.csv(단독_신축신고, "단독_신축신고.csv", row.names =F)

#데이터 병합 및 데이터셋 구성
######
#건축접수 테이블의 경우 이상치제거, 파생변수 생성등의 작업을 마친뒤에

#R에 업로드 하여 다른 데이터와 병합 및 전처리등의 과정을 거쳐 분석에 필요한
#데이터 셋을 구성하였음을 알림
#### 데이터 병합
#건축접수 - regi_new.csv
#건축협의 - 협의222.csv
#건축처리이력 - NA333.csv
#부서명통합 테이블 - 부서전처리.csv
#건축_지역지구구역 - 건축_지역지구구역.csv
####### 건축접수 + 건축협의(부서전처리 병합 후)
regi_new = read.csv("regi_new.csv", header= T, stringsAsFactors = F )
cowork_new = read.csv("협의222.csv", header= T, sep =",",
                      stringsAsFactors = F )
num2 = subset(cowork_new, 협의처리부서>1)
part = read.csv("부서전처리.csv", header= T, sep =",", stringsAsFactors
                = F )
num3 = merge(num2, part, by.x ="협의처리부서", by.y ="협의처리부서명")
table(num3$협의처리부서)
colnames(num3)[2] ="접수번호"
join12_new = merge(num3, regi_new, by.x ="접수번호", by.y ="접수번호")
colnames(join12_new)
join12_new[8]=NULL
colnames(join12_new)[14]="관리시군구명"
write.csv(join12_new, "join121212.csv",row.names=F)
gc()
####### join12_new에서 날짜 안맞는것 전처리하여 다시 저장
colnames(join12_new)
str(join12_new)
c = sqldf('select 접수번호, 협의요청일, 회신일, 실제처리일, 접수일 from
join12_new order by 접수번호 asc')
d = c
str(d)
d$접수일 = as.Date.character((as.character(d$접수일)))

d$실제처리일 = as.Date.character(as.character(d$실제처리일))
d$협의요청일 = as.character(as.integer(d$협의요청일))
d$협의요청일<- as.Date(d$협의요청일, format='%Y%m%d')
d$회신일 = as.character(as.integer(d$회신일))
d$회신일<- as.Date(d$회신일, format='%Y%m%d')
str(d)
e = sqldf('select 접수번호, 협의요청일, 회신일, 실제처리일, 접수일 from d
          where 실제처리일>=회신일 order by 접수번호 asc')
stop = sqldf('select 접수번호, 협의요청일, 회신일, 실제처리일, 접수일 from
             e where 협의요청일>=접수일 order by 접수번호 asc')
zzz = sqldf('select 접수번호, 협의요청일, 회신일, 실제처리일, 접수일 from
            stop where 회신일>=협의요청일 order by 접수번호 asc')
write.csv(zzz, "join12.csv",row.names=F)
####### 건축접수 + 건축처리이력 데이터 조인
regi_new3 = read.csv("NA333.csv", header= T, sep =",",
                     stringsAsFactors = F )
join13 = merge(regi_new3, regi_new, by.x ="접수번호", by.y ="접수번호")
write.csv(join13, "join13.csv",row.names=F)
####### 건축접수 +지역지구구역 데이터 조인
지역 = read.csv("건축_지역지구구역.csv", header= T, sep =",",
              stringsAsFactors = F )
지역merge = merge(regi_new, 지역, by.x ="접수번호", by.y ="접수번호
                ",all.x =TRUE)
write.csv(지역merge,"지역merge.csv",row.names = F)
####### 품질평가표, 시각화를 위한 데이터 셋 구성
gc()
options(mc.cores =1) # 명사추출과 같이 오래 걸리는 작업을 할 경우 의무적으로 넣어줘서 돌다가 멈추는것을 방지하는 기능
regi_new = read.csv("regi_new.csv", header= T, stringsAsFactors = F )
colnames(regi_new)
cowork_new = read.csv("협의222.csv", header= T, sep =",",
                      stringsAsFactors = F )
colnames(regi_new)

regi_new[29] = NULL
regi_new[28] = NULL
regi_new[27] = NULL
regi_new[6] = NULL
regi_new[1] = NULL
colnames(regi_new)[1] = "민원상세유형"
part = read.csv("부서전처리.csv", header= T, sep =",", stringsAsFactors
                = F )
colnames(part)
colnames(cowork_new)
num2 = merge(cowork_new, part, by.x ="협의처리부서", by.y ="협의처리
             부서명",all.x =TRUE)
num3 = subset(num2, 협의처리부서>1)
table(num3$협의처리부서)
colnames(regi_new)
colnames(num3)[2] ="접수번호"
colnames(num3)
join12_new = merge(num3, regi_new, by.x ="접수번호", by.y ="접수번호
                   ",all.x =TRUE)
colnames(join12_new)
join12_new[8]=NULL
colnames(join12_new)
colnames(join12_new)[14]="관리시군구명"
write.csv(join12_new, "join121212.csv",row.names=F)
gc()
library(sqldf)
협의수 = sqldf('select 접수번호,count(접수번호) as 협의수 from
            join12_new group by 접수번호')
regi_new2 = merge(regi_new,협의수 , by.x ="접수번호", by.y ="접수번호
                  ",all.x =TRUE)
write.csv(regi_new2, "접수table_협의수포함",row.names=F)
rm(협의수)
colnames(join12_new)
str(join12_new)
join12 = subset(join12_new, 협의요청일>1)
join12 = subset(join12, 회신일>1)
c = sqldf('select 접수번호, 협의요청일, 회신일, 실제처리일, 접수일 from
          join12 order by 접수번호 asc')

d = c
str(d)
d$접수일 = as.Date.character((as.character(d$접수일)))
d$실제처리일 = as.Date.character(as.character(d$실제처리일))
d$협의요청일 = as.character(as.integer(d$협의요청일))
d$협의요청일<- as.Date(d$협의요청일, format='%Y%m%d')
d$회신일 = as.character(as.integer(d$회신일))
d$회신일<- as.Date(d$회신일, format='%Y%m%d')
str(d)
e = sqldf('select 접수번호, 협의요청일, 회신일, 실제처리일, 접수일 from d
          where 실제처리일>=회신일 order by 접수번호 asc')
stop = sqldf('select 접수번호, 협의요청일, 회신일, 실제처리일, 접수일 from
             e where 협의요청일>=접수일 order by 접수번호 asc')
aa = sqldf('select 접수번호 , min(협의요청일) as 협의요청일 from stop
           group by 접수번호')
bb = sqldf('select 접수번호 , max(회신일) as 회신일 from stop group
           by 접수번호')
sam = merge(aa,bb, by.x ="접수번호", all.x = TRUE)
차이 = as.Date(sam$회신일) - as.Date(sam$협의요청일)
head(차이,100)
협의시간 = as.data.frame(차이)
table(협의시간)
test = cbind(sam, 협의시간)
colnames(test)[2] = "빠른협의요청일"
colnames(test)[3] = "느린회신일"
colnames(test)[4] = "회신_협의빼기"
head(test)
test1 = subset(test, 회신_협의빼기 >= 0)
final = merge(regi_new2, test1, by.x ="접수번호", all.x = TRUE)
write.csv(final, "junyoung.csv",row.names=F)
####join13 join 후 종료지연시군 regi_new2에 merge 하여 junyoun2 로
저장
regi_new3 = read.csv("NA333.csv", header= T, sep =",",
                     stringsAsFactors = F )
colnames(regi_new3)
colnames(regi_new2)
gc()
options("scipen"=100)

options(mc.cores =1)
rm(차이,aa,bb,c,cowork_new, 협의수, 협의시간, d,e, part,num2,num3 )
rm(sam,stop,test,test1)
rm(regi_new)
rm(join12,join12_new)
gc()
join = merge(regi_new3, regi_new2, by.x ="접수번호", by.y ="접수번호",
             all.x=TRUE)
rm(regi_new3)
gc()
colnames(join)
colnames(join)[3]= "프로세스"
join[8]= NULL
colnames(join)
join[16]=NULL
colnames(join)
colnames(join)[10]= "관리시군구명"
colnames(join)[27]= "진행상태"
colnames(join)[28]= "처리구분"
head(join)
library(sqldf)
data = sqldf('select 접수번호,일련번호, 프로세스,등록일시, 실제처리일 from
             join')
av = sqldf('select 접수번호,max(일련번호) as 일련번호, 프로세스,등록일시,
           실제처리일 from data group by 접수번호')
gc()
all = rbind(data, av)
xxx = all[!duplicated(all,fromLast = FALSE)&!duplicated(all,fromLast =
                                                          TRUE),]
x2 = sqldf('select 접수번호 ,max(일련번호) as 일련번호, 프로세스,등록일시,
           실제처리일 from xxx group by 접수번호')
str(x2)
options("scipen"=100)
실제처리일 <- as.Date(as.character(x2$실제처리일, format='%Y%m%d'))
str(실제처리일)
등록일시 = as.character(as.numeric(x2$등록일시))
str(등록일시)
등록일시1 <- as.POSIXlt(등록일시,  format = '%Y%m%d',
                        origin = "1970-01-01",
                        tz ="UTC") # UTC : universal time
등록일시1 = as.Date.POSIXlt(등록일시1)
종료지연일 = as.Date(실제처리일) - as.Date(등록일시1)
str(종료지연일)
종료delay = as.data.frame(종료지연일)
abc = cbind(x2, 종료delay)
colnames(abc)
abcd = subset(abc, 종료지연일 >= 0 )
colnames(abcd)
abcd[5]=NULL
abcd[4]=NULL
abcd[3]=NULL
abcd[2]=NULL
final_final = merge(final, abcd, by.x ="접수번호", by.y ="접수번호",
                    all.x=TRUE)
write.csv(final_final, "end_end.csv", row.names =F )
rm(등록일시, 등록일시1, 실제처리일,종료지연일, x2,xxx, av,abc, abcd,all,종료delay,final)
rm(data)
rm(regi_new2)
gc()
write.csv(join13, "join131313.csv", row.names =F )
colnames(join)
table(join$프로세스)
join13 = join
rm(join)
gc()
library(sqldf)
table(join13$프로세스)
담당자지정수 = sqldf('select 접수번호, count(접수번호) as 담당자지정수
               from join13 where 프로세스 = "담당자지정" group by 접수번호')
보완수 = sqldf('select 접수번호, count(접수번호) as 보완수 from join13
            where 프로세스 = "보완" group by 접수번호')
ab = subset(join13, 프로세스 =경미보완)
경미보완수 = sqldf('select 접수번호, count(접수번호) as 경미보완 from ab 
group by 접수번호')
rm(ab)
트랜잭션수 = sqldf('select 접수번호, count(접수번호) as 트랜젝션수 from
              join13 group by 접수번호')
협의수_처리이력 = sqldf('select 접수번호, count(접수번호) as 협의수_처리
                 이력 from join13 where 프로세스 = "협의" group by 접수번호')
gc()
a = merge(final_final, 담당자지정수 , by.x = "접수번호", all.x =TRUE)
a = merge(a, 보완수 , by.x = "접수번호", all.x =TRUE)
a = merge(a, 경미보완수 , by.x = "접수번호", all.x =TRUE)
a = merge(a, 트랜잭션수 , by.x = "접수번호", all.x =TRUE)
a = merge(a, 협의수_처리이력 , by.x = "접수번호", all.x =TRUE)
write.csv(a, "end_end_end.csv", row.names =F )
rm(보완수, 담당자지정수, 경미보완수, 트랜잭션수, 협의수_처리이력)
rm(final_final, join13)
join12 = read.csv("join121212.csv", header= T, sep =",",
                  stringsAsFactors = F )
colnames(join12)
협의대상아님수 = sqldf('select 접수번호, count(접수번호) as 협의대상아님
                from join12 where 회신결과 = "협의대상" group by 접수번호')
a = merge(a, 협의대상아님수 , by.x = "접수번호", all.x =TRUE)
write.csv(a, "total_행자부.csv", row.names = F)


#############보완이슈 텍스트 분석
abc = 보완내용$처리내역
head(abc)
a = gsub("\\d+"," ",abc) #모든 숫자 제거
a = gsub("\t", " ",a)
a = gsub("\n", " ",a)
a = gsub("[[:punct:]]"," ",a) #모든 특수문자 제거
a= gsub("[A-z]"," ",a)
head(a)
str(a)
mergeUserDic(data.frame("개발행위","ncn"))
mergeUserDic(data.frame("산지전용","ncn"))
gc() # 불필요한 메모리 정리
options(mc.cores=1) # R이 연산을오래 할 때 멈추는걸 일부 방지해주는 기능

Noun = sapply(a, extractNoun, USE.NAMES = F) ## 명사 추출 소스
c= unlist(Noun) ###리스트 형태로 형 변호
str(c)
temp = Filter(function(x) {nchar(x)>2}, c)
head(temp,100)
write(unlist(temp),"sample.txt")
rev<-read.table("sample.txt")
nrow(rev)
str(rev)
wordcount<-table(rev) #factor 형의 자료를 table형으로 변환하면서 chr로 변환됨
str(wordcount)
Dia_top_keyword<-sort(wordcount,decreasing=T)
head(Dia_top_keyword,100)
write.csv(Dia_top_keyword,"aaaa.csv")
wordcount = read.csv("top_keyword_단독주택보완.csv", header= T, sep
                     =",", stringsAsFactors = F )
library(wordcloud)
library(RColorBrewer)
##wordcloud ## 시각화 갯수 선정하기 (from table)
Visual = head(wordcount,1000)
Visual = table(Visual)
palete <- brewer.pal(7,"Set1")
wordcloud(names(Visual),freq=Visual,scale=c(4,1),rot.per=0.25,min.freq=
            2,
          random.order=F,random.color=T,colors=palete)

#####################
##협의부서네트워크분석
부서 = read.csv("join12.csv", header= T, sep =",", stringsAsFactors = F)
부서명전처리 = read.csv("부서전처리.csv", header= T, sep =",",
                  stringsAsFactors = F )
str(부서명전처리)
library(sqldf)
colnames(부서)
colnames(부서)[8] ="관리시군구명"
colnames(부서)
colnames(부서명전처리)[1] ="협의처리부서"

table(부서$협의처리부서)
aaa = table(부서$협의처리부서)
write.csv (aaa, "협의부서개수.csv", row.names=F)
table(부서명전처리$협의처리부서)
data = merge(부서, 부서명전처리, by.x = "협의처리부서", by.y = "협의처리
               부서", all.x = TRUE)
table(data$전처리부서)
colnames(data)
data[8]=NULL
부서명부서명 = sqldf('select 협의처리부서 from data')
abc = unique(부서명부서명)
library(KoNLP)
library(tm)
library(rJava)
library(plyr)
library(stringr)
library(arules)
library(igraph)
colnames(data)
table(data$관리시군구명)
gc()
test = sqldf('select 접수번호, 전처리부서 from data where 주용도 = "단독
             주택" and 민원상세유형 = "신축신고" and 관리시군구명 ="경기파주시" ')
f = subset(test, 전처리부서>1)
str_paste <- function(x)
{
  a <- paste(x,collapse = " ")
  print(str(a))
  return(a)
}
bbb <- aggregate(f[,2],list(f[,1]),str_paste)
colnames(bbb) <- c("접수번호","전처리부서")
t = as.matrix(bbb$전처리부서) ###행의 갯수가 너무 많아지면 매트릭스를만드는데 용량의 문제로 shut down 됨
options(mc.cores =1) # 명사추출과 같이 오래 걸리는 작업을 할 경우 의무적으로 넣어줘서 돌다가 멈추는것을 방지하는 기능
ontology = readLines("부서사전.txt")

head(ontology)
Cor = Corpus(VectorSource(t))
dtm = DocumentTermMatrix(Cor, list(dictionary = ontology))
DtmMtx = as.matrix(dtm)
Dtmtran = as(DtmMtx, "transactions")
ares = apriori(Dtmtran, parameter = list(minlen=1, supp=0.005,
                                         conf=0.01))
detach(package:tm, unload=TRUE)
inspect(ares)
# 중복되는 규칙 제거
ares.sorted <- sort(ares, by="lift")
subset.matrix <- is.subset(ares.sorted, ares.sorted)
subset.matrix[lower.tri(subset.matrix, diag=T)] <- NA
redundant <- colSums(subset.matrix, na.rm=T) >= 1
ares.pruned <- ares.sorted[!redundant]
inspect(ares.pruned)
aa = subset(ares.pruned, lift >1.0001 ) # Lift 1이상만 남기기
inspect(aa)
rules <- labels(aa, ruleSep=" ")#rules
rules <- sapply(rules, strsplit, " ", USE.NAMES=F)#rules
rulemat <- do.call("rbind", rules)
bb = as.data.frame(rulemat)
colnames(bb) = c("a","b")
head(bb,1)
summary(bb)
g = graph.data.frame(bb, directed = FALSE)
summary(g)
g$layout = layout.fruchterman.reingold(g)
V(g)$size = degree(g) # Size 연결중심성 : 한 노드에 얼마나 많은 링크: 허브 역할을 하는 노드
clo = closeness(g) # 색깔 : 근접중심성: 각 노드간 거리 개념, 최단거리의합: 가장 중심이 되는 노드
clo.score = round((clo-min(clo))*length(clo)/max(clo)) + 1
clo.colors = rev(heat.colors(max(clo.score)))
V(g)$color = clo.colors[clo.score]
plot(g)

#====================================================================#
# 공공 서비스 품질 관리 모델
#
#
#
# 건축인허가 데이터셋(KCP07) 추가 전처리
#
#====================================================================#
########## DS_KCP07 에서 17개 특정 유형에 대한 데이터만 추출 ##########
## 데이터 로드 ##
df.KCP07.Total <- fread("DS_KCP07_v3.csv", header = T, stringsAsFactors =
                          F, data.table = F)
## 타겟 유형이 변하는 경우 이 부분 수정 ##
Index.Target.Type <- data.frame("주용도" = c("단독주택", "단독주택", "단독주택", "
                                          제2종근린생활시설", "공동주택",
                                          "제1종근린생활시설", "단독주택", "단독
                                          주택", "제2종근린생활시설", "제2종근린생활시설",
                                          "공장", "창고시설", "제1종근린생활시설
                                          ", "공장", "공장",
                                          "동.식물관련시설", "동.식물관련시설"),
                                
                                "민원상세유형" = c("신축신고", "신축허가", "허가/
                                             신고사항변경-신고", "신축허가", "신축허가",
                                             "신축허가", "허가/신고사항변경-허
                                             가", "증축신고", "신축신고", "허가/신고사항변경-허가",
                                             "허가/신고사항변경-허가", "신축신
                                             고", "신축신고", "신축허가", "증축허가",
                                             "신축신고", "신축허가"),
                                stringsAsFactors = F)
Index.Target.Type$주용도_민원유형 <- paste0(Index.Target.Type$주용도, "_",
                                     Index.Target.Type$민원상세유형)
df.Temp <- data.frame()
for (i in 1:nrow(Index.Target.Type)) {
  
  df.Sub <- subset(df.KCP07.Total, df.KCP07.Total$주용도_민원유형 ==
                     Index.Target.Type[i,3])
  
  df.Temp <- rbind(df.Temp, df.Sub)
}
write.csv(df.Temp, "DS_KCP07_17Types.csv", row.names = F, col.names = T)
###############################################################
########## 협의부서 수 파생변수 생성 ##########
## 데이터 로드 및 서브셋 생성 ##
df.KCP02 <- fread("협의원본.csv", header = T, stringsAsFactors = F, data.table = F)
df.KCP07.17Type <- fread("DS_KCP07_17Types_v2.csv", header = T,
                         stringsAsFactors = F, data.table = F)
df.KCP07.17Type.sub <- subset(df.KCP07.17Type, df.KCP07.17Type$단순복합 ==
                                "복합")
dt.KCP02 <- as.data.table(df.KCP02)
setkey(dt.KCP02, 접수_번호)
dt.Minwon.List <- as.data.table(unique(df.KCP07.17Type.sub$접수번호))
colnames(dt.Minwon.List) <- "접수_번호"
##17개 유형에 대한 민원 번호만 집계
dt.KCP02.v2 <- merge(dt.KCP02, dt.Minwon.List)
dt.Minwon.Jupsu.Num <- as.data.table(unique(dt.KCP02.v2$접수_번호))
dt.Jupsu.Num.n.Dept.Cnt <- data.table()
for ( minwon.cnt in 1:nrow(dt.Minwon.Jupsu.Num)) {
  start.Time <- Sys.time()
  Jupsu.Num <- dt.Minwon.Jupsu.Num[minwon.cnt,]
  dt.Minwon.By.Jupsu <- dt.KCP02.v2[접수_번호 %in% Jupsu.Num]
  Dept.Cnt <- length(unique(dt.Minwon.By.Jupsu$협의처리부서))
  dt.Jupsu.Num.n.Dept.Cnt.Temp <- data.table("접수_번호" = Jupsu.Num, "협의부서수" = Dept.Cnt)
  dt.Jupsu.Num.n.Dept.Cnt <- rbind(dt.Jupsu.Num.n.Dept.Cnt,
                                   dt.Jupsu.Num.n.Dept.Cnt.Temp)
} # end for ( minwon.cnt in 1:nrow(df.KCP02))
End.Time <- Sys.time()
close(pb.Dept.Cnt)
dt.Jupsu.Num.n.Dept.Cnt.2 <- dt.Jupsu.Num.n.Dept.Cnt
colnames(dt.Jupsu.Num.n.Dept.Cnt.2) <- c("접수_번호", "협의부서수")
setkey(dt.Jupsu.Num.n.Dept.Cnt.2, 접수_번호)
dt.KCP02.v3 <- merge(dt.KCP02, dt.Jupsu.Num.n.Dept.Cnt.2)
colnames(dt.KCP02.v3)[1] <- c("접수번호")
setkey(dt.KCP02.v3, 접수번호)
dt.KCP07.17Type <- as.data.table(df.KCP07.17Type)
setkey(dt.KCP07.17Type, 접수번호)
## 불필요 및 중복 항목 삭제 ##
dt.KCP02.v4 <- dt.KCP02.v3[,c(1,9)]
dt.KCP02.v5 <- dt.KCP02.v4[!duplicated(dt.KCP02.v4$접수번호),]
dt.KCP07.17T.v3 <- merge(df.KCP07.17Type, dt.KCP02.v5, by = "접수번호", all.x
                         = T)
## NA 값 0으로 치환 ##
dt.KCP07.17T.v3[c("협의부서수")][is.na(dt.KCP07.17T.v3[c("협의부서수")])] <- 0
###############################################################
##### 처리이력 데이터 - 보완 정보 취득 #####
df.KCP03<- fread("처리이력원본.csv", header = T, stringsAsFactors = F,
                 data.table = F)
dt.KCP03<- as.data.table(df.KCP03)
setkey(dt.KCP03, 접수번호)
df.KCP03$등록일시 <- as.character.integer64(df.KCP03$등록일시)
dt.KCP03$실제보완마감일시 <- as.character.integer64(dt.KCP03$실제보완마감일시)
## 처리이력 원본 해당 민원만 필터링 - 전처리
df.KCP07 <- fread("DS_KCP07_17Types_v3.csv", header = T, stringsAsFactors
                  = F, data.table = F)
dt.Minwon.List <- as.data.table(unique(df.KCP07$접수번호))
colnames(dt.Minwon.List) <- "접수번호"
setkey(dt.Minwon.List, 접수번호 )
##17개 유형에 대한 민원 번호만 집계
dt.KCP03.v2 <- merge(dt.KCP03, dt.Minwon.List)
write.csv(dt.KCP03.v2, "DS_KCP03_17Types_v1.csv", row.names = F, col.names
          = T)
dt.KCP03.v2 <- fread("DS_KCP03_17Types_v1.csv", header = T,
                     stringsAsFactors = F, data.table = T)
dt.KCP03.v2$등록일 <- substr(dt.KCP03.v2$등록일시, 1, 8)
dt.KCP03.v2$실제보완마감일 <- substr(dt.KCP03.v2$실제보완마감일시, 1, 8)
dt.KCP03.v2$등록년도 <- substr(dt.KCP03.v2$등록일, 1, 4)
dt.KCP03.v2$실제보완마감년도 <- substr(dt.KCP03.v2$실제보완마감일, 1, 4)
dt.KCP03.v2$등록일 <- as.Date(dt.KCP03.v2$등록일, "%Y%m%d")
dt.KCP03.v2$실제보완마감일 <- as.Date(dt.KCP03.v2$실제보완마감일, "%Y%m%d")
dt.KCP03.v2$보완마감일 <- as.Date(dt.KCP03.v2$보완마감일, "%Y%m%d")
dt.KCP03.v3 <- dt.KCP03.v2[,c(1:4,11,14,12,6:9,15,13)]
## 보완처리 시간 계산
dt.KCP03.v3$등록일 <- as.Date(dt.KCP03.v3$등록일)
dt.KCP03.v3$실제보완마감일 <- as.Date(dt.KCP03.v3$실제보완마감일)
## 경미보완 제외 보안이 발생한 건만 추출
dt.Bowan.Only <- dt.KCP03.v3[진행상태 %in% "보완"]
#length(unique(dt.Bowan.Only$접수번호))
dt.Minwon.Jupsu.Num <- as.data.table(unique(dt.Bowan.Only$접수번호))
dt.Jupsu.Num.n.Bowan.Cnt <- data.table()
Start.Time <- Sys.time()
for ( minwon.cnt in 1:nrow(dt.Minwon.Jupsu.Num) ) {
  
  Jupsu.Num <- dt.Minwon.Jupsu.Num[minwon.cnt]
  
  dt.Minwon.By.Jupsu <- dt.Bowan.Only[접수번호 %in% Jupsu.Num]
  
  Bowan.Days <- as.numeric(sum(dt.Minwon.By.Jupsu$실제보완마감일 -
                                 dt.Minwon.By.Jupsu$등록일))
  
  dt.Jupsu.Num.n.Bowan.Cnt.Temp <- data.table("접수번호" = Jupsu.Num, "보완처리시간" = Bowan.Days)
  
  li.Jupsu.Num.n.Bowan.Cnt <- list(dt.Jupsu.Num.n.Bowan.Cnt,
                                   dt.Jupsu.Num.n.Bowan.Cnt.Temp )
  dt.Jupsu.Num.n.Bowan.Cnt <- rbindlist(li.Jupsu.Num.n.Bowan.Cnt)
  
  ## 주기적으로 메모리 청소 ##
  if (minwon.cnt %% 50000 == 0) {
    gc()
    cat("Complete Cnt:" ,minwon.cnt , "\n")
  }
} # end for ( minwon.cnt in 1:nrow(df.KCP02))
End.Time <-Sys.time()
gc()
cat("소요시간 :", round(difftime(End.Time, Start.Time, unit = "min"),2), "min\n")
close(pb.Bowan.Cnt)

colnames(dt.Jupsu.Num.n.Bowan.Cnt)[1] <- "접수번호"
write.csv(dt.Jupsu.Num.n.Bowan.Cnt, "건축인허가_보완시간_민원별.csv",
          row.names = F, col.names = T)
###############################################################
#====================================================================#
# 공공 서비스 품질 관리 모델
#
#
#
# 서비스 품질 지표 테이블 생성
#
#====================================================================#
########## 데이터 로드 ##########
df.KCP07.17Type <- fread("DS_KCP07_17Types_v7.csv", header = T,
                         stringsAsFactors = F, data.table = F)
##### 날짜 변수 날짜 속성으로 변경 #####
df.KCP07.17Type$실제처리일 <- as.Date(df.KCP07.17Type$실제처리일)
df.KCP07.17Type$접수신청일 <- as.Date(df.KCP07.17Type$접수신청일)
df.KCP07.17Type$접수일 <- as.Date(df.KCP07.17Type$접수일)
df.KCP07.17Type$처리예정일 <- as.Date(df.KCP07.17Type$처리예정일)
df.KCP07.17Type$최초저장일 <- as.Date(df.KCP07.17Type$최초저장일)
df.KCP07.17Type$빠른협의요청일 <- as.Date(df.KCP07.17Type$빠른협의요청일)
df.KCP07.17Type$느린회신일 <- as.Date(df.KCP07.17Type$느린회신일)
########## Index Calculation ##########
Index.Target.Type <- data.frame("주용도" = c("단독주택", "단독주택", "단독주택", "
제2종근린생활시설", "공동주택",
                                          "제1종근린생활시설", "단독주택", "단독
주택", "제2종근린생활시설", "제2종근린생활시설",
                                          "공장", "창고시설", "제1종근린생활시설
", "공장", "공장",
                                          "동.식물관련시설", "동.식물관련시설"),
                                
                                "민원상세유형" = c("신축신고", "신축허가", "허가/
                                             신고사항변경-신고", "신축허가", "신축허가",
                                             "신축허가", "허가/신고사항변경-허
                                             가", "증축신고", "신축신고", "허가/신고사항변경-허가",
                                             "허가/신고사항변경-허가", "신축신
                                             고", "신축신고", "신축허가", "증축허가",
                                             "신축신고", "신축허가"),
                                stringsAsFactors = F)
Index.Target.Type$주용도_민원유형 <- paste0(Index.Target.Type$주용도, "_",
                                     Index.Target.Type$민원상세유형)
## 단순/복합, 주용도, 민원 유형에 대한 1차 서브셋 생성
## 이 레벨에서 상대 지표 계산
for (target in 1:nrow(Index.Target.Type)) {
  
  Main.Purpose <- Index.Target.Type[target,1]
  Minwon.Type <- Index.Target.Type[target,2]
  Purpose.n.Type <- Index.Target.Type[target,3]
  
  df.Minwon <- subset(df.KCP07.17Type, df.KCP07.17Type$주용도 == Main.Purpose &
                        df.KCP07.17Type$민원상세유형 == Minwon.Type &
                        df.KCP07.17Type$협의유형 == Complex.Type )
  
  cat("1.", Complex.Type, "-", Main.Purpose, "-", Minwon.Type, ": 작업 시작\n")
  
  ## 관리시군구별 2차 서브셋 생성 ##
  ## 이 레벨에서 개별 지표 산출
  City.Name.List <- as.data.frame(unique(df.Minwon$관리시군구명))
  li.Index.Table <- list()
  df.Index.Table.City <- data.frame()
  for ( city.cnt in 1:nrow(City.Name.List) ) {
    
    cat(" 2.", Complex.Type, "-", Main.Purpose, "-", Minwon.Type, "-",                                 
        City.Name.List[city.cnt,], ": 작업 시작\n")
    
    df.Minwon.City <- subset(df.Minwon, df.Minwon$관리시군구명 ==
                               City.Name.List[city.cnt,])
    
    ### 민원 건수 ###
    Total.Minwon <- nrow(df.Minwon.City)
    
    ### 지자체 구분 값 ###
    Area.Category <- unique(df.Minwon.City$지자체구분)
    
    ### 시도명 ###
    State.Name <- unique(df.Minwon.City$시도명)
    
    ### 시군구명 ###
    City.Name <- unique(df.Minwon.City$시군구명)
    
    ### a. 관리시군구_응답성 ###
    ### 공식 : ∑(민원 접수 시간 ? 민원인 신청 시간)/∑(민원 건수)
    ### 사용 변수 : 접수일-접수신청일 / 관리시군구_민원건수
    if (nrow(df.Minwon.City) == 0) {
      Response <- NA
    } else {
      Response <- as.numeric(sum(df.Minwon.City$접수일 - df.Minwon.City$접수신청일) / nrow(df.Minwon.City))
    }
    
    ### b. 관리시군구_신뢰성 ###
    ### 공식 : ∑(완료 예정일 이행 건수)/∑(민원 건수) * 100(%)
    ### 사용 변수 : 처리예정일,실제처리일,관리시군구_민원건수
    if (nrow(df.Minwon.City) == 0) {
      Complete <- NA
    } else {
      Complete <- nrow(df.Minwon.City[df.Minwon.City$처리예정일 >=
                                        df.Minwon.City$실제처리일,]) / nrow(df.Minwon.City) * 100
    }
    ### c. 관리시군구_전문성 ###
    ### 공식 : ∑(당해년도 평균 보완 건수 )/ ∑(전년도 평균 보완 건수) * 100(%)
    ### 사용 변수 : 보완수
    ## 지자체별로 모두 2014 ~ 2016에 대한 기록이 존재하는 것이 아니므로 계산    을 위해
    ## 임의로 2014~ 2016에 대한 정보를 담을 테이블 생성
    df.Supplement.by.Year.Tmp <- data.frame("처리년도" = c(2014, 2015,
                                                       2016))
    
    ## 민원이 지자체별로 연간 1건 이하로 발생하는 경우에 대한 임의 처리를 위한    작업
    df.year.2014 <- subset(df.Minwon.City, df.Minwon.City$처리년도 == 2014)
    df.year.2015 <- subset(df.Minwon.City, df.Minwon.City$처리년도 == 2015)
    df.year.2016 <- subset(df.Minwon.City, df.Minwon.City$처리년도 == 2016)
    
    if ( nrow(df.year.2014) < 2 ) {
      df.Supplement.by.Year.Agg.2014 <- data.frame("처리년도" =
                                                     df.year.2014$처리년도, "보완수" = df.year.2014$보완수 )
    } else {
      df.Supplement.by.Year.Agg.2014 <- as.data.frame(aggregate(보완수 ~ 처
                                                                   리년도, data = df.year.2014, mean))
    }
    
    if ( nrow(df.year.2015) < 2 ) {
      df.Supplement.by.Year.Agg.2015 <- data.frame("처리년도" =
                                                     df.year.2015$처리년도, "보완수" = df.year.2015$보완수 )
    } else {
      df.Supplement.by.Year.Agg.2015 <- as.data.frame(aggregate(보완수 ~ 처
                                                                   리년도, data = df.year.2015, mean))
    }
    
    if ( nrow(df.year.2016) < 2 ) {
      df.Supplement.by.Year.Agg.2016 <- data.frame("처리년도" =
                                                     df.year.2016$처리년도, "보완수" = df.year.2016$보완수 )
    } else {
      df.Supplement.by.Year.Agg.2016 <- as.data.frame(aggregate(보완수 ~ 처
                                                                   리년도, data = df.year.2016, mean))
    }
    
    
    df.Supplement.by.Year.Agg <- rbind(df.Supplement.by.Year.Agg.2014,
                                       df.Supplement.by.Year.Agg.2015, df.Supplement.by.Year.Agg.2016)
    
    df.Supplement.by.Year <- merge(df.Supplement.by.Year.Tmp,
                                   df.Supplement.by.Year.Agg, all.x = T, by = "처리년도")
    df.Supplement.by.Year[c("보완수")][is.na(df.Supplement.by.Year[c("보완수")])]
    <- 0
    
    ## 전문성 계산 ##
    if (df.Supplement.by.Year[df.Supplement.by.Year$처리년도 == 2014,2] == 0
        &
        df.Supplement.by.Year[df.Supplement.by.Year$처리년도 == 2015,2] ==
        0 ) {
      
      Professionality <- 0
      
    } else if (df.Supplement.by.Year[df.Supplement.by.Year$처리년도 ==
                                     2014,2] == 0 &
               df.Supplement.by.Year[df.Supplement.by.Year$처리년도 ==
                                     2015,2] > 0 ) {
      
      Professionality <- df.Supplement.by.Year[df.Supplement.by.Year$처리년도 == 2015,2] * 100
      
    } else {
      Professionality <- (df.Supplement.by.Year[df.Supplement.by.Year$처리년도 == 2015,2]
                          / df.Supplement.by.Year[df.Supplement.by.Year$처리년도 == 2014,2]) * 100
    }
    
    ### d. 관리시군구_협조성 ###
    ### 공식 : ∑(협조시간)/∑(협조 민원 건수)
    ### 사용 변수 : 빠른 협의 요청일, 느린회신일 <- 이미 계산된 필드(회신_협의    빼기)가 있으므로 이 컬럼으로 대체    
    
    
    if (Complex.Type == "단순" | nrow(df.Minwon.City[!df.Minwon.City$협의수
                                                   == 0,]) == 0) {
      
      Cooperate <- NA
      
    } else {
      
      ## 협의유형이 복합/통합(복합이 존재하는) 인 경우
      df.Minwon.City.2 <- subset(df.Minwon.City, !df.Minwon.City$협의부서수
                                 == 0)
      Cooperate <- (sum(df.Minwon.City.2$협의처리시간 / df.Minwon.City.2$협의부서수)) / nrow(df.Minwon.City[!df.Minwon.City$협의수 == 0,])
      
    }
    
    ### e. 관리시군구_신속성 ###
    ### 공식 :∑(완료예정시간- 처리시간)/∑(민원 건수)
    ### 사용 변수 : 처리예정일, 실제처리일, 관리시군구_민원건수
    if (nrow(df.Minwon.City) == 0) {
      Speed <- NA
    } else {
      Speed <- as.numeric(sum(df.Minwon.City$처리예정일 - df.Minwon.City
                              $실제처리일) / nrow(df.Minwon.City))
    }
    
    ### f. 욕구 충족성 ###
    ### 공식 : ∑(민원 완료 건수/∑(민원 건수) * 100(%)
    ### 사용 변수 : 진행상태(완료)
    if (nrow(df.Minwon.City) == 0) {
      Effectiveness <- NA
    } else {
      Effectiveness <- nrow(df.Minwon.City[df.Minwon.City$진행상태 == "완료",]) / nrow(df.Minwon.City) * 100
    }
    
    ### g. 내부품질 개선 ###
    ### 공식 : ∑(당해년도 건당 평균 프로세스 수)/∑(전년도 건당 평균 프로세스 수) * 100(%)

    ### 사용 변수 : 트랜잭션수
df.Transaction.by.Year.Tmp <- data.frame("처리년도" = c(2014, 2015, 2016))

df.year.2014 <- subset(df.Minwon.City, df.Minwon.City$처리년도 == 2014)
df.year.2015 <- subset(df.Minwon.City, df.Minwon.City$처리년도 == 2015)
df.year.2016 <- subset(df.Minwon.City, df.Minwon.City$처리년도 == 2016)

if ( nrow(df.year.2014) < 2 ) {
  df.Transaction.by.Year.Agg.2014 <- data.frame("처리년도" =
                                                  df.year.2014$처리년도, "트랜젝션수" = df.year.2014$트랜젝션수 )
} else {
  df.Transaction.by.Year.Agg.2014 <- as.data.frame(aggregate(트랜젝션수 ~
                                                                    처리년도, data = df.year.2014, mean))
}

if ( nrow(df.year.2015) < 2 ) {
  df.Transaction.by.Year.Agg.2015 <- data.frame("처리년도" =
                                                  df.year.2015$처리년도, "트랜젝션수" = df.year.2015$트랜젝션수 )
} else {
  df.Transaction.by.Year.Agg.2015 <- as.data.frame(aggregate(트랜젝션수 ~
                                                                    처리년도, data = df.year.2015, mean))
}

if ( nrow(df.year.2016) < 2 ) {
  df.Transaction.by.Year.Agg.2016 <- data.frame("처리년도" =
                                                  df.year.2016$처리년도, "트랜젝션수" = df.year.2016$트랜젝션수 )
} else {
  df.Transaction.by.Year.Agg.2016 <- as.data.frame(aggregate(트랜젝션수 ~
                                                                    처리년도, data = df.year.2016, mean))
}

df.Transaction.by.Year.Agg <- rbind(df.Transaction.by.Year.Agg.2014,
                                    df.Transaction.by.Year.Agg.2015, df.Transaction.by.Year.Agg.2016)
df.Transaction.by.Year <- merge(df.Transaction.by.Year.Tmp,
                                df.Transaction.by.Year.Agg, all.x = T, by = "처리년도")    

df.Transaction.by.Year[c("트랜젝션수")][is.na(df.Transaction.by.Year[c("트랜
젝션수")])] <- 0

## 내부품질개선 계산 ##
if (df.Transaction.by.Year[df.Transaction.by.Year$처리년도 == 2014,2] == 0
    &
    df.Transaction.by.Year[df.Transaction.by.Year$처리년도 == 2015,2] ==
    0 ) {
  
  QualityImprove <- 0
  
} else if (df.Transaction.by.Year[df.Transaction.by.Year$처리년도 ==
                                  2014,2] == 0 &
           df.Transaction.by.Year[df.Transaction.by.Year$처리년도 ==
                                  2015,2] > 0 ) {
  
  QualityImprove <- df.Supplement.by.Year[df.Supplement.by.Year$처리년도 == 2015,2] * 100
  
} else {
  QualityImprove <- (df.Transaction.by.Year[df.Transaction.by.Year$처리년도 == 2015,2]
                     / df.Transaction.by.Year[df.Transaction.by.Year$처리년도 == 2014,2]) * 100
}

### h. 관리시군구_만족도 ###
### 공식 : ∑(당해년도 건당 평균 프로세스 수)/∑(전년도 건당 평균 프로세스수) * 100(%)
### 사용 변수 : 트랜잭션수
Satisfaction <- NA

### Output Table Creation ###
li.Index.Table[[city.cnt]] <- c(Main.Purpose, Minwon.Type, Purpose.n.Type,
                                Area.Category, Complex.Type,
                                City.Name.List[city.cnt,],State.Name,
                                City.Name, Total.Minwon,
                                Response, Complete, Professionality,
                                Cooperate, Speed, Effectiveness,
                                QualityImprove, Satisfaction)

unlist.Index.Table <- unlist(li.Index.Table[city.cnt])
mat.Index.Table <- matrix(unlist.Index.Table, ncol = 17, byrow = T)
df.Index.Table.City <- rbind(df.Index.Table.City, mat.Index.Table)

cat(" 2.", Complex.Type, "-", Main.Purpose, "-", Minwon.Type, "-",
    City.Name.List[city.cnt,], ": 작업 완료\n")

  } #end for ( city.cnt in 1:nrow(City.Name.List) )
  
  ## 현재 단순/복합+주용도_민원유형별 상대지표 산출 ##
  cat(" 3.", Complex.Type, "-", Main.Purpose, "-", Minwon.Type, ": 상대지표 작
      업 시작\n")
  
  colnames(df.Index.Table.City) <- c("주용도", "민원유형", "주용도_민원유형","지자
                                     체구분", "협의유형",
                                     "관리시군구명", "시도명", "시군구명", "관리시
                                     군구_민원건수",
                                     "관리시군구_응답성", "관리시군구_신뢰성", "
                                     관리시군구_전문성", "관리시군구_협조성", "관리시군구_신속성",
                                     "관리시군구_욕구충족성", "관리시군구_내부품
                                     질개선", "관리시군구_만족도")
  
  ### 변수 속성 변경 ###
  df.Index.Table.City$관리시군구_민원건수 <- as.numeric(df.Index.Table.City$관리시군구_민원건수)
  df.Index.Table.City$관리시군구_응답성 <- as.numeric(df.Index.Table.City$관리시군구_응답성)
  df.Index.Table.City$관리시군구_신뢰성 <- as.numeric(df.Index.Table.City$관리시군구_신뢰성)
  df.Index.Table.City$관리시군구_전문성 <- as.numeric(df.Index.Table.City$관리시군구_전문성)
  df.Index.Table.City$관리시군구_협조성 <- as.numeric(df.Index.Table.City$관리시군구_협조성)
  df.Index.Table.City$관리시군구_신속성 <- as.numeric(df.Index.Table.City$관리