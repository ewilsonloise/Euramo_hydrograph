#Data Wrangle 

#Libraries
library(tidyverse)
library(lubridate)
library(dplyr)
library(readr)

# Read in all the data as you have done previously
#Height data
a <- read_csv("Data/Raw/113004A.H.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) %>% 
   rename(quality_height = quality)
    a$quality_rainfall <- NA
    a$quality_discharge <- NA
  
b <- read_csv("Data/Raw/113006A.H.CSV") %>%
    mutate(time = format(time, "%Y-%m-%d %H"))%>% 
     rename(quality_height = quality)
      b$quality_rainfall <- NA
      b$quality_discharge <- NA
 
c <- read_csv("Data/Raw/113015A.H.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H")) %>% 
     rename(quality_height = quality)
      c$quality_rainfall <- NA
      c$quality_discharge <- NA
      
    
  
d <- read_csv("Data/Raw/114001A.R.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H")) %>% 
     rename(quality_rainfall = quality)

e <- read_csv("Data/Raw/113015A.R.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H")) %>% 
     rename(quality_rainfall = quality)

f <- read_csv("Data/Raw/113006A.R.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H")) %>% 
     rename(quality_rainfall = quality)
  
g <- read_csv("Data/Raw/113015A.Q.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H")) %>% 
     rename(quality_discharge = quality)

h <- read_csv("Data/Raw/113006A.Q.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H")) %>% 
     rename(quality_discharge = quality)
     
i <- read_csv("Data/Raw/113004A.Q.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H")) %>% 
     rename(quality_discharge = quality)

dat <- df1 %>% 
  pivot_wider(names_from = "varname", values_from = "value") %>% 
  janitor::clean_names()

# df2 <- rbind(
#   (read_csv("Data/Raw/Koombooloomba_Dam_031083_1800_Data.csv") %>%
#      unite(col = "time", Year, Month, Day, sep = "-")),
#   (read_csv("Data/Raw/Tully_Sugar_Mill_032042_1800_Data.csv") %>%
#     unite(col = "time", Year, Month, Day, sep = "-"))) %>%
#   mutate(time = as.Date(time)) %>%
#   rename(
#     rainfall_mm = `Rainfall amount (millimetres)`,
#     site = `Bureau of Meteorology station number`,
#     quality = Quality) %>%
#   select(-`Product code`, -`Period over which rainfall was measured (days)`)

df2$discharge_cumecs <- NA
df2$var <- NA
df2$level_metres <- NA

column_order <- c("site", "time", "quality", "var", "rainfall_mm", "discharge_cumecs", "level_metres")

dat <- dat %>% select(all_of(column_order))
df2 <- df2 %>% select(all_of(column_order))


(names(dat))
(names(df2))

dat_joined <- rbind(dat, df2)

dat_joined <- dat_joined %>% filter(time >= as.Date("2009-12-23") & time <= as.Date("2024-08-01"))

colnames(dat_joined)

# skimr::skim(dat_joined)
# summarytools::dfSummary(dat_joined)


write_csv(dat_joined, "Data/dat_joined.csv")


