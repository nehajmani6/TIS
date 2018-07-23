library(shiny)
require(shinydashboard)
library(ggplot2)
library(raster)
library(rgeolocate)
library(mongolite)
library(leaflet)

dur<- c("Today","Yesterday","This Week","This Month","Last 6 Months","This Year")

title <- HTML('<img src="https://security.cse.iitk.ac.in/sites/default/files/inline-images/cyber%20cell-W.png" width="40" height="40"/>   C3I Center')
header <- dashboardHeader(title = title)  

sidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("World", tabName = "world", icon = icon("globe", lib = "glyphicon")),
    menuItem("India At a Glance", tabName = "india", icon = icon("area-chart")),
    menuItem("Blockchain", tabName = "blockchain", icon = icon("chain")),
    menuItem("Malware", tabName = "malware", icon = icon("bug")),
    menuItem("Botnet", tabName = "botnet", icon = icon("user-secret")),
    menuItem("Blacklist", tabName = "blacklist", icon = icon("ban")),
    menuItem("Search", tabName = "search", icon = icon("search")),
    menuItem("Builder", tabName = "builder", icon = icon("cogs")),
    menuItem("Credits", tabName = "credits", icon = icon("angle-double-right")),
    menuItem("Visit-us", icon = icon("send",lib='glyphicon'), 
             href = "https://security.cse.iitk.ac.in/")
  )
)

#world dashboard

css <- "color: white;
    font-size: 28px;
    font-weight: bold;
    padding-left:5em;
    text-align:center;
    font-family: 'Lato', sans-serif;"



header_logo <- fluidRow(
  column(12, h1(style=css,HTML('<img src="https://security.cse.iitk.ac.in/sites/default/files/inline-images/cyber%20cell-W.png" width="12%" height="12%"/><br>',"Interdisciplinary Centre for Cyber Security and Cyber Defence of Critical Infrastructures")))
  )

frow1 <- fluidRow(
  column(4,valueBoxOutput("world_counter",width="100%")),
  column(4,valueBoxOutput("world_highest",width="100%")),
  column(4,sidebarPanel(selectInput("world_duration", "Duration:", choices=dur),width=12))
)

frow2 <- fluidRow(
  column(12,
    box(
      title = "Heat Map"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,leafletOutput("world_map",width="100%",height="450px")
      ,background = "light-blue"
      ,width=12
    ))
)

frow3 <- fluidRow(
  column(6,
    box(
      title = "Country Attacked"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,plotOutput("world_pie", height = "300px")
      ,background = "light-blue"
      ,width=12
    )),
  column(6,
    box(
      title = "Top 5 Countries Attacked"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,plotOutput("world_histo", height = "300px")
      ,background = "light-blue"
      ,width=12
    ))
)

copyright <- fluidRow(
  h6(align="right","Copyright © C3i IITK 2018. All rights reserved")
)

#india dashboard

irow1 <- fluidRow(
  column(4,valueBoxOutput("india_counter",width="100%")),
  column(4,valueBoxOutput("india_highest",width="100%")),
  column(4,sidebarPanel(selectInput("india_duration", "Duration:", choices=dur),width=12))
)

irow2 <- fluidRow(
  column(12,
    box(
      title = "Heat Map"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,leafletOutput("india_map",width="100%",height="700px")
      ,background = "light-blue"
      ,width=12
    ))
)

irow3 <- fluidRow(
  column(6,
    box(
      title = "Top 5 Risky States"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,plotOutput("india_states", height = "300px")
      ,background = "light-blue"
      ,width=12
    )),
  column(6,
    box(
      title = "Top 10 Cities Attacked"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,plotOutput("india_cities", height = "300px")
      ,background = "light-blue"
      ,width=12
    ))
)

#MALWARE DASHBOARD
mrow1 <- fluidRow(
  column(4,valueBoxOutput("malware_counter",width="100%")),
  column(4,valueBoxOutput("malware_highest",width="100%")),
  column(4,sidebarPanel(selectInput("malware_duration", "Duration:", choices=dur),width=12))
)

mrow2 <- fluidRow(
  column(12,
    box(
      title = "Heat Map"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,leafletOutput("malware_map",width="100%",height="450px")
      ,background = "light-blue"
      ,width=12
    ))
)

