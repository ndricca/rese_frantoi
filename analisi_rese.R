library(reshape2)
library(ggplot2)
library(dplyr)
library(tidyr)
library(plotly)

data <- read.csv2("rese_frantoi.csv")
data$Data_frangitura <- as.Date(df$Data_frangitura)

data %>% 
  group_by(Comune) %>% 
  summarize(n = n()) %>% 
  filter(n>1) %>% 
  arrange(desc(n))

plt <- ggplot(data,aes(Data_frangitura,Resa_perc, color = Comune)) + 
  geom_point() +
  geom_line() +
  facet_wrap(~Provincia)
plt

ggplotly(plt)
