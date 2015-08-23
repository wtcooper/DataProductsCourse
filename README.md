# DataProductsCourse
Project material for the Coursera Data Products course (Shiny app and html5 presentation).
<br />
<br />


## Shiny App

The shiny app is a simple data explorer, built as a tutorial to learn shiny.  The source files (server.r and ui.r) 
are in the RDataViz_Shiny folder, and the app is hosted at https://wtcooper.shinyapps.io/RDataViz.  This is very similar
to the R package I put together (https://github.com/wtcooper/vizrd) but the app uses ggvis instead of ggplot.  The vizrd package
is designed to launch from an interactive R session where you want to quickly view the data with a few canned plots and 
potentially save the plots as a high res png through ggplot (ggvis png save is poor quality).  Otherwise they provide nearly the same
functionality, and maybe i'll switch to ggvis once it catches up to ggplot functionality.  
<br />
<br />

## Presentation Deck with HTML5 

This is a rough presentation, and can be viewd at http://wtcooper.github.io/DataProductsCourse/RDataViz.html.  
It was created through RStudio's presentation option, with default behavior since I didn't get into any specifics on
formatting.  I attempted to use slidify for more customization, but found it to be rough around the edges when working
on a Windoze box (too much googling to get it behaving).  

