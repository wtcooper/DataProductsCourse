library(ggvis)
library(shiny)



shinyUI(pageWithSidebar(
    div(),
    sidebarPanel(
      
      
      ###########################
      ## Sidebar for file chooser 
      ###########################
      
      conditionalPanel(
        condition = "input.tabcond == 1",
        
#        fileInput('datfile', '')
        fileInput('datfile', 'Choose file to upload',
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
        checkboxInput('header', 'Header', TRUE),
        radioButtons('sep', 'Separator',
          c(Comma=',',
            Semicolon=';',
            Tab='\t'),
          ','),
        radioButtons('quote', 'Quote',
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
        uiOutput("choose_columns")
      ) ,
      
      
      
      ###############################
      ## Sidebar for heatmap 
      ###############################
      conditionalPanel(
        condition = "input.tabcond == 3 && output.fileUploaded",
#        htmlOutput("choose_columns")
        br(),
        checkboxInput("dummybox", label = "Dummy code factors?", value = FALSE),
        br(),
        numericInput('headobs', 'Sample size:', 50)
      ), 
      
      
      
      ###############################
      ## Sidebar for distribution plots 
      ###############################
      conditionalPanel(
          condition = "input.tabcond == 4 && output.fileUploaded",
        htmlOutput("pick_a_column")
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
            h1("Upload a file.")),
          
          conditionalPanel(
            condition = "output.fileUploaded",
            h1("Summary of Dataset:"),
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
            h1("Upload a file on the File Chooser tab.")),
          
          conditionalPanel(
            condition = "output.fileUploaded",
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
            h1("Upload a file on the File Chooser tab.")),
          
          conditionalPanel(
            condition = "output.fileUploaded",
            h5("Note: adjust size of plot (lower right corner) to fix axes if not lining up..."),
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
              h1("Upload a file on the File Chooser tab.")),
          
          conditionalPanel(
              condition = "output.fileUploaded",
              h4("Density plots")),
#              br(),
#              ggvisOutput("heatplot")), 
          
          value=4)
      
      
      
      
      )
    
    
    )
  ))