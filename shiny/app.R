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
library(dplyr)

#load and clean data

data <- read.table("LTEE-clone-curated.tsv", header=T, sep="\t",comment.char = "")
data$time = as.numeric(as.character(data$time))
generation_slider_max = max(data$time)

population_list = sort(unique(as.character(data$population)))

# Define UI for application that draws a histogram
ui <- shinyUI(fluidPage(
  
  tags$head(
    tags$style(HTML("
                    .mutation_in_codon {color:red; text-decoration : underline;}
                    .snp_type_synonymous{color:green;}
                    .snp_type_nonsynonymous{color:blue;}
                    .snp_type_nonsense{color:red;}
                    ")
               )
  ),
  
  # Application title
  titlePanel("LTEE Mutations"),
  
  uiOutput('resetable_input'),
  actionButton("reset_input", "Reset"),
  hr(),
  dataTableOutput("mutation_table")
  
))

num_mutations_shown = 0


server <- shinyServer(function(input, output) {
  
  
  output$mutation_table <- renderDataTable({
    
    #Filter data
    
    filtered_data = data %>% 
      filter(time >= input$generation_range[1], time <= input$generation_range[2]) %>% 
      filter(population %in% input$selected_populations ) %>% 
      filter(grepl(input$selected_gene, gene_list, ignore.case=T)) %>%
      arrange(population, time, strain)
    
    if (input$selected_strain != "") {
      filtered_data = filtered_data %>% 
        filter(toupper(input$selected_strain) == toupper(strain))
    }
    
    # Grouping data
    if (input$row_grouping == "per mutation") {
      
      merged_mutation_data = filtered_data %>%
        mutate(full_mutation_definition = paste(type, html_position, html_mutation))
      
      collapsed_mutation_data = merged_mutation_data %>% 
        group_by(full_mutation_definition) %>% 
        summarise(num=n(), 
                  populations=paste(population, collapse="<br>"),
                  times=paste(time, collapse="<br>"),
                  strains=paste(strain, collapse="<br>"),
                  num=n()
                  )
      
      merged_mutation_data  = merged_mutation_data %>% distinct(full_mutation_definition, .keep_all = TRUE)
      
      final_mutation_data = merged_mutation_data %>% 
        left_join(collapsed_mutation_data, by = c("full_mutation_definition")) %>%
        select(-population, -time, -strain) %>%
        rename(population=populations, time=times, strain = strains)
      
      filtered_data = final_mutation_data
    }
    
    ### Save this value
    num_mutations_shown <<- nrow(filtered_data)
    
    
    #Finally rename columns and select the ones we show
    
    filtered_data %>%
      select(population, time, strain, type, html_position, html_mutation, html_mutation_annotation, html_gene_name, html_gene_product) %>%
      rename(pop=population, generation=time, position = html_position, mutation = html_mutation, annotation = html_mutation_annotation, gene = html_gene_name, product = html_gene_product)
  }, 
  
  escape=FALSE, 
  options = list(dom = 'lptp', 
                 pageLength = 50,
                 lengthMenu = c(25, 50, 100, 200, 500, 1000)
               # , order = list(list(1, 'asc'), list(2, 'asc'), list(3, 'asc'))
  ),
  selection = 'none'
  )
  
  output$resetable_input <- renderUI({
    times <- input$reset_input
    div(id=letters[(times %% length(letters)) + 1],
        checkboxGroupInput("selected_populations", 
                           label = "Populations",
                           choices = population_list,
                           selected = population_list,
                           inline=T
        ),
        fluidRow(
          column(3,
                 sliderInput("generation_range", 
                             label = "Generations",
                             min = 0, 
                             max = generation_slider_max, 
                             value = c(0, generation_slider_max), 
                             step = 500
                 )
          ),
          column(2,
                 textInput("selected_gene", 
                           label = "Gene",
                           placeholder = "search within"
                 )
          ),
                 column(2,
                        textInput("selected_strain", 
                                  label = "Strain",
                                  value = "",
                                  placeholder = "exact match"
                        )
          ),
          column(2,
                 selectInput("row_grouping", 
                           label = "Grouping",
                           choices = c(
                             "per genome",
                             "per mutation"
                           #  "per event"
                             ),
                           selected = "per genome"
                 )
          )
        )
    )
  })
  
})

# Run the application 
shinyApp(ui = ui, server = server)

