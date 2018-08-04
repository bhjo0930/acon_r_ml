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
단독_신축신고$등록일시 = as.character(as.numeric(단독_신축신고$등록일
                                              시))
단독_신축신고$보완마감일 = as.character(as.numeric(단독_신축신고$보완
                                               마감일))
단독_신축신고$보완마감일 <- as.POSIXlt(단독_신축신고$보완마감일,
                                   format = '%Y%m%d',
                                   origin = "1970-01-01",
                                   tz ="UTC") # UTC : universal time
단독_신축신고$보완마감일 = as.Date(as.character(단독_신축신고$보완마감
                                            일))
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
options(mc.cores =1) # 명사추출과 같이 오래 걸리는 작업을 할 경우 의무
적으로 넣어줘서 돌다가 멈추는것을 방지하는 기능
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
options(mc.cores=1) # R이 연산을오래 할 때 멈추는걸 일부 방지해주는 기
능