mrow3 <- fluidRow(
  column(6,
    box(
      title = "Top 10 Countries Attacked"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,plotOutput("malware_pie", height = "300px")
      ,background = "light-blue"
      ,width=12
    )),
  column(6,
    box(
      title = "Sub Categories"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,plotOutput("malware_sub", height = "300px")
      ,background = "light-blue"
      ,width=12
    ))
)

#BUILDER DASHBOARD
db<- c("nt_ssh_7d","cleanmx_phishing","firehol_level1","cybercrime","bi_apache_0_1d","firehol_level3")
db<- c("alienvault_reputation","asprox_c2","bambenek_banjori","bambenek_bebloh","bambenek_c2","bambenek_cl","bambenek_cryptowall","bambenek_dircrypt","bambenek_dyre","bambenek_geodo","bambenek_hesperbot","bambenek_matsnu","bambenek_necurs","bambenek_p2pgoz","bambenek_pushdo","bambenek_pykspa","bambenek_qakbot","bambenek_ramnit","bambenek_ranbyus","bambenek_simda","bambenek_suppobox","bambenek_symmi","bambenek_tinba","bambenek_volatile","bbcan177_ms1","bbcan177_ms3","bds_atif","bi_any_0_1d","bi_any_1_7d","bi_any_2_1d","bi_any_2_30d","bi_any_2_7d","bi_apache-404_0_1d","bi_apache-modsec_0_1d","bi_apache-noscript_0_1d","bi_apache-noscript_2_30d","bi_apache-phpmyadmin_0_1d","bi_apache-scriddies_0_1d","bi_apache_0_1d","bi_apache_1_7d","bi_apache_2_30d","bi_apacheddos_0_1d","bi_assp_0_1d","bi_asterisk_0_1d","bi_asterisk_2_30d","bi_badbots_0_1d","bi_badbots_1_7d","bi_bruteforce_0_1d","bi_bruteforce_1_7d","bi_cms_0_1d","bi_cms_1_7d","bi_cms_2_30d","bi_courierauth_0_1d","bi_courierauth_2_30d","bi_default_0_1d","bi_default_1_7d","bi_default_2_30d","bi_dns_0_1d","bi_dovecot-pop3imap_0_1d","bi_dovecot-pop3imap_2_30d","bi_dovecot_0_1d","bi_dovecot_1_7d","bi_dovecot_2_30d","bi_drupal_0_1d","bi_exim_0_1d","bi_exim_1_7d","bi_ftp_0_1d","bi_ftp_1_7d","bi_ftp_2_30d","bi_http_0_1d","bi_http_1_7d","bi_http_2_30d","bi_imap_0_1d","bi_mail_0_1d","bi_mail_1_7d","bi_mail_2_30d","bi_named_0_1d","bi_owncloud_0_1d","bi_plesk-postfix_0_1d","bi_postfix-sasl_0_1d","bi_postfix-sasl_1_7d","bi_postfix-sasl_2_30d","bi_postfix_0_1d","bi_postfix_1_7d","bi_postfix_2_30d","bi_proftpd_0_1d","bi_proftpd_1_7d","bi_proftpd_2_30d","bi_pureftpd_0_1d","bi_pureftpd_1_7d","bi_pureftpd_2_30d","bi_qmail-smtp_0_1d","bi_rdp_0_1d","bi_sasl_0_1d","bi_sasl_1_7d","bi_sasl_2_30d","bi_sip_0_1d","bi_sip_1_7d","bi_sip_2_30d","bi_smtp_0_1d","bi_spam_0_1d","bi_spam_1_7d","bi_sql-attack_0_1d","bi_sql_0_1d","bi_ssh-blocklist_0_1d","bi_ssh-ddos_0_1d","bi_ssh-ddos_2_30d","bi_ssh_0_1d","bi_ssh_1_7d","bi_ssh_2_30d","bi_sshd_0_1d","bi_sshd_1_7d","bi_sshd_2_30d","bi_telnet_0_1d","bi_telnet_1_7d","bi_telnet_2_30d","bi_unknown_0_1d","bi_unknown_1_7d","bi_unknown_2_30d","bi_username-notfound_0_1d","bi_voip_0_1d","bi_voip_1_7d","bi_voip_2_30d","bi_vsftpd_0_1d","bi_vsftpd_2_30d","bi_wordpress_0_1d","bi_wordpress_1_7d","bi_wordpress_2_30d","bitcoin_blockchain_info_1d","bitcoin_blockchain_info_30d","bitcoin_blockchain_info_7d","bitcoin_nodes","bitcoin_nodes_1d","bitcoin_nodes_30d","bitcoin_nodes_7d","blocklist_de","blocklist_de_apache","blocklist_de_bots","blocklist_de_bruteforce","blocklist_de_ftp","blocklist_de_imap","blocklist_de_mail","blocklist_de_sip","blocklist_de_ssh","blocklist_de_strongips","blocklist_net_ua","bm_tor","botscout","botscout_1d","botscout_30d","botscout_7d","botvrij_dst","botvrij_src","bruteforceblocker","ciarmy","cidr_report_bogons","cleanmx_phishing","cleanmx_viruses","cleantalk","cleantalk_1d","cleantalk_30d","cleantalk_7d","cleantalk_new","cleantalk_new_1d","cleantalk_new_30d","cleantalk_new_7d","cleantalk_top20","cleantalk_updated","cleantalk_updated_1d","cleantalk_updated_30d","cleantalk_updated_7d","coinbl_hosts","coinbl_hosts_browser","coinbl_hosts_optional","coinbl_ips","cruzit_web_attacks","cta_cryptowall","cybercrime","darklist_de","datacenters","dm_tor","dshield","dshield_1d","dshield_30d","dshield_7d","dshield_top_1000","dyndns_ponmocup","esentire_14072015_com","esentire_14072015q_com","esentire_22072014a_com","esentire_22072014b_com","esentire_22072014c_com","esentire_atomictrivia_ru","esentire_auth_update_ru","esentire_burmundisoul_ru","esentire_crazyerror_su","esentire_dagestanskiiviskis_ru","esentire_differentia_ru","esentire_disorderstatus_ru","esentire_dorttlokolrt_com","esentire_downs1_ru","esentire_ebankoalalusys_ru","esentire_emptyarray_ru","esentire_fioartd_com","esentire_getarohirodrons_com","esentire_hasanhashsde_ru","esentire_inleet_ru","esentire_islamislamdi_ru","esentire_krnqlwlplttc_com","esentire_maddox1_ru","esentire_manning1_ru","esentire_misteryherson_ru","esentire_mysebstarion_ru","esentire_smartfoodsglutenfree_kz","esentire_venerologvasan93_ru","esentire_volaya_ru","et_block","et_botcc","et_compromised","et_dshield","et_spamhaus","et_tor","feodo","feodo_badips","firehol_abusers_1d","firehol_abusers_30d","firehol_anonymous","firehol_level1","firehol_level2","firehol_level3","firehol_level4","firehol_proxies","firehol_webclient","firehol_webserver","gofferje_sip","gpf_comics","graphiclineweb","greensnow","haley_ssh","hphosts_ats","hphosts_emd","hphosts_exp","hphosts_fsa","hphosts_grm","hphosts_hfs","hphosts_hjk","hphosts_mmt","hphosts_pha","hphosts_psh","hphosts_wrz","iblocklist_abuse_palevo","iblocklist_abuse_spyeye","iblocklist_abuse_zeus","iblocklist_ciarmy_malicious","iblocklist_cidr_report_bogons","iblocklist_cruzit_web_attacks","iblocklist_isp_aol","iblocklist_isp_att","iblocklist_isp_cablevision","iblocklist_isp_charter","iblocklist_isp_comcast","iblocklist_isp_embarq","iblocklist_isp_qwest","iblocklist_isp_sprint","iblocklist_isp_suddenlink","iblocklist_isp_twc","iblocklist_isp_verizon","iblocklist_malc0de","iblocklist_onion_router","iblocklist_org_activision","iblocklist_org_apple","iblocklist_org_blizzard","iblocklist_org_crowd_control","iblocklist_org_electronic_arts","iblocklist_org_joost","iblocklist_org_linden_lab","iblocklist_org_logmein","iblocklist_org_ncsoft","iblocklist_org_nintendo","iblocklist_org_pandora","iblocklist_org_pirate_bay","iblocklist_org_punkbuster","iblocklist_org_riot_games","iblocklist_org_sony_online","iblocklist_org_square_enix","iblocklist_org_steam","iblocklist_org_ubisoft","iblocklist_org_xfire","iblocklist_pedophiles","iblocklist_spamhaus_drop","iblocklist_yoyo_adservers","ipblacklistcloud_recent","ipblacklistcloud_recent_1d","ipblacklistcloud_recent_30d","ipblacklistcloud_recent_7d","ipblacklistcloud_top","iw_spamlist","iw_wormlist","lashback_ubl","malc0de","malwaredomainlist","maxmind_proxy_fraud","myip","nixspam","normshield_all_attack","normshield_all_bruteforce","normshield_all_ddosbot","normshield_all_dnsscan","normshield_all_spam","normshield_all_suspicious","normshield_all_wannacry","normshield_all_webscan","normshield_all_wormscan","normshield_high_attack","normshield_high_bruteforce","normshield_high_ddosbot","normshield_high_dnsscan","normshield_high_spam","normshield_high_suspicious","normshield_high_wannacry","normshield_high_webscan","normshield_high_wormscan","nt_malware_dns","nt_malware_http","nt_malware_irc","nt_ssh_7d","nullsecure","packetmail","packetmail_emerging_ips","packetmail_mail","packetmail_ramnode","php_commenters","php_commenters_1d","php_commenters_30d","php_commenters_7d","php_dictionary","php_dictionary_1d","php_dictionary_30d","php_dictionary_7d","php_harvesters","php_harvesters_1d","php_harvesters_30d","php_harvesters_7d","php_spammers","php_spammers_1d","php_spammers_30d","php_spammers_7d","proxylists","proxylists_1d","proxylists_30d","proxylists_7d","proxyrss","proxyrss_1d","proxyrss_30d","proxyrss_7d","proxyspy_1d","proxyspy_30d","proxyspy_7d","proxz","proxz_1d","proxz_30d","proxz_7d","pushing_inertia_blocklist","ransomware_cryptowall_ps","ransomware_feed","ransomware_locky_c2","ransomware_locky_ps","ransomware_online","ransomware_rw","ransomware_teslacrypt_ps","ransomware_torrentlocker_c2","ransomware_torrentlocker_ps","ri_connect_proxies","ri_connect_proxies_1d","ri_connect_proxies_30d","ri_connect_proxies_7d","ri_web_proxies","ri_web_proxies_1d","ri_web_proxies_30d","ri_web_proxies_7d","sblam","set_file_timestamps","snort_ipfilter","socks_proxy","socks_proxy_1d","socks_proxy_30d","socks_proxy_7d","spamhaus_drop","spamhaus_edrop","sslbl","sslbl_aggressive","sslproxies","sslproxies_1d","sslproxies_30d","sslproxies_7d","stopforumspam","stopforumspam_180d","stopforumspam_1d","stopforumspam_30d","stopforumspam_365d","stopforumspam_7d","stopforumspam_90d","stopforumspam_toxic","taichung","talosintel_ipfilter","temp","threatcrowd","tor_exits","tor_exits_1d","tor_exits_30d","tor_exits_7d","turris_greylist","urandomusto_dns","urandomusto_ftp","urandomusto_http","urandomusto_mailer","urandomusto_malware","urandomusto_ntp","urandomusto_rdp","urandomusto_smb","urandomusto_spam","urandomusto_ssh","urandomusto_telnet","urandomusto_unspecified","urandomusto_vnc","urlvir","uscert_hidden_cobra","voipbl","vxvault","xforce_bccs","xroxy","xroxy_1d","xroxy_30d","xroxy_7d","yoyo_adservers","zeus","zeus_badips")

