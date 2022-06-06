getwd()
setwd('C:/Users/User/Documents/WS') #집 컴퓨터용 디렉터리
#setwd('C:/Users/student/Documents/R_WS')#학교 강의실용 디렉터리

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
btn1<-remDr$findElement(using='xpath',value='/html/body/div[1]/section/main/div/div/div/section/div/button')
btn1$clickElement()

remDr$refresh()

btn2<-remDr$findElement(using='xpath',value='/html/body/div[1]/div/div[1]/div/div[2]/div/div/div[1]/div/div[2]/div/div/div/div/div/div/div/div[3]/button[1]')
btn2$clickElement() #btn2가 에러가발생할 경우 btn3실행하기


#검색창 
searchword<-'여행'
remDr$navigate(paste0('https://www.instagram.com/explore/tags/',searchword))
Sys.sleep(2)

#href="/explore/tags


#중복 해시태그 제거 변수 생성
res<-remDr$getPageSource() %>% `[[`(1)
url<-res %>% read_html() %>% 
  html_nodes('a') %>% 
  html_text() 
url<-url[str_detect(url,'#')]
removenum<-length(url)

url

bu1<-remDr$findElement(using='xpath',value='/html/body/div[1]/div/div[1]/div/div[1]/div/div/div[1]/div[1]/section/main/article/div[1]/div/div/div[1]/div[1]/a/div/div[2]')
bu1$clickElement()


#다음페이지 넘기기
bu2<-remDr$findElement(using='xpath',value='/html/body/div[1]/div/div[1]/div/div[2]/div/div/div[1]/div/div[3]/div/div/div/div/div[1]/div/div/div/button')
bu2$clickElement()

rslt<-c()


for (i in 1:10){
  for (i in 1:10){
    tryCatch(
      {
        remDr$getPageSource()
        bu<-remDr$findElement(using='xpath',value=paste0('/html/body/div[1]/div/div[1]/div/div[2]/div/div/div[1]/div/div[3]/div/div/div/div/div[2]/div/article/div/div[2]/div/div/div[2]/div[1]/ul/ul[',i,']/li/ul/li/div/button/span'))
        Sys.sleep(1)
        bu$clickElement()
      },
      error=function(NoSuchElement){
        print('대댓글이 없을경우 발생하는 오류이니 진행하시면 됩니다')
      }
    )
  }
  
  res<-remDr$getPageSource() %>% `[[`(1)
  Sys.sleep(2)

  url<-res %>% read_html() %>% 
    html_nodes('a') %>% 
    html_text()
  url<-url[str_detect(url,'#')]
  
  t1<-list(url[-c(1:removenum)])
  rslt<-append(rslt,t1)
  Sys.sleep(2)
  bu2$clickElement()
  Sys.sleep(2)
}
rslt
#데이터 수집시 오래된게시글일수록 댓글갯수가 많아짐

library(stringr)
result<-list()
for (i in 1:length(rslt)){
  if (length(rslt[[i]])==0){
    result[[i]]<-0
  } else {
    result[i]<-list(str_replace(rslt[[i]],'#',''))
  }
}

result

#전처리하기
#특수문자 및 이모티콘 제거
rs_1<-list()
for (i in 1: length(result)){
  rs_1[i]<-list(str_replace_all(result[[i]],"[^가-힣]",""))
}

#공백 제거
rs_2<-list()
for (i in 1:length(rs_1)){
  rs_2[[i]]<-rs_1[[i]][rs_1[[i]]!=""]
}
rs_2

#특정 중복 키워드 ifelse문 정리

rs_3<-list()
for (i in 1:length(rs_2)){
  rs_3[[i]]<-ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'맞팔선팔환영'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'선팔'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'팔'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'좋아요'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'좋반'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'게하'))],'게스트하우스',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'강원도여행지추천'))],'강원도',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'강원도관광지'))],'강원도',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'강원도워크숍'))],'강원도',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'거제가볼만한곳'))],'거제도',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'거제관광지'))],'거제도',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'거제도갈만한곳'))],'거제도',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'거제도여행'))],'거제도',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'거제여행'))],'거제도',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'거제여행지추천'))],'거제도',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'거제카페'))],'거제도카페',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'게스트하우스추천'))],'게스트하우스',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'국내여행지'))],'국내여행',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'국내박일여행'))],'국내여행',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'남자게스트'))],'남자게스트하우스',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'년생'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'뉴욕스냅사진'))],'뉴욕',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'뉴욕여행스냅'))],'뉴욕',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'닌빈투어'))],'닌빈',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'당일치기여행지추천'))],'당일치기여행지',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'대구가볼만한곳'))],'대구',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'대구관광지'))],'대구',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'소통'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'인친'))],'',rs_2[[i]])))))))))))))))))))))))))))))
}

#ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],''))],'',
rs_3

rs_3a<-list()
for(i in 1:length(rs_3)){
  rs_3a[[i]]<-rs_3[[i]][rs_3[[i]]!=""]
}



#unique통해 중복 합치기
rs_4<-unique(rs_3a)


#Combn() 위해 n<m보다 작은 리스트 제거
#리스트의 원소의 개수가 2개이하인 리스트 확인
#조건에 만족하는 리스트 삭제

for (i in 1: length(rs_4)){
  if(length(rs_4[[i]])<3){
    rs_4[[i]]=NULL
  }else{
    rs_4[[i]]=rs_4[[i]]
  }
}

rs_4

#게시글 마다 리스트 풀고 combn으로 조합
#Graph로 리스트별 연결된 링크수 가중치
#Source Target Weight 변수명 생성
#for문으로 게시글 모두 반복하여 rbind
#Source Target 중복된 데이터 가중치 합산

rs_test<-data.frame()

for (i in 1: length(rs_4)){
  tmp<-as.data.frame(unlist(rs_4[i]),stringAsFactors=F)
  colnames(tmp)<-"Source"
  tmp<-t(combn(tmp$Source,2))
  colnames(tmp)<-c("Source","Target")
  df_tmp<-as.data.frame(tmp)
  
  library(igraph)
  net_graph<-graph.data.frame(df_tmp,directed=FALSE)
  
  #가중치 측정
  weight_1<-centr_degree(net_graph,mode='all')
  weight_2<-rep(weight_1$res[1],length(tmp)/2)
  
  weight<-as.matrix(weight_2)
  colnames(weight)<-'Weight'
  
  final<-as.data.frame(cbind(df_tmp,weight))
  rs_test<-rbind(rs_test,final)
}

#데이터 확인하기
print(rs_test)

g<-graph.data.frame(rs_test,directed = F)
plot.igraph(g1)
g1<-delete.edges(g2,E(g2)[weight<0.6])
plot(g2,edge.arrow.size=0.5,vertex.label=NA,vertex.size=3)
plot(g1,layout=layout.auto,edge.arrow.size=0.5,vertex.size=3)

head(sort(degree(g2),decreasing = TRUE))
sort(closeness(g1,mode='all'),decreasing = TRUE)
sort(betweenness(g1),decreasing = TRUE)
eigen_centrality(g1)
a1<-sort(eigen_centrality(g1)$vector,decreasing=TRUE)
head(a1)

Isolated=which(degree(g1)==0)
g2<-delete.vertices(g1,Isolated)
plot.igraph(g2)



