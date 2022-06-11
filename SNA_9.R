getwd()
setwd('C:/Users/User/Documents/WS') #Áý ÄÄÇ»ÅÍ¿ë µð·ºÅÍ¸®
#setwd('C:/Users/student/Documents/R_WS')#ÇÐ±³ °­ÀÇ½Ç¿ë µð·ºÅÍ¸®

library(RSelenium)
library(wdman)
library(dplyr)
library(httr)
library(rvest)
library(stringr)
library(igraph)

remDr<-remoteDriver(remoteServerAddr='localhost',
                    port=4445L,
                    browserName='chrome')
remDr$open()
remDr$navigate('https://www.instagram.com/')

#¾ÆÀÌµð ºñ¹ø
id<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[1]/div/label/input')
pw<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[2]/div/label/input')

#·Î±×ÀÎ ¹öÆ°
login_btn<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[3]/button/div')

id$sendKeysToElement(list("testaccount00118"))
pw$sendKeysToElement(list("1q2w3e4r1!"))
login_btn$clickElement()

#·Î±×ÀÎ½Ã ³ª¿À´Â ¾Ë¸²¼³Á¤
btn1<-remDr$findElement(using='xpath',value='/html/body/div[1]/section/main/div/div/div/section/div/button')
btn1$clickElement()

remDr$refresh()

btn2<-remDr$findElement(using='xpath',value='/html/body/div[1]/div/div[1]/div/div[2]/div/div/div[1]/div/div[2]/div/div/div/div/div/div/div/div[3]/button[1]')
btn2$clickElement() #btn2°¡ ¿¡·¯°¡¹ß»ýÇÒ °æ¿ì btn3½ÇÇàÇÏ±â


#°Ë»öÃ¢ 
searchword<-'È¥ÀÚ¿©Çà'
remDr$navigate(paste0('https://www.instagram.com/explore/tags/',searchword))
Sys.sleep(2)

#href="/explore/tags


#Áßº¹ ÇØ½ÃÅÂ±× Á¦°Å º¯¼ö »ý¼º
res<-remDr$getPageSource() %>% `[[`(1)
url<-res %>% read_html() %>% 
  html_nodes('a') %>% 
  html_text() 
url<-url[str_detect(url,'#')]
removenum<-length(url)

url

bu1<-remDr$findElement(using='xpath',value='/html/body/div[1]/div/div[1]/div/div[1]/div/div/div[1]/div[1]/section/main/article/div[1]/div/div/div[1]/div[1]/a/div/div[2]')
bu1$clickElement()


#´ÙÀ½ÆäÀÌÁö ³Ñ±â±â
bu2<-remDr$findElement(using='xpath',value='/html/body/div[1]/div/div[1]/div/div[2]/div/div/div[1]/div/div[3]/div/div/div/div/div[1]/div/div/div/button')
bu2$clickElement()

rslt<-c()


