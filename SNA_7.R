getwd()
setwd('C:/Users/User/Documents/WS') #Áı ÄÄÇ»ÅÍ¿ë µğ·ºÅÍ¸®
#setwd('C:/Users/student/Documents/R_WS')#ÇĞ±³ °­ÀÇ½Ç¿ë µğ·ºÅÍ¸®

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

#¾ÆÀÌµğ ºñ¹ø
id<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[1]/div/label/input')
pw<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[2]/div/label/input')

#·Î±×ÀÎ ¹öÆ°
login_btn<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[3]/button/div')

id$sendKeysToElement(list("testaccount00118"))
pw$sendKeysToElement(list("1q2w3e4r1!"))
login_btn$clickElement()

#·Î±×ÀÎ½Ã ³ª¿À´Â ¾Ë¸²¼³Á¤
btn1<-remDr$findElement(using='xpath',value='//*[@id="react-root"]/section/main/div/div/div/section/div/button')
btn1$clickElement()

btn2<-remDr$findElement(using='css',value='body > div.RnEpo.Yx5HN > div > div > div > div.mt3GC > button.aOOlW.bIiDR')
btn2$clickElement() #btn2°¡ ¿¡·¯°¡¹ß»ıÇÒ °æ¿ì btn3½ÇÇàÇÏ±â


#°Ë»öÃ¢ 
searchword<-'±¹³»¿©Çà'
remDr$navigate(paste0('https://www.instagram.com/explore/tags/',searchword))
Sys.sleep(2)

#Áßº¹ ÇØ½ÃÅÂ±× Á¦°Å º¯¼ö »ı¼º
res<-remDr$getPageSource() %>% `[[`(1)
url<-res %>% read_html() %>% 
  html_nodes(css='a.LFGsB.xil3i') %>% 
  html_text()
removenum<-length(url)

#ÃÖ±Ù °Ô½Ã±Û Å¬¸¯
bu1<-remDr$findElement(using='css',value='#react-root > section > main > article > div.EZdmt > div > div > div:nth-child(1) > div:nth-child(1) > a > div.eLAPa > div._9AhH0')
bu1$clickElement()


#´ÙÀ½ÆäÀÌÁö ³Ñ±â±â
bu2<-remDr$findElement(using='css',value='body > div.RnEpo._Yhr4 > div.Z2Inc._7c9RR > div > div > button > div > span > svg')
bu2$clickElement()

rslt<-c()

for (i in 1:100){
  for (i in 1:10){
    tryCatch(
      {
        remDr$getPageSource()
        bu3<-remDr$findElement(using='css',value=paste0('body > div.RnEpo._Yhr4 > div.pbNvD.QZZGH.bW6vo > div > article > div > div.HP0qD > div > div > div.eo2As > div.EtaWk > ul > ul:nth-child(',i,') > li > ul > li > div > button > span'))
        Sys.sleep(1)
        bu3$clickElement()
      },
      error=function(NoSuchElement){
        print('´ë´ñ±ÛÀÌ ¾øÀ»°æ¿ì ¹ß»ıÇÏ´Â ¿À·ùÀÌ´Ï ÁøÇàÇÏ½Ã¸é µË´Ï´Ù')
      }
    )
  }
  res<-remDr$getPageSource() %>% `[[`(1)

  url<-res %>% read_html() %>% 
    html_nodes(css='a.xil3i') %>% 
    html_text()
  
  t1<-list(url[-c(1:removenum)])
  rslt<-append(rslt,t1)
  bu2$clickElement()
}
rslt

#µ¥ÀÌÅÍ ¼öÁı½Ã ¿À·¡µÈ°Ô½Ã±ÛÀÏ¼ö·Ï ´ñ±Û°¹¼ö°¡ ¸¹¾ÆÁü

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

#ÀüÃ³¸®ÇÏ±â
#Æ¯¼ö¹®ÀÚ ¹× ÀÌ¸ğÆ¼ÄÜ Á¦°Å
rs_1<-list()
for (i in 1: length(result)){
  rs_1[i]<-list(str_replace_all(result[[i]],"[^°¡-ÆR]",""))
}

#°ø¹é Á¦°Å
rs_2<-list()
for (i in 1:length(rs_1)){
  rs_2[[i]]<-rs_1[[i]][rs_1[[i]]!=""]
}
rs_2

#Æ¯Á¤ Áßº¹ Å°¿öµå ifelse¹® Á¤¸®

rs_3<-list()
for (i in 1:length(rs_2)){
  rs_3[[i]]<-ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÈªÄ«ÀÌµµ¿©Çà'))],'ÈªÄ«ÀÌµµ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ¿©Çà'))],'È¥Çà',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥Çà½ºÅ¸±×·¥'))],'È¥Çà',rs_2[[i]])))
}

rs_3


#uniqueÅëÇØ Áßº¹ ÇÕÄ¡±â
rs_4<-unique(rs_3)


#Combn() À§ÇØ n<mº¸´Ù ÀÛÀº ¸®½ºÆ® Á¦°Å
#¸®½ºÆ®ÀÇ ¿ø¼ÒÀÇ °³¼ö°¡ 2°³ÀÌÇÏÀÎ ¸®½ºÆ® È®ÀÎ
#Á¶°Ç¿¡ ¸¸Á·ÇÏ´Â ¸®½ºÆ® »èÁ¦

for (i in 1: length(rs_4)){
  if(length(rs_4[[i]])<3){
    rs_4[[i]]=NULL
  }else{
    rs_4[[i]]=rs_4[[i]]
  }
}


#°Ô½Ã±Û ¸¶´Ù ¸®½ºÆ® Ç®°í combnÀ¸·Î Á¶ÇÕ
#Graph·Î ¸®½ºÆ®º° ¿¬°áµÈ ¸µÅ©¼ö °¡ÁßÄ¡
#Source Target Weight º¯¼ö¸í »ı¼º
#for¹®À¸·Î °Ô½Ã±Û ¸ğµÎ ¹İº¹ÇÏ¿© rbind
#Source Target Áßº¹µÈ µ¥ÀÌÅÍ °¡ÁßÄ¡ ÇÕ»ê

rs_test<-data.frame()

for (i in 1: length(rs_4)){
  tmp<-as.data.frame(unlist(rs_4[i]),stringAsFactors=F)
  colnames(tmp)<="Source"
  tmp<-t(combn(tmp$Source,2))
  colnames(tmp)<-c("Source","Target")
  df_tml<-as.data.frame(tmp)
  
  library(igraph)
  net_graph<-graph.data.frame(df_tmp,directed=FALSE)
  
  #°¡ÁßÄ¡ ÃøÁ¤
  weight_1<-centr_degree(net_graph,mode='all')
  weight_2<-rep(weight_1$res[1],length(tmp)/2)
  
  weight<-as.matrix(weight_2)
  colnames(weight)<-'Weight'
  
  final<-as.data.frame(cbind(df_tmp,weight))
  rs_test<-rbind(rs_test,final)
}

#µ¥ÀÌÅÍ È®ÀÎÇÏ±â
print(rs_test)