drow1 <- fluidRow(
  column(4,valueBoxOutput("builder_counter",width="100%")),
  column(4,sidebarPanel(selectInput("builder_db", "Database:", selected="bi_wordpress_0_1d", choices=db),width=12)),
  column(4,sidebarPanel(selectInput("builder_duration", "Duration:", choices=dur),width=12))
  )

drow2 <- fluidRow(
  column(12, 
  box(
    title = "Heat Map"
    ,status = "primary"
    ,solidHeader = TRUE 
    ,collapsible = TRUE 
    ,leafletOutput("builder_map",width="100%",height="450px")
    ,background = "light-blue"
    ,width=12))
  )
  

drow3 <- fluidRow(
  column(6, 
    box(
      title = "Attack Stats per Day"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,plotOutput("builder_histo", height = "300px")
      ,background = "light-blue"
      ,width=12)),
  column(6,
    box(
      title = "Top 10 Cities Attacked"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,plotOutput("builder_pie", height = "300px")
      ,background = "light-blue"
      ,width=12))
  )

#BOTNET DASHBOARD
db<- c("bambenek_hesperbot","bambenek_qakbot","bi_badbots_0_1d","bi_badbots_1_7d","blocklist_de_bots","botscout","botscout_1d","botscout_30d","botscout_7d","botvrij_dst","botvrij_src","et_botcc","normshield_all_ddosbot","normshield_high_ddosbot")

