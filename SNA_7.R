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
btn2<-remDr$findElement(using='xpath',value='/html/body/div[6]/div/div/div/div[3]/button[2]')
btn2$clickElement()

#°Ë»öÃ¢ 
searchword<-'µ¥ÀÏ¸®·è'
remDr$navigate(paste0('https://www.instagram.com/explore/tags/',searchword))
Sys.sleep(2)

#Áßº¹ ÇØ½ÃÅÂ±× Á¦°Å º¯¼ö »ı¼º
res<-remDr$getPageSource() %>% `[[`(1)
url<-res %>% read_html() %>% 
  html_nodes(css='a.LFGsB.xil3i') %>% 
  html_text()
removenum<-length(url)
Sys.sleep(2)

url
removenum

#ÃÖ±Ù °Ô½Ã±Û Å¬¸¯
bu1<-remDr$findElement(using='css',value='#react-root > section > main > article > div.EZdmt > div > div > div:nth-child(1) > div:nth-child(1) > a > div.eLAPa > div._9AhH0')
bu1$clickElement()


#´ÙÀ½ÆäÀÌÁö ³Ñ±â±â
bu2<-remDr$findElement(using='css',value='body > div.RnEpo._Yhr4 > div.Z2Inc._7c9RR > div > div > button > div > span > svg')
bu2$clickElement()

rslt<-c()

for (i in 1:10){
  for (i in 1:15){
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
result<-str_replace(rslt,'#','')
result
class(result)
result1<-as.data.frame(result)

#ÀüÃ³¸®ÇÏ±â
#Æ¯¼ö¹®ÀÚ ¹× ÀÌ¸ğÆ¼ÄÜ Á¦°Å
rs_1<-str_replace_all(result1$result,"[^°¡-ÆR]","") #ÇÑ±Û¸¸ ³²±â°í ³ª¸ÓÁö´Â °ø¹éÀ¸·Î ¸¸µé±â
rs_1a<-as.data.frame(rs_1)
rs_2<-rs_1a[!apply(is.na(rs_1a)|rs_1a=="",1,all),] #NA°ªÀÌ°Å³ª °ø¹éÀÏ°æ¿ì Á¦°Å (ÀÚ·áÇüÀÌ ¹®ÀÚÇüÀ¸·Î ¹Ù²ñ)
rs_2a<-as.data.frame(rs_2)
class(rs_2a)

rs_2a
write.csv(rs_2a,'sample.csv')



#Æ¯Á¤ Áßº¹ Å°¿öµå ifelse¹® Á¤¸®
#uniqueÅëÇØ Áßº¹ ÇÕÄ¡±â
#Combn() À§ÇØ n<mº¸´Ù ÀÛÀº ¸®½ºÆ® Á¦°Å
#°Ô½Ã±Û ¸¶´Ù ¸®½ºÆ® Ç®°í combnÀ¸·Î Á¶ÇÕ
#Graph·Î ¸®½ºÆ®º° ¿¬°áµÈ ¸µÅ©¼ö °¡ÁßÄ¡
#Source Target Weight º¯¼ö¸í »ı¼º
#for¹®À¸·Î °Ô½Ã±Û ¸ğµÎ ¹İº¹ÇÏ¿© rbind
#Source Target Áßº¹µÈ µ¥ÀÌÅÍ °¡ÁßÄ¡ ÇÕ»ê




#for (i in 1:10){
#  tryCatch(
#    {
#      remDr$getPageSource()
#      bu3<-remDr$findElement(using='css',value=paste0('body > div.RnEpo._Yhr4 > div.pbNvD.QZZGH.bW6vo > div > article > div > div.HP0qD > div > div > div.eo2As > div.EtaWk > ul > ul:nth-child(',i,') > li > ul > li > div > button > span'))
#      bu3$clickElement()
#    },
#    error=function(NoSuchElement){
#      print('´ë´ñ±ÛÀÌ ¾øÀ»°æ¿ì ¹ß»ıÇÏ´Â ¿À·ùÀÌ´Ï ÁøÇàÇÏ½Ã¸é µË´Ï´Ù')
#    }
#  )
#}

