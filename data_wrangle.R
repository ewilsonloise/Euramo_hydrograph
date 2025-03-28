
library(tidyverse)
library(lubridate)
library(readr)
library(janitor)

# Function to process files
process_file <- function(file) {
  df <- read_csv(file) %>%
    mutate(time = format(time, "%Y-%m-%d %H"))
  
  # Identify type and rename `quality`
  if (grepl("\\.R\\.CSV$", file)) {
    df <- df %>% rename(quality_rainfall = quality)
  } else if (grepl("\\.Q\\.CSV$", file)) {
    df <- df %>% rename(quality_discharge = quality)
  } else if (grepl("\\.H\\.CSV$", file)) {
    df <- df %>% rename(quality_height = quality)
  }
  
  # Ensure all quality columns exist
  df <- df %>%
    mutate(
      quality_rainfall = ifelse(!"quality_rainfall" %in% names(df), NA, quality_rainfall),
      quality_discharge = ifelse(!"quality_discharge" %in% names(df), NA, quality_discharge),
      quality_height = ifelse(!"quality_height" %in% names(df), NA, quality_height)
    )
  
  return(df)
}

# Get list of files
files <- list.files("Data/Raw", pattern = "\\.CSV$", full.names = TRUE)

# Read, process, and combine
df1 <- bind_rows(lapply(files, process_file))

# Pivot to wide format and clean names
dat1 <- df1 %>%
  pivot_wider(names_from = "varname", values_from = "value") %>%
  janitor::clean_names()



#old code below 

# #Data Wrangle 
# 
# #Libraries
# library(tidyverse)
# library(lubridate)
# library(dplyr)
# library(readr)
# 
# # Read in all the data as you have done previously
# #Height data
# a <- read_csv("Data/Raw/113004A.H.CSV") %>%
#   mutate(time = format(time, "%Y-%m-%d %H")) %>% 
#    rename(quality_height = quality)
#     a$quality_rainfall <- NA
#     a$quality_discharge <- NA
#   
# b <- read_csv("Data/Raw/113006A.H.CSV") %>%
#     mutate(time = format(time, "%Y-%m-%d %H"))%>% 
#      rename(quality_height = quality)
#       b$quality_rainfall <- NA
#       b$quality_discharge <- NA
#  
# c <- read_csv("Data/Raw/113015A.H.CSV") %>%
#      mutate(time = format(time, "%Y-%m-%d %H")) %>% 
#      rename(quality_height = quality)
#       c$quality_rainfall <- NA
#       c$quality_discharge <- NA
#       
#     
# #Rainfall data  
# d <- read_csv("Data/Raw/114001A.R.CSV") %>%
#      mutate(time = format(time, "%Y-%m-%d %H")) %>% 
#      rename(quality_rainfall = quality)
#       d$quality_height <- NA
#       d$quality_discharge <- NA
# 
# e <- read_csv("Data/Raw/113015A.R.CSV") %>%
#      mutate(time = format(time, "%Y-%m-%d %H")) %>% 
#      rename(quality_rainfall = quality)
#       e$quality_height <- NA
#       e$quality_discharge <- NA
# 
# f <- read_csv("Data/Raw/113006A.R.CSV") %>%
#      mutate(time = format(time, "%Y-%m-%d %H")) %>% 
#      rename(quality_rainfall = quality)
#       f$quality_height <- NA
#       f$quality_discharge <- NA
# 
#       
# #Discharge data  
# g <- read_csv("Data/Raw/113015A.Q.CSV") %>%
#      mutate(time = format(time, "%Y-%m-%d %H")) %>% 
#      rename(quality_discharge = quality)
#       g$quality_rainfall <- NA
#       g$quality_height <- NA
# 
# h <- read_csv("Data/Raw/113006A.Q.CSV") %>%
#      mutate(time = format(time, "%Y-%m-%d %H")) %>% 
#      rename(quality_discharge = quality)
#       h$quality_rainfall <- NA
#       h$quality_height <- NA
#      
# i <- read_csv("Data/Raw/113004A.Q.CSV") %>%
#      mutate(time = format(time, "%Y-%m-%d %H")) %>% 
#      rename(quality_discharge = quality)
#       i$quality_rainfall <- NA
#       i$quality_height <- NA
#       
# 
# dat <- rbind(a,b,c,d,e,f,g,h,i)      
#       
#             
# 
# dat1 <- dat %>%
#   pivot_wider(names_from = "varname", values_from = "value") %>%
#   janitor::clean_names()
# 
# # df2 <- rbind(
# #   (read_csv("Data/Raw/Koombooloomba_Dam_031083_1800_Data.csv") %>%
# #      unite(col = "time", Year, Month, Day, sep = "-")),
# #   (read_csv("Data/Raw/Tully_Sugar_Mill_032042_1800_Data.csv") %>%
# #     unite(col = "time", Year, Month, Day, sep = "-"))) %>%
# #   mutate(time = as.Date(time)) %>%
# #   rename(
# #     rainfall_mm = `Rainfall amount (millimetres)`,
# #     site = `Bureau of Meteorology station number`,
# #     quality = Quality) %>%
# #   select(-`Product code`, -`Period over which rainfall was measured (days)`)
# 
# df2$discharge_cumecs <- NA
# df2$var <- NA
# df2$level_metres <- NA
# 
# column_order <- c("site", "time", "quality", "var", "rainfall_mm", "discharge_cumecs", "level_metres")
# 
# dat <- dat %>% select(all_of(column_order))
# df2 <- df2 %>% select(all_of(column_order))
# 
# 
# (names(dat))
# (names(df2))
# 
# dat_joined <- rbind(dat, df2)
# 
# dat_joined <- dat_joined %>% filter(time >= as.Date("2009-12-23") & time <= as.Date("2024-08-01"))
# 
# colnames(dat_joined)
# 
# # skimr::skim(dat_joined)
# # summarytools::dfSummary(dat_joined)
# 
# 
# write_csv(dat_joined, "Data/dat_joined.csv")

