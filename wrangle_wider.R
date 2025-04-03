
# #Data Wrangle 
# 
# #Libraries
library(tidyverse)
library(lubridate)
library(dplyr)
library(readr)

#Cochable_Creek height 
a <- read_csv("Data/Raw/113004A.H.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) %>% 
  rename(height_metres_value = value) %>% 
  rename(height_cumecs_quality = quality)
aa <- a %>%
  pivot_wider(
    names_from = varname,
    values_from = c(height_metres_value, height_metres_value, site),
    names_glue = "Cochable_Creek_{.value}"
  ) %>% 
  select(-var)

#Cochable_Creek discharge 
i <- read_csv("Data/Raw/113004A.Q.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H")) %>% 
  rename(discharge_cumecs_value = value) %>% 
  rename(discharge_cumecs_quality = quality)
ii <- i %>%
  pivot_wider(
    names_from = varname,
    values_from = c(discharge_cumecs_value, discharge_cumecs_quality, site),
    names_glue = "Cochable_Creek_{.value}"
  ) %>% 
  select(-var)

test <- left_join(aa, ii, by = c("time" = "time", "Cochable_Creek_site" = "Cochable_Creek_site"))

# --------------------------------------------------------------    
    

b <- read_csv("Data/Raw/113006A.H.CSV") %>%
    mutate(time = format(time, "%Y-%m-%d %H"))%>%
  rename(height_metres_value = value) %>% 
  rename(height_cumecs_quality = quality)
bb <- b %>%
  pivot_wider(
    names_from = varname,
    values_from = c(height_metres_value, height_metres_value, site),
    names_glue = "Tully_Euramo_{.value}"
  ) %>% 
  select(-var)
      
      f <- read_csv("Data/Raw/113006A.R.CSV") %>%
           mutate(time = format(time, "%Y-%m-%d %H")) %>%
           rename(quality_rainfall = quality)

            


            h <- read_csv("Data/Raw/113006A.Q.CSV") %>%
                 mutate(time = format(time, "%Y-%m-%d %H")) %>%
                 rename(quality_discharge = quality)


      
      

c <- read_csv("Data/Raw/113015A.H.CSV") %>%
     mutate(time = format(time, "%Y-%m-%d %H")) %>%
     rename(quality_height = quality)
      c$quality_rainfall <- NA
      c$quality_discharge <- NA
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

# 
#       
# #Discharge data  
# g <- read_csv("Data/Raw/113015A.Q.CSV") %>%
#      mutate(time = format(time, "%Y-%m-%d %H")) %>% 
#      rename(quality_discharge = quality)
#       g$quality_rainfall <- NA
#       g$quality_height <- NA

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