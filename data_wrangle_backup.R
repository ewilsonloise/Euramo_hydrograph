#Data Wrangle 

#Libraries
library(tidyverse)
library(lubridate)
library(dplyr)
library(readr)

# Read in all the data as you have done previously
df1 <- rbind(
  (read_csv("Data/113004A.H.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H"))),
  (read_csv("Data/113006A.H.CSV") %>%
    mutate(time = format(time, "%Y-%m-%d %H"))),
  (read_csv("Data/113015A.H.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H"))),
  (read_csv("Data/114001A.R.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H"))),
  (read_csv("Data/113015A.R.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H"))),
  (read_csv("Data/113006A.R.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H"))),
  (read_csv("Data/113015A.Q.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H"))),
  (read_csv("Data/113006A.Q.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H"))),
  (read_csv("Data/113004A.Q.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H")))) 

df2 <- df1 %>% 
  pivot_wider(names_from = "varname", values_from = "value") %>% 
  janitor::clean_names()





