#인스타 해시태그 크롤링

getwd()
setwd('C:/Users/student/Documents/R_WS') #학교 강의실용 디렉터리
#setwd('C:/Users/User/Documents/WS') #집 컴퓨터용 디렉터리

#생각하고 있는 주제 : 계절에 따른 패션트렌드 변화
#어떤 목적으로 어느 지역을 가며 어떠한 의상을 착용하는지
#어떤 것들이 나와서 어떤 서브그룹을 맺고 그 그룹간의 관계를 파악하는것


#필요 패키지 로드
library(RSelenium)
library(wdman)
library(dplyr)
library(httr)
library(rvest)

#셀레니움 드라이브 설정 후 실행
remote<-rsDriver(browser = c("chrome"),chromever ="100.0.4896.127",port="포트명" )
remote$client$open()

remDR<-remote[["client"]]
remDR$navigate("https://www.instagram.com/")

#계정정보 입력
Sys.sleep(2)
id<-remDR$findElement()
id$sendKeysToElement(sendKeys=list())

pw<-remDR$findElement()
pw$sendKeysToElement(sendKeys=list())

#로그인

#로그인하면 뜨는 알림설정

#검색어 지정

#기간 지정(?)

#중복 해시태그 제거 위한 변수 작성

#최근 게시글 클릭

#다음 페이지 넘어가기 css 파싱

#해시태그 합치기 위한 변수 생성

#반복문 시작

#해시태그 값 가져오기

#해시태그 '#'지우기

#사용자 함수 지정 () 전처리 과정

#게시글 리스트 풀고 combn으로 조합

#Graph로 리스트별 연결된 링크수를 가중치로 지정

#Source Target Weight 변수 생성

#for문으로 게시글 모두 반복하여 rbind

#Source Target 중복된 데이터 가중치 합산

#시각화 plot 생성

#중심성 정리

#전체 그래프 확인

#plot 임계치 조정


#최종 결론







