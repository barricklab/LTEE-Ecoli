#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DT)
library(scales)
library(tidyverse)
library(ggplot2)
library(shinyjs)
library(shinyWidgets)

#load and clean data
transfer_data <- read_csv("transfers.csv")

transfer_data = transfer_data %>%
  mutate(date = as.Date(date, format = "%m/%d/%y"), generation = as.double(generation))

#sort(unique(transfer_data$researcher))

day_list = c("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday")

start_date = "1988-02-24"
end_date = max(transfer_data$date)

researcher_list = sort(unique(transfer_data$researcher))

# Define UI for application that draws a histogram
ui <- shinyUI(
  
  # add date range
  
  # add day of the week selector
  
  fluidPage(
    titlePanel("LTEE Transfer History"),
    div(
    mainPanel(
      fluidRow(  
        column(3,
          dateInput("start_date", "Start Date", 
                    value = start_date,
                    min = start_date,
                    max = end_date
                    )
        ),
        column(3,
          dateInput("end_date", "End Date", 
                    value = end_date,
                    min = start_date,
                    max = end_date
                    )
        ),
        column(6,
              actionButton("all_dates", "All dates"),
              actionButton("applicable_dates", "Applicable dates"),
              style = "margin-top: 25px;"
        )
      ),
      fluidRow(  
        column(8,
               selectInput("weekdays", 
                           label = "Weekdays Included",
                           choices = day_list,
                           selected = day_list,
                           multiple=T,
                           width="100%"
               )
        ),
        column(4,
               actionButton("all_weekdays", "All days"),
               actionButton("clear_weekdays", "Clear days"),
               style = "margin-top: 25px;")
      ),
      fluidRow(  
        column(6,
               multiInput(
                 inputId = "researchers", label = "Researchers Included",
                 choices = researcher_list,
                 selected = researcher_list, width = "100%"
               )
        ),
        column(2,
               actionButton("all_researchers", "All researchers"),
               p(),
               actionButton("clear_researchers", "Clear researchers"),
               style = "margin-top: 25px;"
               )
      ),
      tabsetPanel(
        type = "tabs",
        tabPanel("Transfers by Generation", 
                 plotOutput(outputId = "transfers_by_generation_plot", 
                            height=400, 
                            width=780, 
                            inline=T
                 )
        ),
        tabPanel("Transfers by Year", 
                 plotOutput(outputId = "transfers_by_year", 
                            height=400, 
                            width=780, 
                            inline=T
                 )
        ),
        tabPanel("Data", 
                 dataTableOutput(outputId = "transfers_table"),
                 p(),
                 downloadButton("download_complete_csv", label = "Download Complete CSV"),
                 downloadButton("download_summary_csv", label = "Download Summary CSV")
        ),
      ),

     # plotOutput(outputId = "plot", height = 400, width=780, inline=T),
    ), style = 'width:1200px;'
    ),
    useShinyjs()
  )
)

