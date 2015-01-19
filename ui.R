library(shiny)
shinyUI(fluidPage(
  h3("US Historical Oil / Gas Production and Pricing"),
   fluidRow(
          column(2,
              h5("Data Selection"),
                 checkboxGroupInput("id1", "Choose a Region:",
                             choices=c("Bakken Region", "Eagle Ford Region",
                                       "Haynesville Region","Niobrara Region",
                                       "Permian Region", "Utica Region", 
                                       "Marcellus Region", "Woodford Region",
                                       "Barnett Region", "Central Region",
                                       "West Region", "Black Warrior"),
                             selected = "Bakken Region", inline =FALSE)
          ),
          column(6,
                 plotOutput('us', width=550, height =450)
          ),
          column(4,
            h5("Does Oil Output vary with Oil Prices ?"),     
                 plotOutput('oilPrice', height = 150),
                 plotOutput('oilVprice', height =150),
            h5("Oil Total Output vs. Price Rsq:"),
                 verbatimTextOutput("rsq"),
            h5("Production goes very low as prices fall below cutoff of ~75")
                 
                
          )
   ),
  
    fluidRow(
           column(4,
                   plotOutput('rig_count', height= 255),
           h6("All data comes from the US Energy Information Administration")
           ),
             column(4,          
                   plotOutput('op_TP', height= 255),
          h6("website: www.eia.gov")
                   
             ),
           column(4,
                  plotOutput('ng_TP', height= 255),
          h6("Author: Cary Correia")
                  
           )
    )
    
))
