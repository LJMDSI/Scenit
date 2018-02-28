## WARNING - I'm new to shiny so this is not best case code, but it's a start ! Recommend reading 
## up on the googleway and shiny packages on the web. 

library(shiny)
library(shinydashboard)
library(googleway)

## This app links directly to googlemaps so you will need a Google MAP API key, which is free. 
## You can get it here: https://developers.google.com/maps/documentation/javascript/get-api-key

set_key("Your API Key")

## Note: I've put in couple of set origins and destinations, and just one waypoint just to see 
## if I could get the app working. In reality we will need to work out how to produce lists of waypoints 
## for each combination of Origin and Destination. IFElSE function lines 83-93 isn't an ideal way of 
## handling scenic choice but couldn't get other versions of code to work.

## VERY Important ! After you've run the code, it will launch R Viewer but you need to click 
## open in browser for it to work.

## User Interface

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      titlePanel("Have you Scenit?"),
      
      selectInput(inputId = "origin", 
                  label = "From", 
                  choices = c("UTS Sydney Building 11", "Circular Quay"),
                  selected = "UTS Sydney Building 11"),
      
      selectInput(inputId = "destination", 
                  label = "To", 
                  choices = c("Town Hall Station Sydney", "Central Station Sydney"),
                  selected = "Town Hall Station Sydney"),
      
      selectInput(inputId = "mode", 
                  label = "Walking or Cycling today ?", 
                  choices = c("walking", "bicycling"),
                  selected = "walking"),
      
      selectInput(inputId = "scenic", 
                  label = "Something Scenic?", 
                  choices = c("Yes", "No"),
                  selected = "Yes"),

      actionButton(inputId = "getRoute", label = "Get Route")),
    
    mainPanel(google_mapOutput("map")
    )))

## Server function

server <- function(input, output){
  
  
  #key = "AIzaSyD2Gy_9Wg65AWa0Ti25G9WGQxGQQQvAgCg"
  
  #waypoint1=list(c("Sydney Fish Markets"))
  
  df_route <- eventReactive(input$getRoute,{
    
    print("getting route")
    
    
    o <- input$origin
    d <- input$destination
    m <- input$mode
    #w <- ifelse(input$scenic == "Yes", list(c("Via Sydney Fish Markets")), NULL)
    
    return(data.frame(origin = o, destination = d, mode = m, stringsAsFactors = F))
    
  })
  
  
  ## App Output
  
  output$map <- renderGoogle_map({
    
    df <- df_route()
    print(df)
    #if(df$origin == "" | df$destination == "")
    # return()
    
    ifelse(input$scenic == "Yes", 
           
           res <- google_directions(origin = df$origin,
                                    destination = df$destination,
                                    mode = df$mode,
                                    waypoints = list(c("Via Chinese Garden of Friendship, Sydney"))),
           
           res <- google_directions(origin = df$origin,
                                    destination = df$destination,
                                    mode = df$mode))
    
    
    df_route <- data.frame(route = res$routes$overview_polyline$points)
    
    google_map() %>%
      add_polylines(data = df_route, polyline = "route")
  })
}

shinyApp(ui, server)