for (i in 1:100){
  for (i in 1:10){
    tryCatch(
      {
        remDr$getPageSource()
        bu<-remDr$findElement(using='xpath',value=paste0('/html/body/div[1]/div/div[1]/div/div[2]/div/div/div[1]/div/div[3]/div/div/div/div/div[2]/div/article/div/div[2]/div/div/div[2]/div[1]/ul/ul[',i,']/li/ul/li/div/button/span'))
        Sys.sleep(1)
        bu$clickElement()
      },
      error=function(NoSuchElement){
        print('´ë´ñ±ÛÀÌ ¾øÀ»°æ¿ì ¹ß»ýÇÏ´Â ¿À·ùÀÌ´Ï ÁøÇàÇÏ½Ã¸é µË´Ï´Ù')
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
#µ¥ÀÌÅÍ ¼öÁý½Ã ¿À·¡µÈ°Ô½Ã±ÛÀÏ¼ö·Ï ´ñ±Û°¹¼ö°¡ ¸¹¾ÆÁü

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
#Æ¯¼ö¹®ÀÚ ¹× ÀÌ¸ðÆ¼ÄÜ Á¦°Å
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

#ºÒÇÊ¿äÇÑ ´Ü¾î Á¦°Å°úÁ¤
rs_3<-list()
for (i in 1:length(rs_2)){
  rs_3[[i]]<-ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼ÓÃÊ¿©Çà'))],'¼ÓÃÊ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'º¸¼º³ìÂ÷¹ç'))],'º¸¼º',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°­¸ª¿©Çà'))],'°­¸ª',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ¿©ÇàÇÏ±â'))],'È¥ÀÚ¿©Çà',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»çÁøÀÌ»Ú°Ô³ª¿À´Â°÷'))],'»çÁø¸ÀÁý',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'½°'))],'ÈÞ½Ä',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'º£Æ®³²¿©Çà'))],'º£Æ®³²',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ¿©ÇàÇÏ´Â¿©ÀÚ'))],'¿©ÀÚÈ¥ÀÚ¿©Çà',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¦ÁÖ'))],'Á¦ÁÖµµ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¹è³¶¿©Çà²ÜÆÁ'))],'¹è³¶¿©Çà',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÅÍÅ°¿©Çà'))],'ÅÍÅ°',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'½ºÄíÅÍ¿©Çà'))],'¶óÀÌ´õ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÀÚÇØ¿Ü¿©Çà²ÜÆÁ'))],'¿©ÀÚÈ¥ÀÚ¿©Çà',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»êÆ¼¾Æ°í¼ø·Ê±æ'))],'»êÆ¼¾Æ°í',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'½¬´Â³¯'))],'ÁÖ¸»',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³â¹Ý¸¸¿¡'))],'°­¸ª',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀüÁÖ°¡º¼¸¸ÇÑ°÷'))],'ÀüÁÖ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀüºÏ¿©Çà'))],'ÀüºÏ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°¨¼ºÄ·ÇÎ'))],'Ä·ÇÎ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¦ÁÖ¿©Çà'))],'Á¦ÁÖµµ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á©³×ÀÏ'))],'³×ÀÏ¾ÆÆ®',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÏº»¾îÈ¸È­°øºÎ'))],'ÀÏº»',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©¼ö¿©Çà'))],'¿©¼ö',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ß½ÃÄÚ¿©Çà'))],'¸ß½ÃÄÚ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´ñ±ÛÈ¯¿µ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´ñ±Û¼ÒÅë'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÂÆÈ´ñ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÂÆÈ´ñ±Û'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÂÆÈÀº´ñ±Û'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÂÆÈÇØ¿ä¿ì¸®'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÂÆÈÈ¯¿µ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÂÆÈÀº´ñ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼±ÆÈÇÏ¸é¸ÂÆÈ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼±ÆÈ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÎÄ£ÇØ¿ä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÎÄ£µé'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÎÄ£È¯¿µ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÁÁ¾Æ¿äÆøÅº'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÁÁ¹Ý´ñ±Û'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÁÁÅ×¹Ý»ç'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÁÁ¹Ý´ñ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÁÁ¾Æ¿ä¹Ý»ç'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÁÁ¾Æ¿äÅ×·¯'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÁÁ¹Ý'))],'',
                    rs_2[[i]]))))))))))))))))))))))))))))))))))))))))))))}
  
for (i in 1:length(rs_2)){
  rs_3[[i]]<-ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±èµà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ¸¸ÀÇ'))],'È¥ÀÚ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³â»ý'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°¨¼º½ºÅ¸±×·¥'))],'°¨¼º',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ¼­'))],'È¥ÀÚ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿ù¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°¨¼º½Ã°£'))],'°¨¼º',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³â¸¸¿¡'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´ñ±Û'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´ñ±Û¹Ý»ç'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÎÄ£'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÀÆÈ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÂÆÈ±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÂÆÈÁÁ¾Æ¿ä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼ÒÅë'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÁÁÅ×'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÁÁ¾Æ¿ä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÁÁ¾Æ¿äÈ¯¿µ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÁÁÆ¢'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ä£±¸ÇØ¿ä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ã¹ÁÙ¹Ý»ç'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÈ·Î'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÈ·Î¹Ì'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÈ·Î¿ì¹é'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÈ·Î¿ìÇØ¿ä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÈ·Î¿ì¹Ì'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÈ·Î¿ì¹Ý»ç'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÈ·Î¿ö´Ã¸®±â'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÈ·Î¿ì'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÈ·Î¿ìÈ¯¿µ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÈ·Î¿öÇØ¿ä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÈ·ÎÀ×'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÈ·Î¿ì´Ã¸®±â'))],'',
                    rs_2[[i]]))))))))))))))))))))))))))))))))))}
           
