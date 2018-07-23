# TIS
Threat Intelligence System is built using MongoDb as backend connected to a R shiny frontend.  
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
  
## Understanding the structure  
* **Backend**  
The backend scripts are inside the github/ folder and are run in a corntab using `sudo crontab -e` with the line  
`00 11 * * * /home/ubuntu/github/pull.sh && /home/ubuntu/github/filter.sh &&  python /home/ubuntu/github/mongo.py && /home/ubuntu/github/rename.sh`  
  * **pull.sh**  
  At 11 am daily as the cmd is executed daily (from cron) the script is a single line pulling the updated firehol repo from https://github.com/firehol/blocklist-ipsets.git  
  **Note:** I had to run a script to bypass firewall namely **auth.py** which has been run in background using tmux  
  * **filter.sh**  
  Each file in downloaded repository has some comment line, which will be removed through this script  
  * **mongo.py**  
  Puts all the logs into their seperate collections in mongodb in the **firehol** database
  * **rename.sh**  
  The pull.sh script downloads the repository with the name temp, so that filer.sh and mongo.py have a target directory. Once collections are updated, the temp directory is renamed with the format temp_ddmmyyyy where dd is date, mm is month yy is year, thus recording data for posterity.  
  An example for how it would come to look overtime  
  ![](https://github.com/akashrajr1/TIS/blob/master/db_setup.PNG?raw=true)
* **Frontend**  
The R shiny TIS can be run using `sudo Rscript app.R`  
Please chanege the host ip and the port number in app.R according to convenience  

### Others
Tmux is used here to create sessions and run scripts in the background.  
**Reference:**  
https://www.linkedin.com/pulse/how-i-run-days-long-scripts-without-breaking-them-arun-das/  
https://gist.github.com/MohamedAlaa/2961058
