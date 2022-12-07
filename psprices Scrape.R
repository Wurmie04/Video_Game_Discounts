#uncomment install comments if first time and have not installed
#install.packages("rvest")
#install.packages("dplyr")
#install.packages("RSelenium")

library(rvest)
library(dplyr)
library(RSelenium)
library(stringr)

#open connection to RSelenium
rD <-rsDriver(browser="chrome", port=1236L, chromever = "107.0.5304.62")
remDr <- rD[["client"]]

#create empty data frame
games = data.frame()
gameType = ""
searchName = ""
lowestPrice = 0
releaseDate = 0
gameFlyPrice = 0
mercariPrice = 0
ebayPrice = 0


#get the prices for each game in psprices
getPrice = function(priceLink) {
  gamePage = read_html(priceLink)
  gamePrice = gamePage %>% html_nodes(".text-secondary strong:nth-child(1)") %>%
    html_text() %>% paste(collapse = ",")
  if(gamePrice == ""){
    gamePrice = "0.00"
  }
  else{
    gamePrice = gsub("\\$","",gamePrice)
  }
  return(gamePrice)
}

getReleaseDate = function(priceLink){
  gamePage = read_html(priceLink)
  releaseDate = gamePage %>% html_nodes("strong~ strong+ strong") %>%
    html_text() %>% paste(collapse = ",")
  releaseDate = str_sub(releaseDate,-4,-1)
  return(releaseDate)
}

getSwitchReleaseDate = function(priceLink){
  gamePage = read_html(priceLink)
  releaseDate = gamePage %>% html_nodes("strong+ strong") %>%
    html_text() %>% paste(collapse = ",")
  releaseDate = str_sub(releaseDate,-4,-1)
  return(releaseDate)
}

#gets the lowest price on Ebay of the given game
getEbayPrice = function(name, console){
  newName = paste(name, console)
  remDr$findElement(using = "id", value = "gh-ac")$clearElement()
  remDr$findElement(using = "id", value = "gh-ac")$sendKeysToElement(list(newName, "\uE007"))
  ebayPrices = read_html(remDr$getPageSource()[[1]])
  ebayProductPrice = ebayPrices %>% html_nodes(".s-item__price") %>% html_text()
  ebayProductName = ebayPrices %>% html_nodes(".s-item__title span") %>% html_text()
  
  avg = 0
  total = 0
  value = "to"
  
  newTitle = tolower(gsub("New Listing", "", ebayProductName[2]))
  lowername = tolower(name)
  
  if(grepl(lowername, newTitle, fixed = TRUE)){
    for (x in 2:length(ebayProductPrice)){
      if(!grepl(value, ebayProductPrice[x])){
        priceinDouble = as.double(gsub("\\$|,", "", ebayProductPrice[x]))
        if(priceinDouble < 60 && priceinDouble > 10){
          total = total + priceinDouble
        }
      }
    }
  }
  
  avg = total / length(ebayProductPrice)
  return(avg)
}

#get game and prices for PS5
#55 pages
for(PS5pageResult in seq(from = 1, to = 1, by = 1)){
  remDr$navigate(paste0("https://psprices.com/region-us/search/?platform=PS5&show=games&page=", PS5pageResult))
  psprices <- read_html(remDr$getPageSource()[[1]])
  #get all the product names
  productName = psprices %>% html_nodes(".title span") %>% html_text()

  #get to a href link for each game
  gameLinks = psprices %>% html_nodes(".content__game_card__cover") %>%
    html_attr("href") %>% paste("https://www.psprices.com", ., sep="")

  #release date
  releaseDate = sapply(gameLinks, FUN = getReleaseDate)
  lowestPrice = sapply(gameLinks, FUN = getPrice)
  
  gameType = "PS5"
  
  remDr$navigate("https://www.ebay.com/")
  ebayPrice = sapply(productName, gameType, FUN=getEbayPrice)

  #write to data
  games <- rbind(games, data.frame(gameType, productName, lowestPrice, releaseDate, ebayPrice))
}

#get game and prices for PS4
#200 pages
for(PS4pageResult in seq(from = 1, to = 1, by = 1)){
  remDr$navigate(paste0("https://psprices.com/region-us/search/?platform=PS4&show=games&page=", PS4pageResult))
  psprices <- read_html(remDr$getPageSource()[[1]])
  #get all the product names
  productName = psprices %>% html_nodes(".title span") %>% html_text()
  
  #get to a href link for each game
  gameLinks = psprices %>% html_nodes(".content__game_card__cover") %>%
    html_attr("href") %>% paste("https://www.psprices.com", ., sep="")
  
  #release date
  releaseDate = sapply(gameLinks, FUN = getReleaseDate)
  lowestPrice = sapply(gameLinks, FUN = getPrice)
  
  gameType = "PS4"
  
  remDr$navigate("https://www.ebay.com/")
  ebayPrice = sapply(productName, gameType, FUN=getEbayPrice)
  
  #write to data
  games <- rbind(games, data.frame(gameType, productName, lowestPrice, releaseDate, ebayPrice))
}

#Switch
#200 pages
for(SwitchpageResult in seq(from = 1, to = 1, by = 1)){
  remDr$navigate(paste0("https://psprices.com/region-us/search/?platform=Switch&show=games&page=", SwitchpageResult))
  psprices <- read_html(remDr$getPageSource()[[1]])
  #get all the product names
  productName = psprices %>% html_nodes(".title span") %>% html_text()
  
  #get to a href link for each game
  gameLinks = psprices %>% html_nodes(".content__game_card__cover") %>%
    html_attr("href") %>% paste("https://www.psprices.com", ., sep="")
  
  #release date
  releaseDate = sapply(gameLinks, FUN = getSwitchReleaseDate)
  lowestPrice = sapply(gameLinks, FUN = getPrice)
  
  gameType = "Nintendo"
  
  remDr$navigate("https://www.ebay.com/")
  ebayPrice = sapply(productName, gameType, FUN=getEbayPrice)
  
  #write to data
  games <- rbind(games, data.frame(gameType, productName, releaseDate, lowestPrice, ebayPrice))
  #write.csv(games, "ConsoleGames.csv")
}

write.csv(games, "ConsoleGames.csv")

#close RSelenium
remDr$close()
rD$server$stop()

