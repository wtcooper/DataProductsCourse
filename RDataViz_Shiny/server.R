require(shiny)
require(dplyr)
require(ggvis)
require(Hmisc)
require(scales)
require(tidyr)


shinyServer(function(input, output, session) {
      #load the data when the user inputs a file
      
      
      ###############################
      ## File chooser
      ###############################
      
      
      getData <- reactive({
            infile <- input$datfile        
            if(is.null(infile))
              return(NULL)        
            d <- read.csv(infile$datapath, header = T)
            d        
          })
      
      
      output$fileUploaded <- reactive({
            return(!is.null(getData()))
          })
      
      
      outputOptions(output, 'fileUploaded', suspendWhenHidden=FALSE)
      
      
      ###############################
      ## Choose columns
      ###############################
      
      # Check boxes
      output$choose_columns <- renderUI({
            # If missing input, return to avoid error later in function
            if(is.null(input$datfile))
              return()
            
            # Get the data set with the appropriate name
            dat <- getData()
            colnames <- names(dat)
            
            # Create the checkboxes and select them all by default
            checkboxGroupInput("columns", "Choose columns:", 
                choices  = colnames,
                selected = colnames)
          })
      
      
      
      ###############################
      ## Pick single columns
      ###############################
      
# Check boxes
      output$pick_a_column <- renderUI({
            # If missing input, return to avoid error later in function
            if(is.null(input$datfile))
              return()
            
            # Get the data set with the appropriate name
            dat <- getData()
            
            # Remove any factor or character variables
            dat = dat[, !sapply(dat, is.factor)]
            dat = dat[, !sapply(dat, is.character)]
            
            colnames <- names(dat)
            
            selectInput("selectcol", "Choose a column (numeric only):", 
                choices = colnames)
            
          })
      
      
      
      ###############################
      ## Summary (Hmisc)
      ###############################
      
      ## Generate a summary of the dataset
      output$summary <- renderPrint({
            
            if(is.null(input$datfile))
              return()
            
            # Get the data set with the appropriate name
            dat <- getData()
            
#      if (is.null(input$columns) || !(input$columns %in% names(dat)))
#       return()
#      dat <- dat[, input$columns, drop = FALSE]
            
            describe(dat)
          })
      
      
      
      ###############################
      ## Table 
      ###############################
      
      # Filter data based on selections
      output$table <- renderDataTable({
            
            if(is.null(is.null(input$datfile)))
              return()
            
            # Get the data set with the appropriate name
            dat <- getData()
            
            if (is.null(input$columns) || !(input$columns %in% names(dat)))
              return()
            
            dat <- dat[, input$columns, drop = FALSE]
            
          })
      
      
      
      
      ###############################
      ## Heatmap plot
      ###############################
      
      ## Do up the heatmap - if add reactivity (e.g., dummies) then
      ##  default data returned must work with the call to ggvis (must return a plotDatLong)
      
      heatDat <- reactive({
            
            ## Set up a default plot to return 
            defPlot = data.frame(Variable=c("a","b"), obs=1:10, Value=rnorm(10)) %>% mutate(obs=as.factor(obs)) 
            
            
            
            if(is.null(is.null(input$datfile)))
              return(defPlot)
            
            # Get the data set with the appropriate name
            dat <- getData()
            
            if (is.null(input$columns) || !(input$columns %in% names(dat)))
              return(defPlot)
            if(is.null(input$headobs))
              return(defPlot)
            if(is.null(input$dummybox))
              return(defPlot)
            
            
            
            ## filter out the observations and others
            dat <- dat[, input$columns, drop = FALSE]
            
            
            datlen = length(dat[,1])
            
            faccols = names(dat[, sapply(dat, is.factor), drop=FALSE])
            
            ## Do dummy codes
            if (input$dummybox & length(faccols)>0){
              
              dummymat = NULL
              for (faccol in faccols){
                form = as.formula(paste("~",faccol, "-1"))
                dmat = as.data.frame(model.matrix(form, data=dat))
                names(dmat) = gsub(faccol, "", names(dmat))
                if(is.null(dummymat)) {
                  dummymat=dmat
                } else {
                  dummymat = cbind(dummymat,dmat)
                }
              }
              
              dat = cbind(dat, dummymat)
            } 
            
            ## Remove the factor columns
            dat = dat[, !sapply(dat, is.factor)]
            
            
            if (datlen > input$headobs) {
              dat = dat %>% sample_n(input$headobs) %>% data.frame()
            }
            
            dat = as.data.frame(apply(dat, 2, rescale))
            dat$obs = factor(length(dat[,1]):1, levels=as.character(length(dat[,1]):1))
            plotDatLong = dat %>% gather(Variable, Value, -obs) %>% filter(!is.na(Value))
            
          })
      
      heatDat %>% ggvis(~Variable, ~obs, fill=~Value) %>%
          layer_rects(width = band(), height = band()) %>%
          add_tooltip(function(data){
                paste0("Variable: ", data$Variable, "<br>", "Value: ",as.character(data$Value))
              }, "hover") %>%
          scale_nominal("x", padding = 0, points = FALSE) %>%
          scale_nominal("y", padding = 0, points = FALSE) %>% 
          set_options(height = 700, width=700) %>%  
#     add_axis("y", title = "") %>% 
#     add_axis("x", title = "") %>% #, properties = axis_props(
#         labels = list(angle = -45, align = "right"))) %>%
          bind_shiny("heatplot") #, "plot_ui")
      
      
      
      
#     data.frame(Variable=c("aaaaaaaaaaa","bbbbbbbbbbbbbbbbb"), obs=1:10, Value=rnorm(10)) %>% mutate(obs=as.factor(obs)) %>% 
#       ggvis(~Variable, ~obs, fill=~Value) %>%
#       layer_rects(width = band(), height = band()) %>%
#       add_tooltip(function(data){
#          paste0("Variable: ", data$Variable, "<br>", "Value: ",as.character(data$Value))
#         }, "hover") %>%
#       scale_nominal("x", padding = 0, points = FALSE) %>%
#       scale_nominal("y", padding = 0, points = FALSE) %>% 
#       set_options(width = 600, height = 700) %>%      
#       add_axis("y", title = "") %>% 
#           add_axis("x", title = "", properties = axis_props(
#         labels = list(angle = -45, align = "right")
#       ))
#   
      
      
      
      ###############################
      ## Heatmap plot
      ###############################
      
      ## Do up the heatmap - if add reactivity (e.g., dummies) then
      ##  default data returned must work with the call to ggvis (must return a plotDatLong)
      
      densDat <- reactive({
            
            ## Set up a default plot to return 
            defPlot = data.frame(Variable=c("a","b"), obs=1:10, Value=rnorm(10)) %>% mutate(obs=as.factor(obs)) 
            
            
            if(is.null(is.null(input$datfile)))
              return(defPlot)
            
            # Get the data set with the appropriate name
            dat <- getData()
            # Remove any factor or character variables
            dat = dat[, !sapply(dat, is.factor)]
            dat = dat[, !sapply(dat, is.character)]
            
            
            
            if (is.null(input$selectcol) || !(input$selectcol %in% names(dat)))
              return(defPlot)
            
            ## filter out the observations and others
            dat <- dat[, input$columns, drop = FALSE]
            
            
            dat = as.data.frame(apply(dat, 2, rescale))
            dat$obs = factor(length(dat[,1]):1, levels=as.character(length(dat[,1]):1))
            plotDatLong = dat %>% gather(Variable, Value, -obs) %>% filter(!is.na(Value))
            
          })
      
      heatDat %>% ggvis(~Variable, ~obs, fill=~Value) %>%
          layer_rects(width = band(), height = band()) %>%
          add_tooltip(function(data){
                paste0("Variable: ", data$Variable, "<br>", "Value: ",as.character(data$Value))
              }, "hover") %>%
          scale_nominal("x", padding = 0, points = FALSE) %>%
          scale_nominal("y", padding = 0, points = FALSE) %>% 
          set_options(height = 700, width=700) %>%  
#     add_axis("y", title = "") %>% 
#     add_axis("x", title = "") %>% #, properties = axis_props(
#         labels = list(angle = -45, align = "right"))) %>%
          bind_shiny("heatplot") #, "plot_ui")
      
      
      
      
      
      # Return to R session after closing browser window
      session$onSessionEnded(function() { stopApp() })
      
    })