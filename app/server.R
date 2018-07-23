library(shiny)
require(shinydashboard)
library(ggplot2)
library(raster)
library(rgeolocate)
library(mongolite)
library(leaflet)

op <- providerTileOptions(minZoom = 2, maxZoom = 10)
world_display<-leaflet()
world_display<-addProviderTiles(world_display,provider="CartoDB.DarkMatter",options=op)

blockchain_display<-leaflet()
blockchain_display<-addProviderTiles(blockchain_display,provider="CartoDB.DarkMatter",options=op)

malware_display<-leaflet()
malware_display<-addMiniMap(malware_display,position="bottomleft",tiles = "Stamen.Toner",toggleDisplay = TRUE)
malware_display<-addProviderTiles(malware_display,provider="CartoDB.DarkMatter",options=op,group="Dark")

builder_display<-leaflet()
builder_display<-addProviderTiles(builder_display,provider="CartoDB.DarkMatter",options=op,group="Dark")
builder_display<-addProviderTiles(builder_display,provider="Stamen.Toner",options=op,group="Toner")
builder_display<-addProviderTiles(builder_display,provider="Stamen.Watercolor",options=op,group="Watercolor")
builder_display<-addProviderTiles(builder_display,provider="Esri.WorldTerrain",options=op,group="Esri")

botnet_display<-leaflet()
botnet_display<-addProviderTiles(botnet_display,provider="CartoDB.DarkMatter",options=op,group="Dark")

blacklist_display<-leaflet()
blacklist_display<-addProviderTiles(blacklist_display,provider="CartoDB.DarkMatter",options=op,group="Dark")


india<- getData('GADM', country='India',level=0)
op <- providerTileOptions(minZoom = 5, maxZoom = 10, center = c(20.59,78.96))
india_display<-leaflet()
# india_display<-addPolygons(india_display ,data=india,weight=2,fillColor = "white", fillOpacity = 0)
# india_display<-addMiniMap(india_display)
india_display<-addProviderTiles(india_display,provider="CartoDB.DarkMatter",options=op,group="Dark")
india_display<-addProviderTiles(india_display,provider="Stamen.Toner",options=op,group="Toner")
india_display<-setView(india_display,78.9629,20.5937,zoom = 5)




year<-format(Sys.Date(),"%Y")
month<-format(Sys.Date(),"%m")
day<- format(Sys.Date(),"%d")
date<-paste0(year,"-",month,"-",day)
cnst<-24*60*60

dur<- c("Today","Yesterday","This Week","This Month","Last 6 Months","This Year")


getData <- function(collection,date){
    m <- mongo(collection = collection, db ="firehol")
    data <- m$find(paste0('{"date" : {"$gte" : {"$date": "',date,"T00:00:00Z",'"}}}'))   
    results<-maxmind(data[3][[1]],"GeoLite2-City.mmdb",c("latitude","longitude","country_code","city_name","region_name"))
    results<-na.omit(results)
    results<-results[results$country_code=='IN',]
    return(results[-3])
}

getData1 <- function(collection,date){
    m <- mongo(collection = collection, db ="firehol")
    data <- m$find(paste0('{"date" : {"$gte" : {"$date": "',date,"T00:00:00Z",'"}}}'))   
    results<-maxmind(data[3][[1]],"GeoLite2-City.mmdb",c("latitude","longitude","city_name","country_name"))
    results<-na.omit(results)
    return(results)
}


checkTime <- function(mul){
  print("HERE")
  hr<-as.numeric(substr(as.character(Sys.time()),12,13))
  min<-as.numeric(substr(as.character(Sys.time()),15,16))

  if (mul==0 && hr<=12 && min<=30)
    return(1)
  else
    return(mul)
}

checkIp <- function(collection,ip){
	m <- mongo(collection = collection, db ="firehol")
	c <- m$count(paste0('{"ip":"',ip,'"}'))
	if(c==0)
		return(0)
	else
		return(1)
}

#WORLD DASHBOARD

