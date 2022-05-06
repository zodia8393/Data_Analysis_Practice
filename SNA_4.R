getwd()
setwd('C:/Users/User/Documents/WS') #집 컴퓨터용 디렉터리

#패키지 호출
library(RSelenium)
library(wdman)
library(dplyr)
library(httr)
library(rvest)

remDr<-remoteDriver(remoteServerAddr='localhost', #드라이버 설정
                    port=4445L,
                    browserName='chrome')
remDr$open() #브라우저 열기
remDr$navigate('https://www.instagram.com/') #인스타그램 페이지로 이동


#아이디 비번
id<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[1]/div/label/input') #아이디 비번에 해당하는 Xpath를 찾기
pw<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[2]/div/label/input')

#로그인 버튼
login_btn<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[3]/button/div') #로그인 버튼에 해당하는 Xpath찾기

id$sendKeysToElement(list("testaccount00118")) #아이디 입력
pw$sendKeysToElement(list("1q2w3e4r1!")) #비번 입력
login_btn$clickElement() #로그인버튼 클릭

#로그인시 나오는 알림설정
btn1<-remDr$findElement(using='xpath',value='//*[@id="react-root"]/section/main/div/div/div/section/div/button') #버튼찾기
btn1$clickElement() #클릭
btn2<-remDr$findElement(using='xpath',value='/html/body/div[6]/div/div/div/div[3]/button[2]') #버튼찾기
btn2$clickElement()  #클릭

#검색창 
searchword<-'계절 + 성별 + 코디'  #ex) 겨울여자코디 (띄어쓰기하면 안됨)
remDr$navigate(paste0('https://www.instagram.com/explore/tags/',searchword)) #해당해시태그 검색시 나오는 화면으로 이동
Sys.sleep(2) #컴퓨터속도와 시스템 속도 맞추기위한 시스템 일시정지 코드 (코드를 하나씩 실행시키면 없어도된다)


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


rslt<-c()  #해시태그 추출한 데이터 저장하는 변수

#반복문 돌리기
for (i in 1:10){ 
  Sys.sleep(1)
  res<-remDr$getPageSource() %>% '[['(1)
  
  url<-res %>% read_html() %>% 
    html_nodes(css='a.xil3i') %>% 
    html_text()
  
  t1<-url[-c(1:removenum)]
  rslt<-append(rslt,t1)
  bu2$clickElement()
}

library(stringr)
result<-str_replace(rslt,'#','') #해시태그 앞에있는 # 지우기
result #데이터 결과물 

#전처리하기 

#특수문자 및 이모티콘 제거
#특정 중복 키워드 ifelse문 정리
#unique통해 중복 합치기
#Combn() 위해 n<m보다 작은 리스트 제거
#게시글 마다 리스트 풀고 combn으로 조합
#Graph로 리스트별 연결된 링크수 가중치
#Source Target Weight 변수명 생성
#for문으로 게시글 모두 반복하여 rbind
#Source Target 중복된 데이터 가중치 합산








