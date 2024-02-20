library(shiny)
library(reticulate)


ui <- fluidPage(
  titlePanel("AMS Risk Prediction"),
  
  sidebarLayout(
    sidebarPanel(
      numericInput("age", "Age", 49),
      selectInput("gender", "Gender", c("M", "F")),
      numericInput("permanent_altitude", "Permanent Altitude (meters)", 1),
      numericInput("bp_systolic", "Systolic Blood Pressure", 1350),
      numericInput("bp_diastolic", "Diastolic Blood Pressure", 90),
      numericInput("spo2", "Blood Oxygen Saturation (%)", 98),
      numericInput("pulse", "Pulse Rate (bpm)", 103),
      checkboxInput("hypertension", "Hypertension", TRUE),
      checkboxInput("diabetes", "Diabetes", TRUE),
      numericInput("ascent_day", "Ascent Day", 1),
      checkboxInput("smoking", "Smoking", TRUE),
      checkboxInput("sym_headache", "Symptom: Headache", TRUE),
      checkboxInput("sym_gi", "Symptom: Gastrointestinal Distress", FALSE),
      checkboxInput("sym_fatigue", "Symptom: Fatigue", FALSE),
      checkboxInput("sym_dizziness", "Symptom: Dizziness", TRUE)
    ),
    mainPanel(
      textOutput("riskProbability"),
      textOutput("llsScore")
    )
  )
)



server <- function(input, output) {
  use_python("/Users/srinivas/miniforge3/envs/myenv_arm64/bin/python", required = TRUE)
  source_python("/Users/srinivas/AltitudeApp/AltitudeScript.py")
  
  # Reactive expression to prepare and get the prediction
  prediction <- reactive({
    sample_data <- data.frame(
      age = input$age,
      gender = as.character(input$gender),
      permanent_altitude = input$permanent_altitude,
      bp_systolic = input$bp_systolic,
      bp_diastolic = input$bp_diastolic,
      spo2 = input$spo2,
      pulse = input$pulse,
      hypertension = as.integer(input$hypertension),
      diabetes = as.integer(input$diabetes),
      ascent_day = input$ascent_day,
      smoking = as.integer(input$smoking),
      sym_headache = as.integer(input$sym_headache),
      sym_gi = as.integer(input$sym_gi),
      sym_fatigue = as.integer(input$sym_fatigue),
      sym_dizziness = as.integer(input$sym_dizziness)
    )
    
    # Call the Python function and handle potential errors
    tryCatch({
      get_prediction(sample_data)
    }, error = function(e) {
      # Return a default or error message
      list(ams_risk_probability = NA, scaled_lls_score = NA)
    })
  })
  
  # Display the prediction results
  output$riskProbability <- renderText({
    result <- prediction()
    if (!is.na(result$ams_risk_probability)) {
      paste("Probability of high AMS risk:", result$ams_risk_probability, "%")
    } else {
      "Error in prediction"
    }
  })
  
  output$llsScore <- renderText({
    result <- prediction()
    if (!is.na(result$scaled_lls_score)) {
      paste("Approximated LLS score:", result$scaled_lls_score)
    } else {
      "Error in prediction"
    }
  })
}

shinyApp(ui = ui, server = server)
