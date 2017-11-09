library(reshape2)
library(ggplot2)
library(dplyr)
library(tidyr)
library(plotly)

data <- read.csv2("rese_frantoi.csv",colClasses = c("factor","factor","numeric","Date"))
str(data) ; summary(data)


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

# ggplotly(plt)

data %>% 
  mutate(Settimana = strftime(Data_frangitura,"%W")) %>% 
  group_by(Comune,Settimana) %>% 
  summarize(Conteggio = n(),
            Resa_media = mean(Resa_perc)) %>% 
  filter(Conteggio>1) %>% 
  arrange(desc(Resa_media))