brow1 <- fluidRow(
  column(4,valueBoxOutput("botnet_counter",width="100%")),
  column(4,sidebarPanel(selectInput("botnet_db", "Database:",  selected="blocklist_de_bots", choices=db),width=12)),
  column(4,sidebarPanel(selectInput("botnet_duration", "Duration:", choices=dur),width=12))
  )

brow2 <- fluidRow(
  column(12, 
  box(
    title = "Heat Map"
    ,status = "primary"
    ,solidHeader = TRUE 
    ,collapsible = TRUE 
    ,leafletOutput("botnet_map",width="100%",height="450px")
    ,background = "light-blue"
    ,width=12))
  )
  

brow3 <- fluidRow(
  column(6, 
    box(
      title = "Attack Stats per Day"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,plotOutput("botnet_histo", height = "300px")
      ,background = "light-blue"
      ,width=12)),
  column(6,
    box(
      title = "Top 10 Cities Attacked"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,plotOutput("botnet_pie", height = "300px")
      ,background = "light-blue"
      ,width=12))
  )


#BLACKLIST DASHBOARD
db <- c("iblocklist_abuse_palevo","iblocklist_abuse_spyeye","iblocklist_abuse_zeus","iblocklist_ciarmy_malicious","iblocklist_cidr_report_bogons","iblocklist_cruzit_web_attacks","iblocklist_isp_aol","iblocklist_isp_att","iblocklist_isp_cablevision","iblocklist_isp_charter","iblocklist_isp_comcast","iblocklist_isp_embarq","iblocklist_isp_qwest","iblocklist_isp_sprint","iblocklist_isp_suddenlink","iblocklist_isp_twc","iblocklist_isp_verizon","iblocklist_malc0de","iblocklist_onion_router","iblocklist_org_activision","iblocklist_org_apple","iblocklist_org_blizzard","iblocklist_org_crowd_control","iblocklist_org_electronic_arts","iblocklist_org_joost","iblocklist_org_linden_lab","iblocklist_org_logmein","iblocklist_org_ncsoft","iblocklist_org_nintendo","iblocklist_org_pandora","iblocklist_org_pirate_bay","iblocklist_org_punkbuster","iblocklist_org_riot_games","iblocklist_org_sony_online","iblocklist_org_square_enix","iblocklist_org_steam","iblocklist_org_ubisoft","iblocklist_org_xfire","iblocklist_pedophiles","iblocklist_spamhaus_drop","iblocklist_yoyo_adservers")