function(input,output){

  world_date <- reactive({
    k=1

    for (i in 1:6){
      if (dur[i]==input$world_duration)
        k=i
    }

    mul <- c(0,1,7,30,180,365)
    print(mul[k])
    multiply <- checkTime(mul[k])
    print(multiply)
    query_date<-as.character(as.POSIXct(date)-cnst*multiply)
    query_date
  })

  world_data <- reactive(getData1("nt_ssh_7d",world_date()))
  world_data1 <- reactive(getData1("cleanmx_phishing",world_date()))
  world_data2 <- reactive(getData1("firehol_level1",world_date()))
  world_data3 <- reactive(getData1("cybercrime",world_date()))
  world_data4 <- reactive(getData1("bi_apache_0_1d",world_date()))

  world_map_data <- reactive({
    temp <- world_data()
    temp1<- world_data1()
    temp2<- world_data2() 
    temp3<- world_data3()
    temp4<- world_data4()

    world_display<-addCircles(world_display,lng = temp$longitude,  lat = temp$latitude, options=op,color="white",popup=as.character(temp$city_name),group="nt_ssh_7d")    #white
    world_display<-addCircles(world_display,lng = temp1$longitude, lat = temp1$latitude,options=op,color="#02C7A7",popup=as.character(temp1$city_name),group="cleanmx_phishing") #blue
    world_display<-addCircles(world_display,lng = temp2$longitude, lat = temp2$latitude,options=op,color="#048F04",popup=as.character(temp2$city_name),group="firehol_level1") #green
    world_display<-addCircles(world_display,lng = temp3$longitude, lat = temp3$latitude,options=op,color="#870487",popup=as.character(temp3$city_name),group="cybercrime") #pink
    world_display<-addCircles(world_display,lng = temp4$longitude, lat = temp4$latitude,options=op,color="#F91708",popup=as.character(temp4$city_name),group="bi_apache_0_1d") #red

    # world_display<-addLayersControl(overlayGroups = c("nt_ssh_7d","cleanmx_phishing","firehol_level1","cybercrime","bi_apache_0_1d","firehol_level3"))
    names<- c("nt_ssh_7d","cleanmx_phishing","firehol_level1","cybercrime","bi_apache_0_1d")

    world_display<-addLayersControl(
      world_display,
      overlayGroups = names,
      options = layersControlOptions(collapsed = FALSE)
    )

    world_display<-addLegend(world_display,position="bottomright",colors=c("white","#02C7A7","#048F04","#870487","#F91708"),labels= names)

    world_display
    })

  output$world_map <- renderLeaflet({world_map_data()})

  world_all_data <- reactive({
    c(unlist(world_data()[4]),unlist(world_data1()[4]),unlist(world_data2()[4]),unlist(world_data3()[4]),unlist(world_data4()[4]))
    })

  world_table_data <- reactive({
    p<- world_all_data()
    k<-sort(table(p),decreasing=TRUE) 
    k
    })

  output$world_counter <- renderValueBox({
    d<- world_all_data()
    n<- length(unlist(d))
    valueBox(
      formatC(n, format="d", big.mark=',')
      ,paste('Total Attacks')
      ,icon = icon("stats",lib='glyphicon')
      ,color = "aqua")
  })

  output$world_highest <- renderValueBox({
    d<-world_table_data()
    valueBox(
      formatC(d[1][[1]], format="d", big.mark=',')
      ,paste('Highest Attacked: ',names(d))
      ,icon = icon("stats",lib='glyphicon')
      ,color = "green")
  })

  output$world_pie <- renderPlot({
    temp<-world_table_data()[1:13]
    par(bg="#212840",fg="#8D9CCC",col="#8D9CCC",col.axis="#8D9CCC",col.lab="#8D9CCC",col.main="#8D9CCC",col.sub="#8D9CCC")
    pie(temp,names(temp),radius= 1,main="Country %",col=rainbow(length(temp)))
    legend<-legend("topright", names(temp), cex=0.8, fill=rainbow(length(temp)))
    })  

  output$world_histo <- renderPlot({
    par(bg="#212840",fg="#8D9CCC",col="#8D9CCC",col.axis="#8D9CCC",col.lab="#8D9CCC",col.main="#8D9CCC",col.sub="#8D9CCC")
  	barplot(world_table_data()[1:5],xlab = "Countries", ylab="Attacks", col = "#4286f4")
  	})




#	INDIA DASHBOARD
#

  india_date <- reactive({
    k=1

    for (i in 1:6){
      if (dur[i]==input$india_duration)
        k=i
    }

    mul <- c(0,1,7,30,180,365)
    multiply <- checkTime(mul[k])

    query_date<-as.character(as.POSIXct(date)-cnst*multiply)
    query_date
  })

  india_data <- reactive(getData("nt_ssh_7d",india_date()))
  india_data1 <- reactive(getData("cleanmx_phishing",india_date()))
  india_data2 <- reactive(getData("firehol_level1",india_date()))
  india_data3 <- reactive(getData("cybercrime",india_date()))
  india_data4 <- reactive(getData("bi_apache_0_1d",india_date()))
  india_data5 <- reactive(getData("firehol_level3",india_date()))

  india_map_data <- reactive({
    temp <- india_data()
    temp1<- india_data1()
    temp2<- india_data2() 
    temp3<- india_data3()
    temp4<- india_data4()
    temp5<- india_data5()

    india_display<-addCircles(india_display,lng = temp$longitude,  lat = temp$latitude, options=op,color="white",popup=as.character(temp$city_name),group="nt_ssh_7d")    #white
    india_display<-addCircles(india_display,lng = temp1$longitude, lat = temp1$latitude,options=op,color="#02C7A7",popup=as.character(temp1$city_name),group="cleanmx_phishing") #blue
    india_display<-addCircles(india_display,lng = temp2$longitude, lat = temp2$latitude,options=op,color="#048F04",popup=as.character(temp2$city_name),group="firehol_level1") #green
    india_display<-addCircles(india_display,lng = temp3$longitude, lat = temp3$latitude,options=op,color="#870487",popup=as.character(temp3$city_name),group="cybercrime") #pink
    india_display<-addCircles(india_display,lng = temp4$longitude, lat = temp4$latitude,options=op,color="#F91708",popup=as.character(temp4$city_name),group="bi_apache_0_1d") #red
    india_display<-addCircles(india_display,lng = temp5$longitude, lat = temp5$latitude,options=op,color="#AAD51A",popup=as.character(temp5$city_name),group="firehol_level3") #yellow

    # india_display<-addLayersControl(overlayGroups = c("nt_ssh_7d","cleanmx_phishing","firehol_level1","cybercrime","bi_apache_0_1d","firehol_level3"))
    names<- c("nt_ssh_7d","cleanmx_phishing","firehol_level1","cybercrime","bi_apache_0_1d","firehol_level3")

    india_display<-addLayersControl(
      india_display,
      baseGroups = c("Dark","Toner"),
      overlayGroups = names,
      options = layersControlOptions(collapsed = FALSE)
    )

    india_display<-addLegend(india_display,position="bottomright",colors=c("white","#02C7A7","#048F04","#870487","#F91708","#AAD51A"),labels= names)

    india_display
    })

  output$india_map <- renderLeaflet({india_map_data()})

  india_all_data <- reactive({
    c(unlist(india_data()[3]),unlist(india_data1()[3]),unlist(india_data2()[3]),unlist(india_data3()[3]),unlist(india_data4()[3]),unlist(india_data5()[3]))
    })

  india_table_data <- reactive({
    p<- india_all_data()
    k<-sort(table(p),decreasing=TRUE) 
    k
    })

  output$india_counter <- renderValueBox({
    d<- india_all_data()
    n<- length(unlist(d))
    valueBox(
      formatC(n, format="d", big.mark=',')
      ,paste('Total Attacks')
      ,icon = icon("stats",lib='glyphicon')
      ,color = "aqua")
  })


  output$india_highest <- renderValueBox({
    d<-india_table_data()
    valueBox(
      formatC(d[1][[1]], format="d", big.mark=',')
      ,paste('Highest Attacked: ',names(d))
      ,icon = icon("stats",lib='glyphicon')
      ,color = "green")
  })

  output$india_states <- renderPlot({
  	states<- c(unlist(india_data()[4]),unlist(india_data1()[4]),unlist(india_data2()[4]),unlist(india_data3()[4]),unlist(india_data4()[4]),unlist(india_data5()[4]))
  	table <- sort(table(states),decreasing=TRUE)
  	temp <- table[1:5]
    par(bg="#212840",fg="#8D9CCC",col="#8D9CCC",col.axis="#8D9CCC",col.lab="#8D9CCC",col.main="#8D9CCC",col.sub="#8D9CCC")
  	pie(temp,names(temp),radius= 1,col=rainbow(length(temp)))
  	legend<-legend("topright", names(temp), cex=0.8, fill=rainbow(length(temp)))
  })

  output$india_cities <- renderPlot({
  	cities<- c(unlist(india_data()[3]),unlist(india_data1()[3]),unlist(india_data2()[3]),unlist(india_data3()[3]),unlist(india_data4()[3]),unlist(india_data5()[3]))
  	table <- sort(table(cities),decreasing=TRUE)
  	temp <- table[1:10]
    par(bg="#212840",fg="#8D9CCC",col="#8D9CCC",col.axis="#8D9CCC",col.lab="#8D9CCC",col.main="#8D9CCC",col.sub="#8D9CCC")
  	pie(temp,names(temp),radius= 1,col=rainbow(length(temp)))
  	legend<-legend("topright", names(temp), cex=0.8, fill=rainbow(length(temp)))
  })


  #MALWARE DASHBOARD
  #

    malware_date <- reactive({
      k=1

      for (i in 1:6){
        if (dur[i]==input$malware_duration)
          k=i
      }

      mul <- c(0,1,7,30,180,365)
      multiply <- checkTime(mul[k])

      query_date<-as.character(as.POSIXct(date)-cnst*multiply)
      query_date
      })

    malware_data <- reactive(getData1("nt_malware_dns",malware_date()))
    malware_data1 <- reactive(getData1("nt_malware_http",malware_date()))
    malware_data2 <- reactive(getData1("nt_malware_irc",malware_date()))

    malware_map_data <- reactive({
      temp <- malware_data()
      temp1<- malware_data1()
      temp2<- malware_data2() 

      malware_display<-addCircles(malware_display,lng = temp$longitude,  lat = temp$latitude, options=op,color="#870487",popup=as.character(paste0(temp$city_name,", ",temp$country_name)),group="nt_malware_dns")    #pink
      malware_display<-addCircles(malware_display,lng = temp1$longitude, lat = temp1$latitude,options=op,color="#02C7A7",popup=as.character(paste0(temp1$city_name,", ",temp1$country_name)),group="nt_malware_http") #blue
      malware_display<-addCircles(malware_display,lng = temp2$longitude, lat = temp2$latitude,options=op,color="#048F04",popup=as.character(paste0(temp2$city_name,", ",temp2$country_name)),group="nt_malware_irc") #green
      # malware_display<-addLayersControl(overlayGroups = c("nt_ssh_7d","cleanmx_phishing","firehol_level1","cybercrime","bi_apache_0_1d","firehol_level3"))
      names<- c("nt_malware_dns","nt_malware_http","nt_malware_irc")

      malware_display<-addLayersControl(
        malware_display,
        overlayGroups = names,
        options = layersControlOptions(collapsed = FALSE)
      )

      malware_display<-addLegend(malware_display,position="bottomright",colors=c("#870487","#02C7A7","#048F04"),labels= names)

      malware_display
      })

  output$malware_map <- renderLeaflet({malware_map_data()})

  malware_all_data <- reactive({
    c(unlist(malware_data()[4]),unlist(malware_data1()[4]),unlist(malware_data2()[4]))
    })

  malware_table_data <- reactive({
    p<- malware_all_data()
    k<-sort(table(p),decreasing=TRUE) 
    k[1:10]
    })

  output$malware_counter <- renderValueBox({
    d<- malware_all_data()
    n<- length(unlist(d))
    valueBox(
      formatC(n, format="d", big.mark=',')
      ,paste('Total Attacks')
      ,icon = icon("stats",lib='glyphicon')
      ,color = "aqua")
  })


  output$malware_highest <- renderValueBox({
    d<-malware_table_data()
    valueBox(
      formatC(d[1][[1]], format="d", big.mark=',')
      ,paste('Highest Attacked: ',names(d))
      ,icon = icon("stats",lib='glyphicon')
      ,color = "green")
  })

  output$malware_pie <- renderPlot({
    temp<-malware_table_data()
    par(bg="#212840",fg="#8D9CCC",col="#8D9CCC",col.axis="#8D9CCC",col.lab="#8D9CCC",col.main="#8D9CCC",col.sub="#8D9CCC")
    pie(temp,names(temp),radius= 1,main="Country %",col=rainbow(length(temp)))
    legend<-legend("topright", names(temp), cex=0.8, fill=rainbow(length(temp)))
    })  

  output$malware_sub <- renderPlot({
    n <-length(unlist(malware_data()))
    n1<-length(unlist(malware_data1()))
    n2<-length(unlist(malware_data2()))

    names<-c("Dns","HTTP","IRC")
    colors<-c("#870487","#02C7A7","#048F04")
    par(bg="#212840",fg="#8D9CCC",col="#8D9CCC",col.axis="#8D9CCC",col.lab="#8D9CCC",col.main="#8D9CCC",col.sub="#8D9CCC")
    pie(c(n,n1,n2),names,radius= 1,main="Attack %",col=colors)
    legend<-legend("topright", names, cex=0.8, fill=colors)
    })


  #BUILDER DASHBOARD
    builder_date <- reactive({
      k=1

      for (i in 1:6){
        if (dur[i]==input$builder_duration)
          k=i
      }

      mul <- c(0,1,7,30,180,365)
      multiply <- checkTime(mul[k])

      query_date<-as.character(as.POSIXct(date)-cnst*multiply)
      query_date
      })

    builder_data <- reactive(getData1(input$builder_db,builder_date()))

    builder_map_data <- reactive({
      temp <- builder_data()

      builder_display<-addCircles(builder_display,lng = temp$longitude,  lat = temp$latitude, options=op,color=rainbow(7),popup=as.character(paste0(temp$city_name,", ",temp$country_name)))
      builder_display<-addLayersControl(
        builder_display,
        baseGroups = c("Dark","Toner","Watercolor","Esri"),
        options = layersControlOptions(collapsed = FALSE)
      )
      builder_display
      })

  output$builder_map <- renderLeaflet({builder_map_data()})

  output$builder_counter <- renderValueBox({
    n<- length(builder_data()[1][[1]])
    valueBox(
      formatC(n, format="d", big.mark=',')
      ,paste('Total Attacks')
      ,icon = icon("stats",lib='glyphicon')
      ,color = "yellow")
  })
  output$builder_table <- renderTable(builder_data())  

    output$builder_histo <- renderPlot({
    	m <- mongo(collection = input$builder_db, db ="firehol")
    	data <-m$aggregate('[{ "$group" : { "_id" : "$date", "total" : {"$sum" : 1}}}, { "$sort"  : { "_id" : 1}}]')
    	x <- as.vector(unlist(data[2]))
    	n <- length(x)

    	temp <- character(0)
    	for(i in 1:n){
    	    temp[i]<-as.character(as.POSIXct(data[i,1])) 
    	}

    	temp<-substr(temp,1,10)
    	par(mar=c(5,10,5,5),bg="#212840",fg="#8D9CCC",col="#8D9CCC",col.axis="#8D9CCC",col.lab="#8D9CCC",col.main="#8D9CCC",col.sub="#8D9CCC")
    	barplot(x,names.arg=temp, horiz=TRUE,las=1,col="#f2772b")    	
    	})

    output$builder_pie <- renderPlot({
    	temp<-builder_data()
    	temp<-sort(table(temp[3]),decreasing=TRUE)[1:10]
    	par(bg="#212840",fg="#8D9CCC",col="#8D9CCC",col.axis="#8D9CCC",col.lab="#8D9CCC",col.main="#8D9CCC",col.sub="#8D9CCC")
    	pie(temp,names(temp),radius= 1,main="Cities %",col=rainbow(length(temp)))
    	legend<-legend("topright", names(temp), cex=0.8, fill=rainbow(length(temp)))
    	})


    #BOTNET DASHBOARD

      botnet_date <- reactive({
        k=1

        for (i in 1:6){
          if (dur[i]==input$botnet_duration)
            k=i
        }

        mul <- c(0,1,7,30,180,365)
        multiply <- checkTime(mul[k])

        query_date<-as.character(as.POSIXct(date)-cnst*multiply)
        query_date
        })

      botnet_data <- reactive(getData1(input$botnet_db,botnet_date()))

      botnet_map_data <- reactive({
        temp <- botnet_data()

        botnet_display<-addCircles(botnet_display,lng = temp$longitude,  lat = temp$latitude, options=op,color=rainbow(7),popup=as.character(paste0(temp$city_name,", ",temp$country_name)))
        botnet_display
        })

    output$botnet_map <- renderLeaflet({botnet_map_data()})

    output$botnet_counter <- renderValueBox({
      n<- length(botnet_data()[1][[1]])
      valueBox(
        formatC(n, format="d", big.mark=',')
        ,paste('Total Attacks')
        ,icon = icon("stats",lib='glyphicon')
        ,color = "yellow")
    })
    output$botnet_table <- renderTable(botnet_data())  

      output$botnet_histo <- renderPlot({
        m <- mongo(collection = input$botnet_db, db ="firehol")
        data <-m$aggregate('[{ "$group" : { "_id" : "$date", "total" : {"$sum" : 1}}}, { "$sort"  : { "_id" : 1}}]')
        x <- as.vector(unlist(data[2]))
        n <- length(x)

        temp <- character(0)
        for(i in 1:n){
            temp[i]<-as.character(as.POSIXct(data[i,1])) 
        }

        temp<-substr(temp,1,10)
        par(mar=c(5,10,5,5),bg="#212840",fg="#8D9CCC",col="#8D9CCC",col.axis="#8D9CCC",col.lab="#8D9CCC",col.main="#8D9CCC",col.sub="#8D9CCC")
        barplot(x,names.arg=temp, horiz=TRUE,las=1)     
        })

      output$botnet_pie <- renderPlot({
        temp<-botnet_data()
        temp<-sort(table(temp[3]),decreasing=TRUE)[1:10]
        par(bg="#212840",fg="#8D9CCC",col="#8D9CCC",col.axis="#8D9CCC",col.lab="#8D9CCC",col.main="#8D9CCC",col.sub="#8D9CCC")
        pie(temp,names(temp),radius= 1,main="Cities %",col=rainbow(length(temp)))
        legend<-legend("topright", names(temp), cex=0.8, fill=rainbow(length(temp)))
        })


      #BLACKLIST DASHBOARD


        blacklist_date <- reactive({
          k=1

          for (i in 1:6){
            if (dur[i]==input$blacklist_duration)
              k=i
          }

          mul <- c(0,1,7,30,180,365)
          multiply <- checkTime(mul[k])

          query_date<-as.character(as.POSIXct(date)-cnst*multiply)
          query_date
          })

        blacklist_data <- reactive(getData1(input$blacklist_db,blacklist_date()))

        blacklist_map_data <- reactive({
          temp <- blacklist_data()

          blacklist_display<-addCircles(blacklist_display,lng = temp$longitude,  lat = temp$latitude, options=op,color=rainbow(7),popup=as.character(paste0(temp$city_name,", ",temp$country_name)))
          blacklist_display
          })

      output$blacklist_map <- renderLeaflet({blacklist_map_data()})

      output$blacklist_counter <- renderValueBox({
        n<- length(blacklist_data()[1][[1]])
        valueBox(
          formatC(n, format="d", big.mark=',')
          ,paste('Total Attacks')
          ,icon = icon("stats",lib='glyphicon')
          ,color = "yellow")
      })
      output$blacklist_table <- renderTable(blacklist_data())  

        output$blacklist_histo <- renderPlot({
          m <- mongo(collection = input$blacklist_db, db ="firehol")
          data <-m$aggregate('[{ "$group" : { "_id" : "$date", "total" : {"$sum" : 1}}}, { "$sort"  : { "_id" : 1}}]')
          x <- as.vector(unlist(data[2]))
          n <- length(x)

          temp <- character(0)
          for(i in 1:n){
              temp[i]<-as.character(as.POSIXct(data[i,1])) 
          }

          temp<-substr(temp,1,10)
          par(mar=c(5,10,5,5),bg="#212840",fg="#8D9CCC",col="#8D9CCC",col.axis="#8D9CCC",col.lab="#8D9CCC",col.main="#8D9CCC",col.sub="#8D9CCC")
          barplot(x,names.arg=temp, horiz=TRUE,las=1,col="#f2772b")     
          })

        output$blacklist_pie <- renderPlot({
          temp<-blacklist_data()
          temp<-sort(table(temp[3]),decreasing=TRUE)[1:10]
    	  par(bg="#212840",fg="#8D9CCC",col="#8D9CCC",col.axis="#8D9CCC",col.lab="#8D9CCC",col.main="#8D9CCC",col.sub="#8D9CCC")
          pie(temp,names(temp),radius= 1,main="Cities %",col=rainbow(length(temp)))
          legend<-legend("topright", names(temp), cex=0.8, fill=rainbow(length(temp)))
          })

#SEARCH DASHBOARD

	text <- eventReactive(input$go,input$search_text)
	db<- c("nt_ssh_7d","cleanmx_phishing","firehol_level1","cybercrime","bi_apache_0_1d","firehol_level3")
	db<- c("alienvault_reputation","asprox_c2","bambenek_banjori","bambenek_bebloh","bambenek_c2","bambenek_cl","bambenek_cryptowall","bambenek_dircrypt","bambenek_dyre","bambenek_geodo","bambenek_hesperbot","bambenek_matsnu","bambenek_necurs","bambenek_p2pgoz","bambenek_pushdo","bambenek_pykspa","bambenek_qakbot","bambenek_ramnit","bambenek_ranbyus","bambenek_simda","bambenek_suppobox","bambenek_symmi","bambenek_tinba","bambenek_volatile","bbcan177_ms1","bbcan177_ms3","bds_atif","bi_any_0_1d","bi_any_1_7d","bi_any_2_1d","bi_any_2_30d","bi_any_2_7d","bi_apache-404_0_1d","bi_apache-modsec_0_1d","bi_apache-noscript_0_1d","bi_apache-noscript_2_30d","bi_apache-phpmyadmin_0_1d","bi_apache-scriddies_0_1d","bi_apache_0_1d","bi_apache_1_7d","bi_apache_2_30d","bi_apacheddos_0_1d","bi_assp_0_1d","bi_asterisk_0_1d","bi_asterisk_2_30d","bi_badbots_0_1d","bi_badbots_1_7d","bi_bruteforce_0_1d","bi_bruteforce_1_7d","bi_cms_0_1d","bi_cms_1_7d","bi_cms_2_30d","bi_courierauth_0_1d","bi_courierauth_2_30d","bi_default_0_1d","bi_default_1_7d","bi_default_2_30d","bi_dns_0_1d","bi_dovecot-pop3imap_0_1d","bi_dovecot-pop3imap_2_30d","bi_dovecot_0_1d","bi_dovecot_1_7d","bi_dovecot_2_30d","bi_drupal_0_1d","bi_exim_0_1d","bi_exim_1_7d","bi_ftp_0_1d","bi_ftp_1_7d","bi_ftp_2_30d","bi_http_0_1d","bi_http_1_7d","bi_http_2_30d","bi_imap_0_1d","bi_mail_0_1d","bi_mail_1_7d","bi_mail_2_30d","bi_named_0_1d","bi_owncloud_0_1d","bi_plesk-postfix_0_1d","bi_postfix-sasl_0_1d","bi_postfix-sasl_1_7d","bi_postfix-sasl_2_30d","bi_postfix_0_1d","bi_postfix_1_7d","bi_postfix_2_30d","bi_proftpd_0_1d","bi_proftpd_1_7d","bi_proftpd_2_30d","bi_pureftpd_0_1d","bi_pureftpd_1_7d","bi_pureftpd_2_30d","bi_qmail-smtp_0_1d","bi_rdp_0_1d","bi_sasl_0_1d","bi_sasl_1_7d","bi_sasl_2_30d","bi_sip_0_1d","bi_sip_1_7d","bi_sip_2_30d","bi_smtp_0_1d","bi_spam_0_1d","bi_spam_1_7d","bi_sql-attack_0_1d","bi_sql_0_1d","bi_ssh-blocklist_0_1d","bi_ssh-ddos_0_1d","bi_ssh-ddos_2_30d","bi_ssh_0_1d","bi_ssh_1_7d","bi_ssh_2_30d","bi_sshd_0_1d","bi_sshd_1_7d","bi_sshd_2_30d","bi_telnet_0_1d","bi_telnet_1_7d","bi_telnet_2_30d","bi_unknown_0_1d","bi_unknown_1_7d","bi_unknown_2_30d","bi_username-notfound_0_1d","bi_voip_0_1d","bi_voip_1_7d","bi_voip_2_30d","bi_vsftpd_0_1d","bi_vsftpd_2_30d","bi_wordpress_0_1d","bi_wordpress_1_7d","bi_wordpress_2_30d","bitcoin_blockchain_info_1d","bitcoin_blockchain_info_30d","bitcoin_blockchain_info_7d","bitcoin_nodes","bitcoin_nodes_1d","bitcoin_nodes_30d","bitcoin_nodes_7d","blocklist_de","blocklist_de_apache","blocklist_de_bots","blocklist_de_bruteforce","blocklist_de_ftp","blocklist_de_imap","blocklist_de_mail","blocklist_de_sip","blocklist_de_ssh","blocklist_de_strongips","blocklist_net_ua","bm_tor","botscout","botscout_1d","botscout_30d","botscout_7d","botvrij_dst","botvrij_src","bruteforceblocker","ciarmy","cidr_report_bogons","cleanmx_phishing","cleanmx_viruses","cleantalk","cleantalk_1d","cleantalk_30d","cleantalk_7d","cleantalk_new","cleantalk_new_1d","cleantalk_new_30d","cleantalk_new_7d","cleantalk_top20","cleantalk_updated","cleantalk_updated_1d","cleantalk_updated_30d","cleantalk_updated_7d","coinbl_hosts","coinbl_hosts_browser","coinbl_hosts_optional","coinbl_ips","cruzit_web_attacks","cta_cryptowall","cybercrime","darklist_de","datacenters","dm_tor","dshield","dshield_1d","dshield_30d","dshield_7d","dshield_top_1000","dyndns_ponmocup","esentire_14072015_com","esentire_14072015q_com","esentire_22072014a_com","esentire_22072014b_com","esentire_22072014c_com","esentire_atomictrivia_ru","esentire_auth_update_ru","esentire_burmundisoul_ru","esentire_crazyerror_su","esentire_dagestanskiiviskis_ru","esentire_differentia_ru","esentire_disorderstatus_ru","esentire_dorttlokolrt_com","esentire_downs1_ru","esentire_ebankoalalusys_ru","esentire_emptyarray_ru","esentire_fioartd_com","esentire_getarohirodrons_com","esentire_hasanhashsde_ru","esentire_inleet_ru","esentire_islamislamdi_ru","esentire_krnqlwlplttc_com","esentire_maddox1_ru","esentire_manning1_ru","esentire_misteryherson_ru","esentire_mysebstarion_ru","esentire_smartfoodsglutenfree_kz","esentire_venerologvasan93_ru","esentire_volaya_ru","et_block","et_botcc","et_compromised","et_dshield","et_spamhaus","et_tor","feodo","feodo_badips","firehol_abusers_1d","firehol_abusers_30d","firehol_anonymous","firehol_level1","firehol_level2","firehol_level3","firehol_level4","firehol_proxies","firehol_webclient","firehol_webserver","gofferje_sip","gpf_comics","graphiclineweb","greensnow","haley_ssh","hphosts_ats","hphosts_emd","hphosts_exp","hphosts_fsa","hphosts_grm","hphosts_hfs","hphosts_hjk","hphosts_mmt","hphosts_pha","hphosts_psh","hphosts_wrz","iblocklist_abuse_palevo","iblocklist_abuse_spyeye","iblocklist_abuse_zeus","iblocklist_ciarmy_malicious","iblocklist_cidr_report_bogons","iblocklist_cruzit_web_attacks","iblocklist_isp_aol","iblocklist_isp_att","iblocklist_isp_cablevision","iblocklist_isp_charter","iblocklist_isp_comcast","iblocklist_isp_embarq","iblocklist_isp_qwest","iblocklist_isp_sprint","iblocklist_isp_suddenlink","iblocklist_isp_twc","iblocklist_isp_verizon","iblocklist_malc0de","iblocklist_onion_router","iblocklist_org_activision","iblocklist_org_apple","iblocklist_org_blizzard","iblocklist_org_crowd_control","iblocklist_org_electronic_arts","iblocklist_org_joost","iblocklist_org_linden_lab","iblocklist_org_logmein","iblocklist_org_ncsoft","iblocklist_org_nintendo","iblocklist_org_pandora","iblocklist_org_pirate_bay","iblocklist_org_punkbuster","iblocklist_org_riot_games","iblocklist_org_sony_online","iblocklist_org_square_enix","iblocklist_org_steam","iblocklist_org_ubisoft","iblocklist_org_xfire","iblocklist_pedophiles","iblocklist_spamhaus_drop","iblocklist_yoyo_adservers","ipblacklistcloud_recent","ipblacklistcloud_recent_1d","ipblacklistcloud_recent_30d","ipblacklistcloud_recent_7d","ipblacklistcloud_top","iw_spamlist","iw_wormlist","lashback_ubl","malc0de","malwaredomainlist","maxmind_proxy_fraud","myip","nixspam","normshield_all_attack","normshield_all_bruteforce","normshield_all_ddosbot","normshield_all_dnsscan","normshield_all_spam","normshield_all_suspicious","normshield_all_wannacry","normshield_all_webscan","normshield_all_wormscan","normshield_high_attack","normshield_high_bruteforce","normshield_high_ddosbot","normshield_high_dnsscan","normshield_high_spam","normshield_high_suspicious","normshield_high_wannacry","normshield_high_webscan","normshield_high_wormscan","nt_malware_dns","nt_malware_http","nt_malware_irc","nt_ssh_7d","nullsecure","packetmail","packetmail_emerging_ips","packetmail_mail","packetmail_ramnode","php_commenters","php_commenters_1d","php_commenters_30d","php_commenters_7d","php_dictionary","php_dictionary_1d","php_dictionary_30d","php_dictionary_7d","php_harvesters","php_harvesters_1d","php_harvesters_30d","php_harvesters_7d","php_spammers","php_spammers_1d","php_spammers_30d","php_spammers_7d","proxylists","proxylists_1d","proxylists_30d","proxylists_7d","proxyrss","proxyrss_1d","proxyrss_30d","proxyrss_7d","proxyspy_1d","proxyspy_30d","proxyspy_7d","proxz","proxz_1d","proxz_30d","proxz_7d","pushing_inertia_blocklist","ransomware_cryptowall_ps","ransomware_feed","ransomware_locky_c2","ransomware_locky_ps","ransomware_online","ransomware_rw","ransomware_teslacrypt_ps","ransomware_torrentlocker_c2","ransomware_torrentlocker_ps","ri_connect_proxies","ri_connect_proxies_1d","ri_connect_proxies_30d","ri_connect_proxies_7d","ri_web_proxies","ri_web_proxies_1d","ri_web_proxies_30d","ri_web_proxies_7d","sblam","set_file_timestamps","snort_ipfilter","socks_proxy","socks_proxy_1d","socks_proxy_30d","socks_proxy_7d","spamhaus_drop","spamhaus_edrop","sslbl","sslbl_aggressive","sslproxies","sslproxies_1d","sslproxies_30d","sslproxies_7d","stopforumspam","stopforumspam_180d","stopforumspam_1d","stopforumspam_30d","stopforumspam_365d","stopforumspam_7d","stopforumspam_90d","stopforumspam_toxic","taichung","talosintel_ipfilter","temp","threatcrowd","tor_exits","tor_exits_1d","tor_exits_30d","tor_exits_7d","turris_greylist","urandomusto_dns","urandomusto_ftp","urandomusto_http","urandomusto_mailer","urandomusto_malware","urandomusto_ntp","urandomusto_rdp","urandomusto_smb","urandomusto_spam","urandomusto_ssh","urandomusto_telnet","urandomusto_unspecified","urandomusto_vnc","urlvir","uscert_hidden_cobra","voipbl","vxvault","xforce_bccs","xroxy","xroxy_1d","xroxy_30d","xroxy_7d","yoyo_adservers","zeus","zeus_badips")

    data <- reactive({
    		ip <- text()
    		lis <- c()
    		pos <- 0
    		x<- 0.9/439

    		withProgress(message="Progress ", value=0.3, {

    			withProgress(message="Searching ", detail="", value=0,{

    				for (i in db){
    					if(checkIp(i,ip)){
    						lis[pos+1]<- i
    						pos<-pos+1
    					}
    					incProgress(x, detail=i)

    				}
    				})
    			})
    		lis
    	})

    output$search_output <- renderTable(data())


#BLOCKCHAIN DASHBOARD

  blockchain_date <- reactive({
    k=1

    for (i in 1:6){
      if (dur[i]==input$blockchain_duration)
        k=i
    }

    mul <- c(0,1,7,30,180,365)
    multiply <- checkTime(mul[k])

    query_date<-as.character(as.POSIXct(date)-cnst*multiply)
    query_date
  })

  blockchain_data <- reactive(getData1("bitcoin_blockchain_info_1d",blockchain_date()))

  blockchain_map_data <- reactive({
    temp <- blockchain_data()

    blockchain_display<-addCircles(blockchain_display,lng = temp$longitude,  lat = temp$latitude, options=op,color=rainbow(10),popup=as.character(temp$city_name))    #white

    blockchain_display
    })

  output$blockchain_map <- renderLeaflet({blockchain_map_data()})


  blockchain_table_data <- reactive({
    p<- blockchain_data()
    k<-sort(table(unlist(p[4])),decreasing=TRUE) 
    k
    })

  output$blockchain_counter <- renderValueBox({
    d<- blockchain_data()
    n<- length(unlist(d[4]))
    valueBox(
      formatC(n, format="d", big.mark=',')
      ,paste('Total Attacks')
      ,icon = icon("stats",lib='glyphicon')
      ,color = "aqua")
  })

  output$blockchain_highest <- renderValueBox({
    d<-blockchain_table_data()
    valueBox(
      formatC(d[1][[1]], format="d", big.mark=',')
      ,paste('Highest Attacked: ',names(d))
      ,icon = icon("stats",lib='glyphicon')
      ,color = "green")
  })

  output$blockchain_pie <- renderPlot({
    temp<-blockchain_table_data()[1:13]
    par(bg="#212840",fg="#8D9CCC",col="#8D9CCC",col.axis="#8D9CCC",col.lab="#8D9CCC",col.main="#8D9CCC",col.sub="#8D9CCC")
    pie(temp,names(temp),radius= 1,main="Country %",col=rainbow(length(temp)))
    legend<-legend("topright", names(temp), cex=0.8, fill=rainbow(length(temp)))
    })  

  output$blockchain_histo <- renderPlot({
    par(bg="#212840",fg="#8D9CCC",col="#8D9CCC",col.axis="#8D9CCC",col.lab="#8D9CCC",col.main="#8D9CCC",col.sub="#8D9CCC")
  	barplot(blockchain_table_data()[1:5],xlab = "Countries", ylab="Attacks", col = "#4286f4")
  	})


}