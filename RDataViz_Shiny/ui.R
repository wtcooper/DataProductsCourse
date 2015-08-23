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
				br(),
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
				tags$hr(),
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
				strong("Do you want to randomize a sample?"),
				checkboxInput("randbox", label = "Yes", value = FALSE),
                numericInput('headobs', 'Sample size (randomized):', 75)
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
                    
                    value=4),
            
            
			
			###############################
			## Documentation
			###############################
			
			tabPanel("Documentation", 
					
					## Display text if file uploaded 
							h3("Overview"),
							p("This app provides a simple interactive data exploration.  Choose a dataset saved to disc and select different tabs at the top of the page to view the data in various ways.  All figures use R's ggvis, so you can automatically rescale the size (triangle in lower right corner of plot), and save the plots (cog in upper right corner of plot)."),
							tags$hr(),
							strong("Steps to run:"),
							br(),
							p("1) Click on 'Choose File' tab, and click on 'Choose File' button on left side panel.  Choose a dataset to upload, selecting the correct parameters in the side panel, e.g., whether it has a header row, comma/tab/semicolon seperated, and what type of quotes are used in the file."),
							br(),
							p("2) Click on the other tabs (Data Table, Heatmap, and Distribution) to view the data both as a sortable table (Data Table) and in different plot types."),
							br(),
							br(),
							tags$hr(),
							h3("Notes on Usage"),
							strong("Data Table"),
							p("This is a simple table of the data, the provides quick sorts and searches of the data."),
							br(),
							br(),
							strong("Heatmap"),
							p("Viewing the data as a heatmap is a quick way to visually inspect correlations between the data.  The sidebar panel allows you to randomly select a subset of columns, dummy code character/factor/class variables (what computer science majors call one-hot encoding), and randomly select a subset of observations so the figure is readable.  Data are scaled from 0-1 to compare among columns."),
							br(),
							p("Note 1: The figure is an R ggvis plot, so you can hover over the figure to see the value."),
							p("Note 2: The axes do not line up correctly for some likely logical reason, but you can drag the small re-size triangle in the lower right of the plot to fix the axes one it re-draws."),
							br(),
							br(),
							strong("Distribution"),
							p("The distribution tab provides two plots for any given variable you want to visualize, just select the variable in the side panel to view that data.  Note that you can also choose a subset of observations that are randomized.  Seeing all data at once (setting the sample high) will show in the original order."),
							br(),
							p("(a) The raw data (value on the y-axis, observation # on the x-axis) to visualize the range of the data and any potential outliers.  The color of the points represents the standard deviations from the mean, where some use 3 or 4 standard deviations as a rough gauge of data outliers."),
							br(),
							p("(b) A histogram of the data, with an adjustable slider bar in the side-panel to change the bin size."),
							br(),
							br(),
							tags$hr(),
							h3("Download Source Files"),
							p("The server.r and ui.r files to run the shiny app can be downloaded from:"),
							br(),
							p("https://github.com/wtcooper/DataProductsCourse/blob/master/RDataViz_Shiny"),
							
							 
					
					value=5)
            
            
            )
        
        
        )
    ))