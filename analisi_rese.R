library(reshape2)
library(ggplot2)

df <- read.csv2("rese_frantoi.csv")
df <- df[,c("Provincia_oliveto","Resa_perc","Data_frangitura")]
df$Data_frangitura <- as.Date(df$Data_frangitura)

df$Comune_oliveto <- tolower(df$Comune_oliveto)

ifelse(df$Comune_oliveto=="",df$Provincia_oliveto,df$Comune_oliveto)


ggplot(df,aes(Data_frangitura,Resa_perc,color = Comune_oliveto)) + 
  geom_line() +
  facet_wrap(~Provincia_oliveto)