for (i in 1:length(rs_2)){
  rs_3[[i]]<- ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÈ·Î¿ì±×·¥'))],'',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»çÁø°èÁ¤¸ÂÆÈ'))],'',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼¿ÇÇ'))],'¼¿Ä«',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼¿½ºÅ¸±×·¥'))],'¼¿Ä«',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»çÁø½ºÅ¸±×·¥'))],'»çÁø',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà»çÁø'))],'»çÁø',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»çÁø¿¡°üÇÏ¿©'))],'»çÁø',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà½ºÅ¸±×·¥ÃßÃµ'))],'¿©ÇàÁöÃßÃµ',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´ë¾ÆÁÜ¸¶'))],'¾ÆÁÜ¸¶',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸Ô¹æ'))],'¸À½ºÅ¸±×·¥', 
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'µß±¼µß±¼'))],'',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼¿Ä«±×·¥'))],'¼¿Ä«',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼¿Ä«½ºÅ¸±×·¥'))],'¼¿Ä«',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'²ó'))],'',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»çÁø°èÁ¤'))],'»çÁø',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà½ºÅ¸±×·¥ÁöÃßÃµ'))],'¿©ÇàÁöÃßÃµ',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà¿¡¹ÌÄ¡´Ù'))],'¿©Çà',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà½ºÅ¸±×·¥'))],'¿©Çà',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'µå¶óÀÌºê¿©Çà'))],'µå¶óÀÌºê',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´çÀÏÄ¡±â¿©Çà'))],'´çÀÏÄ¡±â',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Çªµå½ºÅ¸±×·¥'))],'¸Ô¹æ',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸À½ºÅ¸±×·¥'))],'¸Ô¹æ',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà±×·¥'))],'¿©Çà',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà½ºÅ¸'))],'¿©Çà',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÇàÁ¤º¸'))],'¿©Çà',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÀÚÈ¥ÀÚÇØ¿Ü'))],'¿©ÀÚÇØ¿Ü¿©Çà',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇØ¿Ü¿©ÇàÃßÃµ'))],'ÇØ¿Ü¿©Çà',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÇàÀ»ÀÏ»óÃ³·³'))],'¿©Çà',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°¨¼º¿©Çà'))],'°¨¼º',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÇàÁß'))],'¿©Çà',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³ªÀÇ¹Ù´Ù'))],'¹Ù´Ù',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±Ù°í±â'))],'',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÏ»ó½ºÅ¸±×·¥'))],'ÀÏ»ó',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà¿¡¹ÌÄ¡´Ù¸ß½ÃÄÚ'))],'¸ß½ÃÄÚ½ÃÆ¼',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¾Æ¾¾'))],'',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'½ÃºÎ··'))],'',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Áö¶ö'))],'',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¹è½ÅÀÚ'))],'',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Àç¼ö¶Ë'))],'',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´«À¸·ÎÂï¾î¸¶À½¿¡´ã¾Æº»´Ù'))],'»çÁø',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼­´ç°³»ï³âÀÌ¸éÇ³¿ùÀ»À¼´Â´Ù´õ´Ï'))],'',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»çÁøÂï´Â¼Ø¾¾°¡´Ã¾ú¾î'))],'»çÁø',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¦¿©°´ÅÍ¹Ì³Î'))],'¿©°´ÅÍ¹Ì³Î',
              ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±¹³»'))],'±¹³»¿©Çà',
                     rs_2[[i]]))))))))))))))))))))))))))))))))))))))))))))}
                       