server <- shinyServer(function(input, output, session) {
  
  # ALL and CLEAR buttons
  observeEvent(input$all_dates, {
    updateDateInput(session, "start_date", value = start_date)
    updateDateInput(session, "end_date", value = end_date)
  })
  
  observeEvent(input$applicable_dates, {
    x = in_range_transfer_data()
    updateDateInput(session, "start_date", value = min(x$date))
    updateDateInput(session, "end_date", value = max(x$date))
  })
  
  # ALL and CLEAR buttons
  observeEvent(input$clear_weekdays, {
    updateSelectInput(session, "weekdays", selected = character(0))
  })
  
  observeEvent(input$all_weekdays, {
    updateSelectInput(session, "weekdays", selected = day_list)
  })
  
  observeEvent(input$clear_researchers, {
    updateMultiInput(session, "researchers", selected = character(0))
  })
  
  observeEvent(input$all_researchers, {
    updateMultiInput(session, "researchers", selected = researcher_list)
  })
  
  in_range_transfer_data <- reactive({
    x = transfer_data
    x = x %>% filter(!is.na(generation))
    
    # Take a certain date range
    x = x %>% 
      filter(date >= input$start_date) %>% 
      filter(date <= input$end_date)
    
    # Take certain weekdays
    x = x %>% filter(weekday %in% input$weekdays)
    
    # Take certain researchers
    x = x %>% filter(researcher %in% input$researchers)
    
    # Fix researcher factor levels
    x$researcher = factor(x$researcher , levels=sort(unique(x$researcher)))
    
    # Grey buttons that are not needed
    if (length(input$weekdays) > 0) {
      enable("clear_weekdays")
    } else {
      disable("clear_weekdays")
    }
    
    if (length(input$weekdays) == length(day_list)) {
      disable("all_weekdays")
    } else {
      enable("all_weekdays")
    }
    
    if (length(input$researchers) > 0) {
      enable("clear_researchers")
    } else {
      disable("clear_researchers")
    }
    
    if (length(input$researchers) == length(researcher_list)) {
      disable("all_researchers")
    } else {
      enable("all_researchers")
    }
    
    return(x)
  })
  
  transfer_data_summary <- reactive({
    
    x = in_range_transfer_data() %>%
      filter(!is.na(researcher)) %>%
      group_by(researcher) %>%
      summarize(transfers = n()) %>% 
      arrange(desc(transfers))
    
    return(x)
  })
  
  transfers_by_year_data <- reactive({
    
    x = in_range_transfer_data()
    x$year = format(x$date, "%Y")
    
    x = x %>%
      group_by(researcher, year) %>%
      summarize(transfers = n())
    
    return(x)
  })
  
  ## Now create outputs
  
  output$transfers_table <- renderDataTable(
    {
      return(transfer_data_summary())
    }, 
    escape=FALSE, 
    options = list(pageLength = 10,
                   lengthMenu = c(10, 25, 100, 200)
                   # , order = list(list(1, 'asc'), list(2, 'asc'), list(3, 'asc'))
    )
  )
  
  output$transfers_by_year <- renderPlot(
    expr={
      
      start_year = format(input$start_date, "%Y")
      end_year = format(input$end_date, "%Y")
      
      my_data = transfers_by_year_data()
      top_researchers = as.character((head(transfer_data_summary(), n=7))$researcher)
      my_data$highlighted_researcher = as.character(my_data$researcher)
      my_data$highlighted_researcher[!my_data$researcher %in% top_researchers] = "Other"
      my_data$highlighted_researcher = factor(my_data$highlighted_researcher, levels=c(top_researchers, "Other"))
      
      
      
      okabe = c("#E69F00", "#56B4E9",  "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
      okabe = okabe[1:length(top_researchers)]
      okabe = c(okabe, "#999999")
      
      p = ggplot(data = my_data, 
                 aes(x = year, y = transfers, fill=highlighted_researcher)
        ) + 
        theme_bw() +
        geom_col() + 
        ylab("Transfers") +
        labs(fill='Researcher') +
        scale_fill_manual(values = okabe) +
        scale_y_continuous(expand = expansion(mult = c(0, 0.05))) +
        scale_x_discrete(limits=as.character(start_year:end_year)) +
        theme(axis.text.x = element_text(angle=90, vjust=.5, hjust=1), 
              panel.grid.major.x = element_blank(),
              axis.title.x = element_blank(),
              axis.text=element_text(size=14), 
              axis.title=element_text(size=16,face="bold"),
              legend.title=element_text(size=16,face="bold"),
              legend.text=element_text(size=14),
              legend.position = "top"
        )
      p
    }, 
    height = 400,
    width=800
    )
  
  output$transfers_by_generation_plot <- renderPlot(
    expr={
      
      my_data = in_range_transfer_data()
      top_researchers = as.character((head(transfer_data_summary(), n=7))$researcher)
      my_data$highlighted_researcher = as.character(my_data$researcher)
      my_data$highlighted_researcher[!my_data$researcher %in% top_researchers] = "Other"
      my_data$highlighted_researcher = factor(my_data$highlighted_researcher, levels=c(top_researchers, "Other"))
      
      okabe = c("#E69F00", "#56B4E9",  "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
      okabe = okabe[1:length(top_researchers)]
      okabe = c(okabe, "#999999")
      
      options(scipen = 999)
      
      p = ggplot(data = my_data, 
                 aes(x = date, y = generation, color=highlighted_researcher)
      ) + 
        theme_bw() +
        geom_point() + 
        xlab("Date") +
        ylab("Bacterial generations") +
        labs(color='Researcher') +
        scale_color_manual(values = okabe) +
        scale_y_continuous(label=comma, limits=c(0,100000), breaks=0:10*10000, expand = expansion(mult = c(0, 0))) +
        scale_x_date(limits=c(input$start_date, input$end_date), expand = expansion(mult = c(0, 0))) +
        theme(
          axis.text=element_text(size=14), 
          axis.title=element_text(size=16,face="bold"),
          legend.title=element_text(size=16,face="bold"),
          legend.text=element_text(size=14),
          legend.position = "top"
          )
      
     p
    }, 
    height = 400,
    width= 780
  )
  
  output$download_complete_csv <- downloadHandler(
    filename = paste0("LTEE-Ecoli-transfer-complete-data ", Sys.time(), ".csv"),
    content = function(file) {
      #could clean HTML columns out here
      write_csv(in_range_transfer_data(), file)
    },
    contentType = "text/csv"
  )
  
  output$download_summary_csv <- downloadHandler(
    filename = paste0("LTEE-Ecoli-transfer-summary-data ", Sys.time(), ".csv"),
    content = function(file) {
      #could clean HTML columns out here
      write_csv(transfer_data_summary(), file)
    },
    contentType = "text/csv"
  )
  
})
  


# Run the application 
shinyApp(ui = ui, server = server)

