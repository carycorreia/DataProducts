library(shiny)
library(xlsx)
library(stats)
library(Hmisc)
library(zoo)
library(rgdal)
library(ggmap)
library(ggplot2)

###########################################################
## Read in the shale basins dataset
#setwd("~/Desktop/Gas Prod Pricing/GasProdPricing/ShapeFiles/shalegasbasin")
basins<-readOGR("./data","US_ShaleBasins_EIA_May2011")             # data is in 1 big sp dataset
basins <- spTransform(basins, CRS("+proj=longlat +datum=WGS84"))

## Read in shale plays dataset 
# setwd("~/Desktop/Gas Prod Pricing/GasProdPricing/ShapeFiles/shalegasplay")
plays<-readOGR("./data","US_ShalePlays_EIA_May2011")             # data is in 1 big sp dataset
plays<- spTransform(plays, CRS("+proj=longlat +datum=WGS84"))

## Convert the shale data into a useable form for mapping
basins <- fortify(basins)
plays <- fortify(plays)

## Both data sets have numeric id's instead of meanginful names - download keys to fix this
file<-"./data/wellproduction.xlsx"
B_key<- read.xlsx(file, sheetIndex="Basins", startRow=1, as.data.frame=TRUE, header=TRUE)
P_key<- read.xlsx(file, sheetIndex="sheet", startRow=1, as.data.frame=TRUE, header=TRUE)
B_key$id<-as.character(B_key$id); P_key$id<-as.character(P_key$id)
basins<-merge(basins, B_key, by="id")
plays<-merge(plays, P_key, by="id") ## at this point plays has all of the regional plays before a user clicks the button and sub selects

## Read in the well data for the output graphs
file<-"./data/wellproduction.xlsx"
newdata<- read.xlsx(file, sheetIndex="All Data", startRow=3, as.data.frame=TRUE, header=FALSE)
## Map the USA with google maps
USmap = map = get_map(location = 'United States', source = 'google', zoom = 4)

## Create function for regression
fit<-function(input){
      fit<-lm(X5 ~ X11,  data=subset(newdata, X9==input))
      out<-summary(fit)[9]
      return(out)
}

#####################################################################
shinyServer(
  function(input, output){
    
## Create map
    # now output the Plot
      output$us<-renderPlot({
          play_split<-subset(plays, Region==({input$id1}))
          ggmap(USmap) + 
                    geom_polygon(aes(fill = 'white', x = long, y = lat, group = group), 
                                 data = basins,
                                 alpha = 0.8, 
                                 color = "black",
                                 size = 0.2) +
                    geom_polygon(aes(fill = 'red', x = long, y = lat, group = group), 
                                 data = play_split,
                                 alpha = 0.8, 
                                 color = "black",
                                 size = 0.2) +
                    theme(legend.position="none")
     })
     

## output Number of Oil rigs data for the selected region: 
      output$rig_count <- renderPlot({
        data=subset(newdata, X9=={(input$id1)})
        data[,1]<-as.Date(data[,1], "%YM%m")
        ggplot(data=data, aes(x=X1, y=X2)) + geom_line(aes(color=X9)) + theme(legend.position="bottom") + 
               labs(x="Date",y="Rig Count",title="Total Number of Rigs")   
      })
 
## output Total Oil Production  data for the selected region:  
      output$op_TP <- renderPlot({
        data=subset(newdata, X9=={(input$id1)})
        data[,1]<-as.Date(data[,1], "%YM%m")
        ggplot(data=data, aes(x=X1, y=X5))+ geom_line(aes(color=X9)) + theme(legend.position="bottom") +
               labs(x="Date",y="Oil Output (bbl/d)",title="Oil Production (bbl/d)")  
      })


## output Total NG Production  data for the selected region:  
      output$ng_TP <- renderPlot({
        data=subset(newdata, X9=={(input$id1)})
        data[,1]<-as.Date(data[,1], "%YM%m")
        ggplot(data=data, aes(x=X1, y=X8))+ geom_line(aes(color=X9)) + theme(legend.position="bottom") +
               labs(x="Date",y="Nat Gas Output",title="Natural Gas Production (Mcf/d")  
      })

## output Static graph for the Oil Price for the selected region:  
    output$oilPrice <- renderPlot({
      data=subset(newdata, X9=={(input$id1)})
      data[,1]<-as.Date(data[,1], "%YM%m")
      ggplot(data=data, aes(x=X1, y=X11))+ geom_point(aes(color="black")) + theme(legend.position="none") +
        labs(x="Date",y="OilPrice $'s Barrel",title="Price of Oil vs Time")  
    })
      
## output graph for the Oil TP vs Oil Price for the selected region:  
      output$oilVprice<- renderPlot({
        data=subset(newdata, X9=={(input$id1)})
        ggplot(data=data, aes(x=X11, y=X5))+ geom_point(aes(color=X9)) + theme(legend.position="none") +
          labs(x="Oil Price",y="Total Production",title="Oil Production vs Price")  
    })

## produce regression data:
       output$rsq<-renderPrint({fit(input$id1)})
 

  }
)