for (i in 1:length(rs_2)){
  rs_3[[i]]<-ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼Ò¶ó¾ð´Ï'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»çÁø¿¡¹ÌÄ¡´Ù'))],'»çÁø',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³ª¸¸¿¡¿©Çà'))],'È¥ÀÚ¿©Çà',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿ùÀÇÅ©¸®½º¸¶½º'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°ÅÁ¦µµ¿©Çà'))],'°ÅÁ¦µµ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ã¢¹Û'))],'ºä',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¾ÆÀÌ½½¶õµå¿©Çà'))],'¾ÆÀÌ½½¶õµå',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³ª´ÂÀÚÀ¯ÀÎÀÌ´Ù'))],'ÀÚÀ¯',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÚÀ¯¿©Çà'))],'ÀÚÀ¯',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ãß¾ïÆÈÀÌ'))],'Ãß¾ï', 
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¹üºíºñ¾ß´©³ª°¡¿Ô´Ù°£´Ù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¾ö¸¶¾ÈÃ£°íÀßÁö³»´Â¿ï¾Ö±âµéÃÖ°í'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼º°Ýµµ½À°üÀÌ´Ù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Èú¸µÀÌÇÊ¿äÇØ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ãµ±¹'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±Ø¶ô'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇÑ±¹È­°¡½ÅÀº¹Ì'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇØ¸¼À½'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»ç»Ó»ç»Ó'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¶½ÅÇÑÃ´'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÌ¹Ì·¡'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÄÉÀÌÀÛ°¡'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±Ã±×¹Ì'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³ª¸¦À§ÇÑ¼±¹°'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'º°°Å¾ø´Ù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»ï°¢´ë´Â³»Ä£±¸'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ä£±¸¾ø´Â°ÅÆ¼³»±â'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¶Ç¸¤'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³­±¦Âú¾Æ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¾ÆÄ§¿£'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¾Õ¸Ó¸®°¡ÀÖ¾ú´Âµ¥¾ø¾ú¾î¿ä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÎ»ýÈ¥ÀÚ»ç´Â°Å¾ß'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±¸µ¶°úÁÁ¾Æ¿ä´Â»ç¶ûÀÔ´Ï´Ù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼ÕÇÏÆ®'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³Ê¹«¿¹»µ¼­±âÀý'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ãâ»ç¸ðµ¨'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»óÈ£¹«ÆäÀÌ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´Ü¾ÆÇÔ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³»µ·³»»ê'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'½Å¶óÈ£ÅÚ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'½Å¶ó½ºÅ×ÀÌÁ¦ÁÖ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'½Å¶ó½ºÅ×ÀÌ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¦ÁÖÈ£ÅÚ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¦ÁÖ¹è´ÞÀ½½Ä'))],'',
                    rs_2[[i]]))))))))))))))))))))))))))))))))))))))))))))}
                                  
