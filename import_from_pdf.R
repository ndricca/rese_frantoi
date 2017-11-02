# library(devtools)
# devtools::install_github(c("ropenscilabs/tabulizerjars", "ropenscilabs/tabulizer"), args = "--no-multiarch")
library(tabulizer)
data <- extract_tables("Rese_frantoi_17.pdf")


province <- c("GENOVA","IMPERIA","LA SPEZIA","SAVONA")
data <- lapply(data,function(x)(x[x[,1] %in% province,]))
data <- do.call(rbind,data)

headers <- c("Provincia_oliveto","Comune_oliveto","Resa_perc","Data_frangitura","Settimana")
colnames(data) <- headers
data <- as.data.frame(data[,-5])

data$Resa_perc <- as.numeric(sub(",",".",sub("%","",data$Resa_perc)))
data$Data_frangitura <- as.Date(paste0(data$Data_frangitura,"/2017"),format = "%d/%m/%Y")

write.csv2(data,"rese_frantoi.csv")
