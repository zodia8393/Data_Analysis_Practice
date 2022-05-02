getwd()
setwd('C:/Users/User/Documents/WS') #집 컴퓨터용 디렉터리

library(RSelenium)
library(wdman)

RSelenium_Connect=function(){
  tryCatch(expr={
    port_no=as.integer(sample(2000:8000,1))
    rs=chrome(port=port_no)
    remDr<-remoteDriver(remoteServerAddr="localhost",
                        port=port_no,
                        browserName="chrome")
    remDr$open()
  },finally={
    port_no=as.integer(sample(2000:8000,1))
    browser_ver=binman::list_versions(appname = "chromedriver")
    browser_ver=browser_ver[[1]][length(browser_ver[[1]])-2]
    rs=chrome(port=port_no,version=browser_ver)
    remDr<-remoteDriver(remoteServerAddr="localhost",
                        port=port_no,
                        browserName="chrome")
    remDr$open()
    remDr$navigate('https://www.instagram.com/')
    Sys.sleep(2)
    
    #아이디 비번
    id<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[1]/div/label/input')
    pw<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[2]/div/label/input')
    #로그인 버튼
    login_btn<-remDr$findElement(using="xpath",value='//*[@id="loginForm"]/div/div[3]/button/div')

    id$clickElement()
    Sys.sleep(1)
    id$sendKeysToElement(list("testaccount00118"))
    Sys.sleep(1)
    pw$clickElement()
    Sys.sleep(1)
    pw$sendKeysToElement(list("1q2w3e4r1!"))
    Sys.sleep(1)
    login_btn$clickElement()
    Sys.sleep(3)
    btn1<-remDr$findElement(using='xpath',value='//*[@id="react-root"]/section/main/div/div/div/section/div/button')
    btn1$clickElement()
    Sys.sleep(3)
    btn2<-remDr$findElement(using='xpath',value='/html/body/div[6]/div/div/div/div[3]/button[2]')
    btn2$clickElement()
    
    #검색창 
    search<-remDr$findElement(using='xpath',value='//*[@id="react-root"]/section/nav/div[2]/div/div/div[2]/input')
    search$clickElement()
    search$sendKeysToElement(list('#패션'))
  })
}

RSelenium_Connect()




