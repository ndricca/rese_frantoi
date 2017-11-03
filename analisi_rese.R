library(reshape2)
library(ggplot2)
library(dplyr)
library(tidyr)
library(plotly)

df <- read.csv2("rese_frantoi.csv")
df$Data_frangitura <- as.Date(df$Data_frangitura)
df$Comune_oliveto <- tolower(df$Comune_oliveto)
df$Comune_oliveto <- ifelse(df$Comune_oliveto=="",as.character(df$Provincia_oliveto),df$Comune_oliveto)

df %>% 
  group_by(Comune_oliveto,Data_frangitura) %>% 
  summarize(n = n()) %>% 
  filter(n>1) %>% 
  arrange(desc(n))

plt <- ggplot(df,aes(Data_frangitura,Resa_perc,color = Comune_oliveto)) + 
  geom_line() +
  facet_wrap(~Provincia_oliveto)

ggplotly(plt)