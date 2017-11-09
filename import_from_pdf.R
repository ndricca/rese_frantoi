# library(devtools)
# devtools::install_github(c("ropenscilabs/tabulizerjars", "ropenscilabs/tabulizer"), args = "--no-multiarch")
library(tabulizer)
library(tidyr)
library(dplyr)
library(rvest)
library(stringdist)

# extraction of the data from pdf file 
data <- extract_tables("Rese_frantoi_17.pdf")

province <- c("GENOVA","IMPERIA","LA SPEZIA","SAVONA")
data <- lapply(data,function(x)(x[x[,1] %in% province,]))
data <- do.call(rbind,data)

headers <- c("Provincia_oliveto","Comune_oliveto","Resa_perc","Data_frangitura","Settimana")
colnames(data) <- headers
data <- as.data.frame(data[,-5])

data$Resa_perc <- as.numeric(sub(",",".",sub("%","",data$Resa_perc)))
data$Data_frangitura <- as.Date(paste0(data$Data_frangitura,"/2017"),format = "%d/%m/%Y")
data$Comune_oliveto <- tolower(data$Comune_oliveto)
data$Comune_oliveto <- ifelse(data$Comune_oliveto=="",as.character(data$Provincia_oliveto),data$Comune_oliveto)



# get official list of Ligurian municipalities to match with the ones declared into the pdf document
url <- "https://it.wikipedia.org/wiki/Comuni_della_Liguria"
comuni <- url %>%
  read_html() %>%
  html_nodes(xpath='//*[@id="mw-content-text"]/div/table[1]') %>%
  html_table()


comuni <- comuni[[1]]
summary(comuni) ; str(comuni)

# one row example
comuni[which.min(stringdist(tolower(data$Comune_oliveto[1]),tolower(comuni$Comune),method = "lv")),"Comune"]

# create vector of best match btw declared and official municipalities lists
data$lev_dist_comuni <- unlist(lapply(data$Comune_oliveto, function(x) (
  comuni[which.min(stringdist(tolower(x),tolower(comuni$Comune),method = "lv")),"Comune"])))

# create vector of the value of best match in order to check non-obvious matches
data$lev_dist_valore <- unlist(lapply(data$Comune_oliveto, function(x) (
  min(stringdist(tolower(x),tolower(comuni$Comune),method = "lv")))))

# check non-obvious matches
data %>% 
  select(Comune_oliveto,lev_dist_comuni, lev_dist_valore) %>% 
  filter(lev_dist_valore>1) %>% 
  filter(Comune_oliveto!="serra riccã²" 
         & Comune_oliveto!="imperia fraz. poggi" 
         & Comune_oliveto!="loano sv") %>% 
  select(Comune_oliveto) -> wrong_data


data[which(data$Comune_oliveto %in% wrong_data$Comune_oliveto),"lev_dist_comuni"] <- c("Vezzano Ligure", rep("Santo Stefano di Magra",4), "Sarzana")

data <- merge(data,comuni, by.x = "lev_dist_comuni",by.y = "Comune")

data %>% 
  mutate(check = ifelse(tolower(Provincia_oliveto)!=tolower(Provincia),1,0)) %>% 
  filter(check>0)

data <- data[,c("lev_dist_comuni","Provincia_oliveto","Resa_perc","Data_frangitura")]

names(data) <- c("Comune","Provincia","Resa_perc","Data_frangitura")


# creation of a 
write.csv2(data,"rese_frantoi.csv",row.names = FALSE)

rm(province, headers,url,comuni,wrong_data)