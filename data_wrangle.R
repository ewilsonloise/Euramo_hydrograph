#Data Wrangle 

#Libraries
library(tidyverse)
library(lubridate)
library(dplyr)
library(readr)

# Read in all the data as you have done previously
Height_113004A <- read_csv("Data/113004A.H.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) 

Height_113006A <- read_csv("Data/113006A.H.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) 

Height_113015A <- read_csv("Data/113015A.H.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) 

Rainfall_114001A <- read_csv("Data/114001A.R.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H"))

Rainfall_113015A <- read_csv("Data/113015A.R.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) 

Rainfall_113006A <- read_csv("Data/113006A.R.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H"))  

Discharge_113015A <- read_csv("Data/113015A.Q.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) 

Discharge_113006A <- read_csv("Data/113006A.Q.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) 

Discharge_113004A <- read_csv("Data/113004A.Q.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H"))


#Site 113004A


# Tully River at Eur joined df
TRE_joined <- Rainfall_113006A %>%
  full_join(Discharge_113006A, by = c("time", "site")) %>%
  full_join(Height_113006A, by = c("time", "site")) %>%
  rename(
    site = site,
    tre_rainfall_varname = varname.x,
    tre_rainfall_var = var.x,
    time = time,
    tre_rainfall_value = value.x,
    tre_rainfall_quality = quality.x, 
    tre_discharge_varname = varname.y,
    tre_discharge_discharge = var.y,
    tre_discharge_value = value.y,
    tre_discharge_quality = quality.y, 
    tre_height_varname = varname, 
    tre_height_var = var,
    tre_height_value = value,
    tre_height_quality = quality)



write_csv(TRE_joined, "Data/TRE_Joined_df.csv")


# Tully Gorge NP joined df
TGNP_joined <- Rainfall_113015A %>%
  full_join(Discharge_113015A, by = c("time", "site")) %>%
  full_join(Height_113015A, by = c("time", "site")) %>%
  rename(
    site = site,
    tgnp_rainfall_varname = varname.x,
    tgnp_rainfall_var = var.x,
    time = time,
    tgnp_rainfall_value = value.x,
    tgnp_rainfall_quality = quality.x, 
    tgnp_discharge_varname = varname.y,
    tgnp_discharge_discharge = var.y,
    tgnp_discharge_value = value.y,
    tgnp_discharge_quality = quality.y, 
    tgnp_height_varname = varname, 
    tgnp_height_var = var,
    tgnp_height_value = value,
    tgnp_height_quality = quality)    

write_csv(TGNP_joined, "Data/TGNP_joined_df.csv")

    
CCP_joined <- Discharge_113004A %>%
  full_join(Height_113004A, by = c("time", "site")) %>%
  rename(
    ccp_discharge_varname = varname.x,
    ccp_discharge_discharge = var.x,
    ccp_discharge_value = value.x,
    ccp_discharge_quality = quality.x,
    ccp_height_varname = varname.y, 
    ccp_height_var = var.y,
    ccp_height_value = value.y,
    ccp_height_quality = quality.y)   

write_csv(CCP_joined, "Data/CCP_joined_df.csv")


MRUM_joined <- Rainfall_114001A %>% 
  rename(
   mrum_rainfall_varname = varname,
   mrum_rainfall_var = var,
   mrum_rainfall_value = value,
   mrum_rainfall_quality = quality
  )   

write_csv(MRUM_joined, "Data/MRUM_joined_df.csv")



merged_data <- CCP_joined %>%
  full_join(MRUM_joined, by = c("site", "time")) %>%
  full_join(TGNP_joined, by = c("site", "time")) %>%
  full_join(TRE_joined, by = c("site", "time"))

merged_data <- TRE_joined %>%
left_join(TGNP_joined, by = c("site", "time"))



