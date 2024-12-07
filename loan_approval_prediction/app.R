library(shiny)
library(randomForest)
library(magrittr)
library(tidyverse)
library(glue)

# Load the trained random forest model
load("rf_trained_model.RData")

# Define the UI
ui <- fluidPage(
  titlePanel("Predicting loan approval status"),
  sidebarLayout(
    sidebarPanel(
      # Numeric inputs for the 7 numeric covariates
      sliderInput("Age", "Enter nearest age between 18 and 75",
        min = 18, max = 75, value = 18, step = 1
      ),
      sliderInput("Income", "Enter your annual income to the nearest $10,000 ($)",
                  min = 0, max = 750000, value = 50000, step = 10000
      ),
      sliderInput("Emp_length", "How long have you been in the work force (to the nearest 1 year)?",
                  min = 0, max = 70, value = 2, step = 1
      ),
      sliderInput("Loan_amount", "How much of a loan do you intend of obtaining ($)?",
                  min = 1000, max = 300000, value = 5000, step = 1000
      ),
      sliderInput("Int_rate", "What is the interest rate you expect on the loan (%)?",
                  min = 0.5, max = 30, value = 2.5, step = 0.5, post = "%"
      ),
      sliderInput("Loan_inc_prop", "What is your loan amount as a percentage of your income? (%)",
                  min = 1, max = 200, value = 1, step = 1, post = "%"
      ),
      sliderInput("Cred_hist_length", "Length of your credit history (years)",
                  min = 0, max = 75, value = 5, step = 1
      ),
      
      # Dropdowns for the 4 categorical covariates
      selectInput("Home_ownership_status", "What is your home ownership status?", choices = c("Own", "Rent", "Mortgage", "Other")),
      selectInput("Loan_intent", "What is your intent of obtaining a loan?", choices = c("Education", "Medical", "Personal", 
                                                                                         "Business", "Debt Reconciliation", "Home")),
      selectInput("Loan_grade", "What grade of a loan do you intend of obtaining (a higher grade is one from a higher rated financial institution)", 
                  choices = LETTERS[1:7]),
      selectInput("Default_history", "Do you have on file of a past default?", choices = c("Y", "N")),
      
      actionButton("predict", "Click to see if a loan with the options which you selected will get approved")
    ),
    mainPanel(
      textOutput("prediction")
    )
  )
)

# Define the server
server <- function(input, output, session) {
  observeEvent(input$predict, {
    print(input$Age)
    print(input$Income)
    print(input$Int_rate)
    print(input$Home_ownership_status)
    print(input$Emp_length)
    print(input$Loan_amount)
    print(input$Loan_inc_prop)
    print(input$Cred_hist_length)
    print(input$Loan_intent)
    print(input$Loan_grade)
    print(input$Default_history)
  })
  prediction <- eventReactive(input$predict, {
    # Prepare input data as a data frame
    new_data <- data.frame(
      person_age = input$Age,
      person_income = input$Income,
      person_emp_length = input$Emp_length,
      loan_amnt = input$Loan_amount,
      loan_int_rate = input$Int_rate,
      loan_percent_income = input$Loan_inc_prop,
      cb_person_cred_hist_length = input$Cred_hist_length,
      person_home_ownership = input$Home_ownership_status,
      loan_intent = input$Loan_intent,
      loan_grade = factor(input$Loan_grade, levels = LETTERS[1:7]),
      cb_person_default_on_file = factor(input$Default_history, levels = c("N", "Y"))
    )
    
    new_data %<>%
      mutate(person_home_ownership = factor(case_when(person_home_ownership == "Own" ~ "OWN",
                                               person_home_ownership == "Rent" ~ "RENT",
                                               person_home_ownership == "Mortgage" ~ "MORTGAGE",
                                               person_home_ownership == "Other" ~ "OTHER"),
                                            levels = c("MORTGAGE", "OTHER", "OWN", "RENT")),
             loan_intent = factor(case_when(loan_intent == "Education" ~ "edu",
                                     loan_intent == "Medical" ~ "med",
                                     loan_intent == "Personal" ~ "personal",
                                     loan_intent == "Business" ~ "bus",
                                     loan_intent == "Home" ~ "home",
                                     loan_intent == "Debt Reconciliation" ~ "debt_rec"),
                                  levels = c("debt_rec", "edu", "home", "med", "personal", "bus")
             )
      )
    
    str(new_data)
    
    # Predict using the random forest model
    pred <- predict(rf_fit, newdata = new_data, type = "response")
    levels(pred)[pred]  # Return the predicted class (0 or 1)
  })
  
  # Render the prediction
  output$prediction <- renderText({
    req(input$predict)  # Ensure the button is clicked
    ifelse(prediction() == 0, 
      glue("Thank you for your interest in applying for a loan. 
        We are however unfortunately unable to approve you for a loan based on the inputs provided."),
      glue("WOO HOO! You have been pre-approved for a loan. This does not guarantee you a loan until all documentation
        is provided. Please follow up at smallloan@gmail.com for next steps. Looking forward to partnering with you in your next
           step forward.")
    )
  })
}

# Run the app
shinyApp(ui, server)
