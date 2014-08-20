library(shiny)

# Define server logic
shinyServer(function(input, output) {  
  num_games=0
  #Set up high scores table
  scores <<- data.frame(best=c(NA,NA,NA), average=c(0,0,0))
  row.names(scores) <<- c("SDs from Intercept", "SDs from Slope", "% from RMSE")
  
  #Skip first automatic iteration of Guess button
  new_game <<- FALSE
#Guess Button
  observe({
    # Take a dependency on input$check_guess
    input$check_guess
    
    #Only execute if this is the first time this button has been pressed for this game
    if (new_game){
      #Train with lm to get best fit, then extract coefficianets for plotting
      lm_fit <<- lm(plot_data$y ~ plot_data$x)
      lm_intercept <<- summary(lm_fit)$coef[1,1]
      lm_slope <<- summary(lm_fit)$coef[2,1]
      lm_intercept_sd <<- summary(lm_fit)$coefficients[1,2]
      lm_slope_sd <<- summary(lm_fit)$coefficients[2,2]
      show_lm <<- TRUE
  
      #Create results table
      isolate({
        user_intercept <<- input$intercept
        user_slope <<- input$slope
      })
      user_y <<- user_intercept + user_slope*x
      user_rmse <<- sum((user_y - y)^2) / (length(y) - 2)
      lm_rmse <<- sum(lm_fit$residuals^2) / (length(y) - 2)
      
      sd_off_intercept <<- abs(lm_intercept - user_intercept) / lm_intercept_sd
      sd_off_slope <<- abs(lm_slope - user_slope) / lm_slope_sd
      perc_off_rmse <<- (user_rmse - lm_rmse) / lm_rmse
      
      results <<- data.frame (Intercept=c(user_intercept, lm_intercept, sd_off_intercept, NA),
                             Slope=c(user_slope, lm_slope, sd_off_slope, NA),
                             Root_Mean_Squared_Error=c(user_rmse, lm_rmse, NA, perc_off_rmse))
      row.names(results) <<- c("Your guess", "lm model result", "SDs away from model coefficients", "% away from RMSE")
      
      output$results <<- renderTable(results)
      
      #Update high/low scores
      num_games<<-num_games+1
      user_results <<- c(sd_off_intercept, sd_off_slope, perc_off_rmse)
      #If first game then expect NA values in high scores - allocate user's 1st scores
      if (num_games==1){
        scores$best <<- user_results
      }

      better <<- (user_results < scores$best)
      for (i in 1:3){ 
        if(better[i]){
          scores$best[i] <<- user_results[i]
        } 
      }
      
      scores$average <<- (scores$average*(num_games-1) + user_results) / num_games
      
      output$scores <<- renderTable(scores)
      
      new_game <<- FALSE
    }
  })
  
#Reset button
  observe({
    # Take a dependency on input$resetButton
    input$reset_button
    
    new_game <<- TRUE
    isolate({
      difficulty <<- input$difficulty
      })
    
    x <<- rnorm(80, mean=20, sd=20)
    y <<- (6-difficulty)*x + rnorm(80,mean=40, sd=difficulty*15)*max(abs(rnorm(1,0,2)),0.1)
    plot_data<<-data.frame(x=x, y=y)
    
    show_lm <<- FALSE
    
    results <<- data.frame (Intercept=c(NA,NA,NA,NA), Slope=c(NA,NA,NA,NA), Root_Mean_Squared_Error= c(NA,NA,NA,NA))
    row.names(results) <<- c("Your guess", "lm model result", "SDs away from model coefficients", "% away from RMSE")
    output$results <<- renderTable(results)
  
  })

#Plot
  output$distPlot <- renderPlot({
    # Take a dependency on input$resetButton
    input$reset_button
    input$check_guess
    
    #Plot x Vs y
    plot(plot_data$x, plot_data$y, xlab="", ylab="")

    #plot user's guessed line
    abline(input$intercept, input$slope)
    
    if(show_lm){
      abline(lm_intercept, lm_slope, col="red")
    }
  })
})
