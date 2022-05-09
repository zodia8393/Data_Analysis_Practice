getwd()
setwd('C:/Users/User/Documents/WS') #집 컴퓨터용 디렉터리

library(RSelenium)
library(wdman)
library(dplyr)
library(httr)
library(rvest)

remDr<-remoteDriver(remoteServerAddr='localhost',
                    port=4445L,
                    browserName='chrome')
remDr$open()
remDr$navigate('https://www.instagram.com/')


#아이디 비번
id<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[1]/div/label/input')
pw<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[2]/div/label/input')

#로그인 버튼
login_btn<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[3]/button/div')

id$sendKeysToElement(list("testaccount00118"))
pw$sendKeysToElement(list("1q2w3e4r1!"))
login_btn$clickElement()

#로그인시 나오는 알림설정
btn1<-remDr$findElement(using='xpath',value='//*[@id="react-root"]/section/main/div/div/div/section/div/button')
btn1$clickElement()
btn2<-remDr$findElement(using='xpath',value='/html/body/div[6]/div/div/div/div[3]/button[2]')
btn2$clickElement()

#검색창 
searchword<-'데일리룩'
remDr$navigate(paste0('https://www.instagram.com/explore/tags/',searchword))
Sys.sleep(2)


#중복 해시태그 제거 변수 생성
res<-remDr$getPageSource() %>% '[['(1)
url<-res %>% read_html() %>% 
  html_nodes(css='a.LFGsB.xil3i') %>% 
  html_text()
removenum<-length(url)
Sys.sleep(2)

#최근 게시글 클릭
bu1<-remDr$findElement(using='css',value='#react-root > section > main > article > div.EZdmt > div > div > div:nth-child(1) > div:nth-child(1) > a > div.eLAPa > div._9AhH0')
bu1$clickElement()

#다음페이지 넘기기
bu2<-remDr$findElement(using='css',value='body > div.RnEpo._Yhr4 > div.Z2Inc._7c9RR > div > div > button > div > span > svg')
bu2$clickElement()

rslt<-c()
rslt2<-{}


for (i in 1:10){
  Sys.sleep(1)
  res<-remDr$getPageSource() %>% '[['(1)
  url<-res %>% read_html() %>% 
    html_nodes(css='a.xil3i') %>% 
    html_text()
  
  t1<-url[-c(1:removenum)]
  rslt<-append(rslt,t1)
  #rslt2[[i]]<-rslt
  bu2$clickElement()
}
rslt2
rslt[2]
rslt

#리스트1번지정
#게시글 넘어가면 리스트 2번지정 (반복)


library(stringr)
result<-str_replace(rslt,'#','')
result
class(result)
result1<-as.data.frame(result)

#전처리하기
#특수문자 및 이모티콘 제거
rs_1<-str_replace_all(result1$result,"[^가-힣]","") #한글만 남기고 나머지는 공백으로 만들기
rs_1a<-as.data.frame(rs_1)
rs_2<-rs_1a[!apply(is.na(rs_1a)|rs_1a=="",1,all),] #NA값이거나 공백일경우 제거 (자료형이 문자형으로 바뀜)
rs_2a<-as.data.frame(rs_2)
class(rs_2a)

write.csv(rs_2a,'sample.csv')


#특수문자 및 이모티콘 제거
#특정 중복 키워드 ifelse문 정리
#unique통해 중복 합치기
#Combn() 위해 n<m보다 작은 리스트 제거
#게시글 마다 리스트 풀고 combn으로 조합
#Graph로 리스트별 연결된 링크수 가중치
#Source Target Weight 변수명 생성
#for문으로 게시글 모두 반복하여 rbind
#Source Target 중복된 데이터 가중치 합산