for (i in 1:length(rs_2)){
  rs_3[[i]]<-ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¦ÁÖ°øÇ×È£ÅÚ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¹è´ÞÀÇ¹ÎÁ·'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¦ÁÖÆÒ´õÀÇµ¤¹ä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÒ´õÀÇµ¤¹ä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'µ¤¹ä½ºÅ¸±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´ë°ÔµüÁöÀå'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´ë°ÔµüÁöÀåµ¤¹ä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´ß¹ß'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´ß¹ß¸ÀÁý'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ºôµù¾ÆÄí¾Æ¸®¿ò'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°ÅºÏÀÌ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°ÅºÏÀÌ°È´Ù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÃµÃµÈ÷'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°ÅºÏÀÌ½Ä»çÁß'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¹Ù´Ù»çÀÚ¿ïÀ½¼Ò¸®'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¥´Þ¶ó°í¶§¾²´ÂÁß'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆòÇÏ·Î¿ò'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°¥¶óÆÄ°í½º'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¹Ù´Ù»çÀÚ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'½æ¸Ó'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³Ê¹«¿¹»µ³Ê¹«ÁÁ¾Æ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇÑº¹ÀÌÀß¾î¿ï¸®´Â¿©ÀÚ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ä«Æä¶ÑÀÌ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼­±ÍÆ÷¿©Çà»ç'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³»ÀÏ·Î'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³»ÀÏ·Î°èÈ¹'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³»ÀÏ·ÎÀÏ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇÁ¸®·£¼­'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇÁ¸®·£¼­ÀÇ»î'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇÁ¸®·£¼­ÀÛ¾÷½Ç'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³ë¸ÅµåÇæ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'²É¹ÝÁö'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÅÇØ¸¶´Ù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Åä¿äÀÏ¿ÀÀü'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»ì'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¶¿ëÇÑÇØº¯'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀüÁÖÇÖÀV'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±×»ç¶÷ÀÇ¸¶À½Àº±×»ç¶÷ÀÇÇàµ¿'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼­Àº¿ùµåÅÛÇÃ½ºÅ×ÀÌ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÅÛÇÃ½ºÅ×ÀÌÃ¼Çè'))],'ÅÛÇÃ½ºÅ×ÀÌ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼Ò¸®¼Òºô¸®Áö'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Æú·¯¸®'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±Í³ó±ÍÃÌ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ã»ÃáÇÊ¶óÅ×½º'))],'ÇÊ¶óÅ×½º',
                    rs_2[[i]]))))))))))))))))))))))))))))))))))))))))))))}
           
for (i in 1:length(rs_2)){
  rs_3[[i]]<-ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»õº®¼ö¿µ'))],'¼ö¿µ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È£Ä²½ºÃßÃµ'))],'È£Ä²½º',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°ûÁö¸ÀÁý'))],'°ûÁö',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¦ÁÖÈæµÅÁö¸ÀÁý'))],'Á¦ÁÖÈæµÅÁö',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÇÁ¤ºÎ¸ÀÁý'))],'ÀÇÁ¤ºÎ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÃáÃµ¸ÀÁý'))],'ÃáÃµ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼ÓÃÊ¸ÀÁý'))],'¼ÓÃÊ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÇàÁöÃßÃµ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Â÷¹Ú¸í¼Ò'))],'Â÷¹Ú',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³ëÁöÄ·ÇÎ¸í¼Ò'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ä·ÇÎÀåÃßÃµ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±Û·¥ÇÎÀåÃßÃµ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¹Ù´Ùº¸ÀÌ´ÂÄ·ÇÎÀå'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿À¼ÇºäÄ·ÇÎÀå'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'º°º¸±âÁÁÀº°÷'))],'º°',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ä·ÇÎ¸ÀÆÈ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà¿¡¹ÌÄ¡´Ù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ä·ÇÎ½ºÅ¸±×·¥'))],'Ä·ÇÎ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'µî»ê½ºÅ¸±×·¥'))],'µî»ê',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»ê½ºÅ¸±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Â÷½ºÅ¸±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ä«½ºÅ¸±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¾ÆÀÌ¿À´Ð'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Àü±âÂ÷'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇÇ¾ÆÆ®'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇÇ¾ÆÆ®Â÷¹Ú'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿ÀÅä¹ÙÀÌÅõ¾î'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¹ÙÀÌÅ©µ¿È£È¸'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¹ÙÀÌÅ©¸Å´Ï¾Æ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¦ÁÖ¹ö½º¿©Çà'))],'Á¦ÁÖµµ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¦ÁÖ¹ö½ºÅõ¾î'))],'Á¦ÁÖµµ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¾ÆÀÌ¿À´ÐÂ÷¹Ú'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¾Æ¹æ°¡¸£µåÄ«Æä'))],'Ä«Æä',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ºÎ»ê¿©Çà'))],'ºÎ»ê',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ºÎ»êµ¥ÀÌÆ®'))],'ºÎ»ê',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'½Ì°¡Æú¿©Çà'))],'½Ì°¡Æú',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'½Ì°¡ÆúÈ£ÅÚ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'½Ì°¡Æú¾ß°æ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'½Ì°¡Æú¶óÀÌÇÁ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'½Ì°¡ÆúÀÏ»ó'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±Í³ó±ÍÃÌ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³²¾çÁÖÄ«Æä'))],'³²¾çÁÖ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³²¾çÁÖÄ«ÆäÃßÃµ'))],'³²¾çÁÖ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'µå¶óÀÌºêÄ«Æä'))],'',
                    rs_2[[i]]))))))))))))))))))))))))))))))))))))))))))))}

