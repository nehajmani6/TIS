# TIS
Threat Intelligence System is a built using a MongoDb database connected to a R shiny frontend.  
## Setting up the R environment 
- First install R using these commands
```
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb [arch=amd64,i386] https://cran.rstudio.com/bin/linux/ubuntu xenial/'
sudo apt-get update
sudo apt-get install r-base
```
Start R using `sudo -i R`. Please look at the documentation at https://www.digitalocean.com/community/tutorials/how-to-install-r-on-ubuntu-16-04-2 for more information  
- Installing libraries
  * **Shiny**  
  After running R please note that the version of R is ≥ 3.0.2 for compatibility purposes.  
  Install the package using `install.packages("shiny")` and to verify, we can load the package using `library(shiny)`.   
  No error prompt means a successful installation
  * **Shiny Dashboard**  
  Use `install.packages("shinydashboard")`  
  * **Ggplot2**  
  Use `install.packages("ggplot2")`  
  * **Raster**  
  Use `install.packages("raster")`  
  * **Leaflet**  
  Use `install.packages("leaflet")`
  * **Rgeolocate**
  Run this cmd `sudo apt-get install libcurl4-openssl-dev libssl-dev`  
  Then in the R console `install.packages("rgeolocate")`
  * **Mongolite**  
  Run this cmd `sudo apt-get install libssl-dev libsasl2-dev`
  Then in the R concole `install.packages("mongolite")`
  
 