blrow1 <- fluidRow(
  column(4,valueBoxOutput("blacklist_counter",width="100%")),
  column(4,sidebarPanel(selectInput("blacklist_db", "Database:", choices=db),width=12)),
  column(4,sidebarPanel(selectInput("blacklist_duration", "Duration:", choices=dur),width=12))
  )

blrow2 <- fluidRow(
  column(12, 
  box(
    title = "Heat Map"
    ,status = "primary"
    ,solidHeader = TRUE 
    ,collapsible = TRUE 
    ,leafletOutput("blacklist_map",width="100%",height="450px")
    ,background = "light-blue"
    ,width=12))
  )
  

blrow3 <- fluidRow(
  column(6, 
    box(
      title = "Attack Stats per Day"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,plotOutput("blacklist_histo", height = "300px")
      ,background = "light-blue"
      ,width=12)),
  column(6,
    box(
      title = "Top 10 Cities Attacked"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,plotOutput("blacklist_pie", height = "300px")
      ,background = "light-blue"
      ,width=12))
  )

#SEARCH DASHBOARD

srow1 <- fluidRow ( 
    br(),br(),br(),
    column(1),
    column(4,
        tableOutput("search_output")
      ),
    column(7,sidebarPanel(
        textInput("search_text", label = h3("Enter IP"), value = "83.69.233.121"),
        actionButton("go","Search",width="50%"),
        width=12
      )
      )
    )