for (i in 1:length(rs_2)){
  rs_3[[i]]<-ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³²¾çÁÖ°¡º¼¸¸ÇÑ°÷'))],'³²¾çÁÖ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³²¾çÁÖ¸ÀÁý'))],'³²¾çÁÖ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´º¿å¿©Çà'))],'´º¿å',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´º¿åÈ¥ÀÚ¿©Çà'))],'´º¿å',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´º¿å»ìÀÌ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¦ÁÖµµ¿©Çà'))],'Á¦ÁÖµµ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°¡Æò¿©Çà'))],'°¡Æò',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸¶Ä«¿À¿©Çà'))],'¸¶Ä«¿À',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¦ÁÖµµ¹Î'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'½½±â·Î¿îÁ¦ÁÖ»ýÈ°'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Æ÷Ç×¿©Çà'))],'Æ÷Ç×',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Æ÷Ç×°ü±¤Áö'))],'Æ÷Ç×',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È«Äá¿©Çà'))],'È«Äá',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀüÁÖ¿©Çà'))],'ÀüÁÖ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°ÅÁ¦¿©Çà'))],'°ÅÁ¦µµ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°ÅÁ¦µµ¿©Çà'))],'°ÅÁ¦µµ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°­¿øµµ¿©Çà'))],'°­¿øµµ',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Æ÷Ç×¿©ÇàÄÚ½º'))],'Æ÷Ç×',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´Ü¾ç¿©Çà'))],'´Ü¾ç',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÏ»ó'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÏ»ó±â·Ï'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÏ»ó±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÏ»ó¼ÒÅë'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'µ¥ÀÏ¸®½ºÅ¸±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼¿ÇÇ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼¿½ºÅ¸±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Çàº¹½ºÅ¸±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼ÒÅë'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼ÒÅëÈ¯¿µ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´ñ±Û'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÅÀÏ¾÷·Îµå'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÎÄ£È¯¿µ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼±ÆÈ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼±¸ÂÆÈ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼±ÆÈÀº¸ÂÆÈ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼±ÆÈ¸ÂÆÈ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÂÆÈ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÂÆÈÇØ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÂÆÈÇØ¿ä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÂÆÈÇØ¿ë'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÂÆÈÇØ¿ä¿ì¸®'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÂÆÈÈ¯¿µ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÎÄ£'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á÷ÀåÀÎ½ºÅ¸±×·¥'))],'',
                    rs_2[[i]]))))))))))))))))))))))))))))))))))))))))))))}

for (i in 1:length(rs_2)){
  rs_3[[i]]<-ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÀÁý'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÀÁýÆò°¡'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÀÁý½ºÅ¸±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸Ô½ºÅ¸±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÀÀÕ´Ù±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÁÁ¾Æ¿ä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÁÁ¹Ý'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÁÁ¹ÝÅ×·¯'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÀÁý'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ä«ÆäÃßÃµ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'µ¥ÀÌÆ®Ä«ÆäÃßÃµ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´Ê°Ô±îÁöÇÏ´ÂÄ«Æä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ä«ÆäÅõ¾î'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ä«Æä¸ÀÁý'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ä«ÆäÇÖÇÃ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´Ê°Ô±îÁö'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±Û¾²±âÁÁÀºÄ«Æä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±Û¾²±â'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥Ä²½º'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ°¡±âÁÁÀºÄ«Æä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ°¡±âÁÁÀº°÷'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ³î±â'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ°¡ÆíÇØ¼­'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ³î±â¸¸·¾'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ°¡±â'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÚÀ¯¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÀÚÈ¥ÀÚ'))],'¿©ÀÚÈ¥ÀÚ¿©Çà',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ¿©ÇàÇÏ´Â¿©ÀÚ'))],'¿©ÀÚÈ¥ÀÚ¿©Çà',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÀÚÈ¥ÀÚÇØ¿Ü¿©Çà'))],'¿©ÀÚÈ¥ÀÚ¿©Çà',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¶Ñ¹÷ÀÌ¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Èú¸µ¿©ÇàÁö'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇÑ±¹'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°Å¸®°È±â'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°È±â¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°ÔÇÏÆÄÆ¼'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°Ô½ºÆ®ÇÏ¿ì½ºÆÄÆ¼'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'°Ô½ºÆ®ÇÏ¿ì½º'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÆÄÆ¼°Ô½ºÆ®ÇÏ¿ì½º'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¾Ë¹Ù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÏ»ó'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼Ò¼ÒÇÑÀÏ»ó'))],'',
                    rs_2[[i]]))))))))))))))))))))))))))))))))))))))))))))}

