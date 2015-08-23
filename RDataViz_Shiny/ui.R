library(shiny)
library(ggvis)



shinyUI(pageWithSidebar(
        div(),
        sidebarPanel(
            
            
            ###########################
            ## Sidebar for file chooser 
            ###########################
            
            conditionalPanel(
                condition = "input.tabcond == 1",
                strong("Choose a file to visualize from your",
                    "local drives by clicking on the button.",
                    "If you need a file, try:"),
                code("data(iris)",style = "color:blue"),
                br(),
                code("write.csv(iris, file='iris.csv', row.names=FALSE)",style = "color:blue"),
                tags$hr(),
                #        fileInput('datfile', '')
                fileInput('datfile', 'Choose a file to upload.',
                    accept = c(
                        'text/csv',
                        'text/comma-separated-values',
                        'text/tab-separated-values',
                        'text/plain',
                        '.csv',
                        '.tsv'
                    )
                ),
                tags$hr(),
                strong("Choose whether or not your data has a header row."),
                checkboxInput('header', 'Header', TRUE),

                tags$hr(),
                radioButtons('sep', 'Choose the delimiter.',
                    c(Comma=',',
                        Semicolon=';',
                        Tab='\t'),
                    ','),
                tags$hr(),
                
                radioButtons('quote', 'Choose the types of quotes.',
                    c(None='',
                        'Double Quote'='"',
                        'Single Quote'="'"),
                    '"')
            
            
            ),
            
            
            ###############################
            ## Sidebar for data table 
            ###############################
            conditionalPanel(
                condition = "(input.tabcond == 2 || input.tabcond == 3) && output.fileUploaded",
                strong("Choose the columns to include in the table."),
                uiOutput("choose_columns")
            ) ,
            
            
            
            ###############################
            ## Sidebar for heatmap 
            ###############################
            conditionalPanel(
                condition = "input.tabcond == 3 && output.fileUploaded",
                #        htmlOutput("choose_columns")
                tags$hr(),
                strong("Do you want to dummy code (one-hot encode)?"),
                checkboxInput("dummybox", label = "Yes", value = FALSE),
                tags$hr(),
                numericInput('headobs', 'Sample size (randomized):', 50)
            ), 
            
            
            
            ###############################
            ## Sidebar for distribution plots 
            ###############################
            conditionalPanel(
                condition = "input.tabcond == 4 && output.fileUploaded",
                strong("Choose the column to plot."),
                htmlOutput("pick_a_column"),
                tags$hr(),
                numericInput('distobs', 'Sample size (randomized):', 1000),
                tags$hr(),
                sliderInput("binsize", "Histogram bin size", .1, 20, value=1)
            )
        
        
        
        
        ),
        
        
        
        mainPanel(
            
            
            tabsetPanel(
                id = "tabcond",
                
                
                ###############################
                ## File chooser
                ###############################
                
                tabPanel("Choose File",
                    
                    ## Display text if file uploaded 
                    conditionalPanel(
                        condition = "!output.fileUploaded",
                        br(),
                        h2("Upload a file.")),
                    
                    conditionalPanel(
                        condition = "output.fileUploaded",
                        h2("Summary of Dataset:"),
                        br(),
                        verbatimTextOutput("summary")),
                    
                    value=1),
                
                
                
                ###############################
                ## Table
                ###############################
                
                tabPanel("Data Table", 
                    
                    ## Display text if file uploaded 
                    conditionalPanel(
                        condition = "!output.fileUploaded",
                        br(),
                        h2("Upload a file on the File Chooser tab.")),
                    
                    conditionalPanel(
                        condition = "output.fileUploaded",
                        br(),
                        dataTableOutput(outputId="table")),
                    
                    value=2) ,
                
                
                
                ###############################
                ## Heatmap
                ###############################
                
                tabPanel("Heatmap", 
                    
                    ## Display text if file uploaded 
                    conditionalPanel(
                        condition = "!output.fileUploaded",
                        br(),
                        h2("Upload a file on the File Chooser tab.")),
                    
                    conditionalPanel(
                        condition = "output.fileUploaded",
                        br(),
                        strong("Note: adjust size of plot (lower right corner) to fix axes if not lining up..."),
                        br(),
                        ggvisOutput("heatplot")), 
                    
                    value=3) ,
                
                
                
                ###############################
                ## Data distribution plots
                ###############################
                
                tabPanel("Distribution", 
                    
                    ## Display text if file uploaded 
                    conditionalPanel(
                        condition = "!output.fileUploaded",
                        br(),
                        h2("Upload a file on the File Chooser tab.")),
                    
                    conditionalPanel(
                        condition = "output.fileUploaded",
                        br(),
                        strong("Raw data plots. Note: color represents standard deviations from mean."),
                        br(),
                        ggvisOutput("rawplot"),
                        br(),
                        tags$hr(),
                        br(),
                        strong("Distribution of the data points."),
                        ggvisOutput("histplot")), 
                    
                    value=4)
            
            
            
            
            )
        
        
        )
    ))