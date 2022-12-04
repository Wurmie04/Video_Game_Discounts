library(rvest)
library(dplyr)
library(RSelenium)
library(stringr)

#open connection to RSelenium
rD <-rsDriver(browser="chrome", port=1233L, chromever = "107.0.5304.62")
remDr <- rD[["client"]]


searchName = ""
steamGames = data.frame()

getReleaseDate = function(link){
  gamePage = read_html(link)
  releaseDate = gamePage %>% html_nodes(".game-info-details-section-release .game-info-details-content") %>%
    html_text() %>% paste(collapse = ",")
  steamReleaseDate = str_sub(releaseDate,-4,-1)
  return(steamReleaseDate)
}

checkCDKeyPrice = function(link){
  remDr$navigate(paste0("https://www.cdkeys.com/",link))
  tempCDKeyPage = read_html(remDr$getPageSource()[[1]])
  tempCDKeyPrice = tempCDKeyPage %>% html_nodes(".product-info-price .special-price .price") %>% html_text()
  if(length(tempCDKeyPrice) == 0){
    tempCDKeyPrice = tempCDKeyPage %>% html_nodes(".product-info-price .price") %>% html_text()
    if(length(tempCDKeyPrice) == 0){
      tempCDKeyPrice = tempCDKeyPage %>% html_nodes("#maincontent .price") %>% html_text()
      if(length(tempCDKeyPrice) == 0){
        tempCDKeyPrice = NULL
      }
    }
  }
  return(tempCDKeyPrice)
}

#get the prices for each game in psprices
getSteamLowestPrice = function(priceLink) {
  gamePage = read_html(priceLink)
  steamGamePrice = gamePage %>% html_nodes(".game-lowest-price-row:nth-child(1) .numeric") %>%
    html_text() %>% paste(collapse = ",")
  steamGamePrice = gsub("Free", "$0.00", steamGamePrice)
  steamGamePrice = gsub("~", "", steamGamePrice)
  steamGamePrice = gsub("(\\$.*[\\,*]).*", "\\1", steamGamePrice)
  steamGamePrice = gsub("\\$", "", steamGamePrice)
  steamGamePrice = gsub("\\,", "", steamGamePrice)
  
  return(steamGamePrice)
}

getCKeysPrice = function(gameName, gameType){
  searchName = paste(gameName, gameType)
  remDr$findElement(using = "id", value = "search")$clearElement()
  remDr$findElement(using = "id", value = "search")$sendKeysToElement(list(searchName, "\uE007"))
  
  #get the prices from the page
  CDKeyPage = read_html(remDr$getPageSource()[[1]])
  #get the discount price
  CDKeyPrice = CDKeyPage %>% html_nodes(".product-info-price .special-price .price") %>% html_text()
  #if there is no discount
  if(length(CDKeyPrice) == 0){
    CDKeyPrice = CDKeyPage %>% html_nodes(".product-info-price .price") %>% html_text()
    #check to see if page is -pc
    if(length(CDKeyPrice) == 0){
      gameName = gsub("-", " ", gameName)
      gameName = gsub(":", "", gameName)
      gameName = gsub("\\s+", " ", gameName)
      gameName = paste0(gsub(" ","-",gameName), "-pc")
      CDKeyPrice = checkCDKeyPrice(gameName)
      #check to see if page is -pc-steam
      if(length(CDKeyPrice) == 0){
        gameName = paste0(gameName, "-steam")
        CDKeyPrice = checkCDKeyPrice(gameName)
        #check to see if page is -pc-steam-cd-key
        if(length(CDKeyPrice) == 0){
          gameName = paste0(gameName, "-cd-key")
          CDKeyPrice = checkCDKeyPrice(gameName)
          #if none of the above, set price to 0
          if(length(CDKeyPrice) == 0){
            CDKeyPrice = "0.00"
          }
        }
      }
    }
  }
  CDKeyPrice = gsub("\\$","",CDKeyPrice)
  return(CDKeyPrice)
}

for(steamPageResult in seq(from = 1, to = 1, by = 1)){
  remDr$navigate(paste0("https://gg.deals/deals/?minRating=0&sort=metascore&store=4&page=", steamPageResult))
  getSteamPrices <- read_html(remDr$getPageSource()[[1]])
  #get all the product names
  steamProductName = getSteamPrices %>% html_nodes(".title.tippy-initialized") %>% html_text()
  
  #get to a href link for each game
  steamGameLinks = getSteamPrices %>% html_nodes("#deals-list .full-link") %>%
    html_attr("href") %>% paste("https://gg.deals", ., sep="")
  
  #release date
  releaseDate = sapply(steamGameLinks, FUN = getReleaseDate)
  steamLowestPrice = sapply(steamGameLinks, FUN = getSteamLowestPrice)
  
  gameType = "Steam"
  
  remDr$navigate("https://www.cdkeys.com/")
  CDKeysPrices = sapply(steamProductName, gameType, FUN = getCKeysPrice)
  
  #write to data
  steamGames = rbind(steamGames, data.frame(gameType, steamProductName, releaseDate, steamLowestPrice, CDKeysPrices))
  write.csv(steamGames, "SteamGames.csv")
}

#close RSelenium
remDr$close()
rD$server$stop()