#BLOCKCHAIN DASHBOARD

bcrow1 <- fluidRow(
  column(4,valueBoxOutput("blockchain_counter",width="100%")),
  column(4,valueBoxOutput("blockchain_highest",width="100%")),
  column(4,sidebarPanel(selectInput("blockchain_duration", "Duration:", choices=dur),width=12))
)

bcrow2 <- fluidRow(
  column(12,
    box(
      title = "Heat Map"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,leafletOutput("blockchain_map",width="100%",height="450px")
      ,background = "light-blue"
      ,width=12
    ))
)

bcrow3 <- fluidRow(
  column(6,
    box(
      title = "Country Attacked"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,plotOutput("blockchain_pie", height = "300px")
      ,background = "light-blue"
      ,width=12
    )),
  column(6,
    box(
      title = "Top 5 Countries Attacked"
      ,status = "primary"
      ,solidHeader = TRUE 
      ,collapsible = TRUE 
      ,plotOutput("blockchain_histo", height = "300px")
      ,background = "light-blue"
      ,width=12
    ))
)

crow1 <- fluidRow(
  column(12,
    box(
    title = "Project Lead",
    status = "primary",
    solidHeader = F,
    collapsible = F,
    width = 12,
    fluidRow(
             column(width=1, align="left",img(src="hod.jpg", width=100)),
             column(width=1),
             column(width=3,HTML("Prof. Sandeep Shukla <br><br> Head of Depeartment, CSE IIT Kanpur"))
            )
      )
    )
  )

crow2 <- fluidRow(
  column(12,
    box(
    title = "Systems Engineer",
    status = "primary",
    solidHeader = F,
    collapsible = F,
    width = 12,
    fluidRow(
             column(width=1, align="left",img(src="neha.jpg", width=100)),
             column(width=1),
             column(width=3,HTML("Neha Ajmani <br><br> Project Engineer at C3i Center"))
            )
      )
    )
  )

crow3 <- fluidRow(
  column(12,
    box(
    title = "Developer",
    status = "primary",
    solidHeader = F,
    collapsible = F,
    width = 12,
    fluidRow(
             column(width=1, align="left",img(src="akash.jpg", width=100)),
             column(width=1),
             column(width=3, HTML("R. Akashraj<br><br>Summer Intern 2018"))
            )
      )
    )
  )

####################

dashbody <- dashboardBody(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
    tags$link(href="https://fonts.googleapis.com/css?family=Lato", rel="stylesheet"),
    tags$link(rel = "icon", type = "image/png", href = "cyber_cell.png")
  ),
  tabItems(
    tabItem(tabName = "world", frow1, frow2, frow3, copyright),
    tabItem(tabName = "india", irow1, irow2, irow3, copyright),
    tabItem(tabName = "malware", mrow1, mrow2, mrow3, copyright),
    tabItem(tabName = "builder", drow1, drow2, drow3, copyright),
    tabItem(tabName = "botnet", brow1, brow2, brow3, copyright),
    tabItem(tabName = "blacklist", blrow1, blrow2, blrow3, copyright),
    tabItem(tabName = "search", header_logo, srow1, copyright),
    tabItem(tabName = "blockchain", bcrow1, bcrow2, bcrow3, copyright),
    tabItem(tabName = "credits", crow1, crow2, crow3, copyright)
    )
  )



#completing the ui part with dashboardPage

dashboardPage(title = "Threat Intelligence", header, sidebar, dashbody, skin='purple')


# shinyUI( 

#   includeHTML("index.html")
# )