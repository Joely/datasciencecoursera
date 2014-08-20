library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Guess the linear model!"),
  
  # Sidebar with a slider input to change intercept and slope
  sidebarLayout(
    sidebarPanel(
      p("Guess the slope and intercept of the plot"),
      sliderInput("slope",
                  "Slope of the line:",
                  min = -1,
                  max = 10,
                  value = 1,
                  step = 0.01),
      sliderInput("intercept",
                  "Intercept of the line:",
                  min = -100,
                  max = 150,
                  value = 0),
      p(""),
      p("Then click the 'check my guess' button to see the best fit the lm model found"),
      p("The results section below the plot will tell you how close you came"),
      actionButton("check_guess",
                  "Check your guess!"),
      p(""),
      p("Use this slider to increase or decrease the difficulty of guessing the fit"),
      sliderInput("difficulty",
                 "Difficulty (1-5)",
                 min = 1,
                 max = 5,
                 value = 2),
      p(""),
      p("Click this button to start a new game"),
      actionButton("reset_button",
                   "New Game"),
      p(""),
      h5("Past results - best and average"),
      tableOutput("scores")
    ),
    
    # Show a plot of the generated distribution
    # with user's guess and model fit if appropriate
    mainPanel(
      plotOutput("distPlot"),
      #show table of user results
      h5("Results"),
      p("How close were you to the best intercept and slope? (measured in standard deviations)"),
      p("How close were you to achieving the minimum Root Mean Squared Error? (measured in % above)"),
      tableOutput("results")
    )
  )
))