for (i in 1:length(rs_2)){
  rs_3[[i]]<-ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È£ÅÚÀÏ»ó'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿¡¼¼ÀÌ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸¶À½'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸¸Á·'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´ÙÁü'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Çàµ¿'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´Þ¸®±â'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'·¯´×'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¸ÅÀÏ´Þ¸®±â'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'µ¶¼­'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¹é¼ö'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´ÙÀÌ¾îÆ®'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿îµ¿'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ã¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿µÈ­'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿ä¸®'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ã»¼Ò'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±Û¾²±â'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿¡¼¼ÀÌ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ãß¾ï'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥¼ú'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà°¡¼­´Ù¸¸³²'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Èú¸µ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Èú¸µ¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Èú¸µÀÌÇÊ¿äÇØ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È£ÅÚÃßÃµ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È£ÅÚÀÎÅ×¸®¾î'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÎÅ×¸®¾î'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´Ü¾ç°Ô½ºÆ®ÇÏ¿ì½ºÆÄÆ¼'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´Ü¾ç°ÔÇÏ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´Ü¾ç°¡º¼¸¸ÇÑ°÷'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´Ü¾çÆÐ·¯±Û¶óÀÌµù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´Ü¾çÄ«Æä'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Çàº¹'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿òÁ÷ÀÌ±â'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿þµù½º³À'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼Ö·Î½º³À'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Ä¿ÇÃ½º³À'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Çã´Ï¹®½º³À'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´Ï½ºÅ¸ÀÏ½º³À'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇÑº¹½º³À'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇÑº¹´ë¿©¿¹»Û°÷'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇÑº¹³²'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇÑº¹ÀÌÀß¾î¿ï¸®´Â¿©ÀÚ'))],'',
                    rs_2[[i]]))))))))))))))))))))))))))))))))))))))))))))}

for (i in 1:length(rs_2)){
  rs_3[[i]]<-ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´º¿å½º³À'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´º¿å½º³À»çÁø'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´º¿å½º³ÀÃÔ¿µ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´º¿åÄ¿ÇÃ½º³À'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´º¿åÈ­º¸'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´º¿å¿©Çà½º³À'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¹ö½ºÅõ¾î'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÇàÁß'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÇàÀÏ»ó'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà±â·Ï'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÇàÀ»´ã´Ù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà¿¡¹ÌÄ¡´Ù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Á¦ÁÖ¿¡¹ÌÄ¡´Ù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà¿¡¹ÌÄ¡´Ù¸¶Ä«¿À'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà¿¡¹ÌÄ¡´Ù°ÅÁ¦'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà½ºÅ¸±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà¼ÒÅë'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÇàÃßÃµ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÇàÀ»ÀÏ»óÃ³·³'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÇàÀº¾ðÁ¦³ª¿Ç´Ù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà±â·Ï¿©ÇàÀ»´ã´Ù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©Çà¾ÎÀÌ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³¯¾¾°¡´ÙÇß´Ù'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÎ»ý¼¦¿¬±¸¼Ò'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Àü½Å¼¦'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»©²Ä¼¦'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼¿Ä«'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'»ï°¢´ë¼¦'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼¿½ºÅ¸±×·¥'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'´ëÇÑ¹Î±¹±¸¼®±¸¼®'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÀÚÈ¥ÀÚ±¹³»¿©Çà'))],'¿©ÀÚÈ¥ÀÚ¿©Çà',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ¿©ÇàÇÏ´Â¿©ÀÚ'))],'¿©ÀÚÈ¥ÀÚ¿©Çà',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¿©ÀÚÈ¥ÀÚ¹è³¶¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥¿©'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³ªÈ¦·Î¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'³ªÈ¥ÀÚ¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'¼¿Ä«³îÀÌ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¥ÀÚ¿©ÇàÇÏ±âÁÁÀº°÷'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'È¦·Î¿©Çà'))],'',
                    rs_2[[i]]))))))))))))))))))))))))))))))))))))))))))))}

