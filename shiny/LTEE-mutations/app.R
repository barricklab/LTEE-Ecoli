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
mutator_status_list = c("non-mutator", "point-mutator", "IS-mutator")

mutation_category_list = c( "SNP nonsynonymous", 
                         "SNP synonymous", 
                         "SNP intergenic", 
                         "SNP nonsense",
                         "SNP noncoding",
                         "SNP pseudogene",
                         "small indel",
                         "mobile element insertion",
                         "large deletion",
                         "large amplification",
                         "large substitution",
                         "inversion",
                         "gene conversion" 
                         )

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
  fluidRow(
    column(1,actionButton("reset_input", label = "Reset")),
    column(1,downloadButton("download_csv", label = "Download CSV"))
  ),
  hr(),
  dataTableOutput("mutation_table")
  
))

num_mutations_shown = 0


filter_group_data <- function(input) {
  #Filter data
  sanitized_mutation_category = input$mutation_category
  sanitized_mutation_category = tolower(sanitized_mutation_category)
  sanitized_mutation_category = gsub(" ", "_", sanitized_mutation_category)
  
  print(input$generation_range)
  print(input$selected_gene)
  filtered_data = data %>% 
    filter(time >= input$generation_range[1]) %>% 
    filter(time <= input$generation_range[2]) %>% 
    filter(mutation_category %in% sanitized_mutation_category ) %>% 
    filter(mutator_status %in% input$mutator_status ) %>% 
    filter(population %in% input$selected_populations )
    
  if (input$selected_gene!="") {
    filtered_data = filtered_data %>%
      filter(grepl(input$selected_gene, gene_list, ignore.case=T))
  }
  
  filtered_data = filtered_data %>% arrange(population, time, strain)
  
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
      select(-population, -time, -strain, -clone, -mutator_status, -full_mutation_definition) %>%
      rename(population=populations, time=times, strain = strains)
    
    filtered_data = final_mutation_data
  }
  
  return(filtered_data)
}

server <- shinyServer(function(input, output) {
  
  
  output$mutation_table <- renderDataTable(
    {
      
      filtered_data = filter_group_data(input)
      
      #Finally rename columns and select the ones we show
      filtered_data %>%
        select(population, time, strain, type, html_position, html_mutation, html_mutation_annotation, html_gene_name, html_gene_product) %>%
        rename(pop=population, generation=time, position = html_position, mutation = html_mutation, annotation = html_mutation_annotation, gene = html_gene_name, product = html_gene_product)
    }, 
    options = list(  ),
    escape = FALSE,
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
          
          column(9,
                 selectInput("mutation_category", 
                                    label = "Mutation categories shown",
                                    choices = mutation_category_list,
                                    selected = mutation_category_list,
                                    multiple=T,
                                    width="100%"
                 )
          )
        ),
        fluidRow(  
          
          column(9,
                 checkboxGroupInput("mutator_status", 
                                    label = "Mutator status",
                                    choices = mutator_status_list,
                                    selected = mutator_status_list,
                                    inline = T
                 )
          )
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
  
  
  output$download_csv <- downloadHandler(
    filename = paste0("LTEE-Ecoli-data ", Sys.time(), ".csv"),
    content = function(file) {
      #could clean HTML columns out here
      write.csv(filter_group_data(input), file)
    },
    contentType = "text/csv"
  )
  
})

# Run the application 
shinyApp(ui = ui, server = server)