for (i in 1:length(rs_2)){
  rs_3[[i]]<-ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇÖÇÃÅõ¾î'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ºÎ»êÇÖÇÃ'))],'ºÎ»ê',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇÑ±¹'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±¹³»¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±¹³»¿©ÇàÃßÃµ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'±¹³»¿©ÇàÁöÃßÃµ'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÇØ¿Ü¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'ÀÚÀ¯¿©Çà'))],'',
             ifelse(rs_2[[i]]%in%rs_2[[i]][which(str_detect(rs_2[[i]],'Èú¸µ¿©Çà'))],'',
                    rs_2[[i]])))))))))}

rs_3

rs_3a<-list()
for(i in 1:length(rs_3)){
  rs_3a[[i]]<-rs_3[[i]][rs_3[[i]]!=""]
}


#uniqueÅëÇØ Áßº¹ ÇÕÄ¡±â
rs_4<-unique(rs_3a)


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

rs_4

#°Ô½Ã±Û ¸¶´Ù ¸®½ºÆ® Ç®°í combnÀ¸·Î Á¶ÇÕ
#Graph·Î ¸®½ºÆ®º° ¿¬°áµÈ ¸µÅ©¼ö °¡ÁßÄ¡
#Source Target Weight º¯¼ö¸í »ý¼º
#for¹®À¸·Î °Ô½Ã±Û ¸ðµÎ ¹Ýº¹ÇÏ¿© rbind
#Source Target Áßº¹µÈ µ¥ÀÌÅÍ °¡ÁßÄ¡ ÇÕ»ê

for (i in 1: length(rs_4)){
  tmp<-as.data.frame(unlist(rs_4[i]),stringAsFactors=F)
  colnames(tmp)<-"Source"
  tmp<-t(combn(tmp$Source,2))
  colnames(tmp)<-c("Source","Target")
  df_tmp<-as.data.frame(tmp)
  
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

g<-graph.data.frame(rs_test,directed = TRUE)
plot.igraph(g)
plot(g,edge.arrow.size=0.5,vertex.label=NA,vertex.size=3)
plot(g,layout=layout.auto,edge.arrow.size=0.5,vertex.size=3,vertex.label=NA)
head(sort(degree(g),decreasing = TRUE))
Isolated<-which(degree(g)==0)

g1<-delete.vertices(g,Isolated)
plot(g1,layout=layout.auto,edge.arrow.size=0.5,vertex.size=3,vertex.label=NA)
g1<-delete.edges(g1,E(g)[abs(weight)<0.6])
components(g)
length(E(g))
dyad_census(g)
transitivity(g)
edge_density(g)
centr_degree(g,mode = 'all')

abs(rs_test$Weight)

#
#È÷½ºÅä±×·¥,¿öµåÅ¬¶ó¿ìµå ±×¸®±â

head(sort(degree(g1),decreasing = TRUE))
sort(closeness(g1,mode='all'),decreasing = TRUE)
sort(betweenness(g1),decreasing = TRUE)
eigen_centrality(g1)
a1<-sort(eigen_centrality(g1)$vector,decreasing=TRUE)
head(a1)



head(sort())


           
  
                                                                                                                                                