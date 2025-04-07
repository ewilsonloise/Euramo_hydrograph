
# Data Wrangle 

# Libraries
library(tidyverse)
library(lubridate)
library(dplyr)
library(readr)

# -----------------------------------------------------------
# 113004A Cochable Creek at Powerline

# Cochable_Creek height data
cc_h <- read_csv("Data/Raw/113004A.H.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) %>% 
  rename(height_metres_value = value) %>% 
  rename(height_metres_quality = quality)%>%
  arrange(site, time) %>%
  mutate(height_deriv_value = height_metres_value - lag(height_metres_value))

cc_h <- cc_h %>%
  pivot_wider(
    names_from = varname,
    values_from = c(site, height_metres_value, height_deriv_value, height_metres_quality),
    names_glue = "CC_{.value}"
  ) %>% 
  select(-var)

# Cochable_Creek discharge data
cc_d <- read_csv("Data/Raw/113004A.Q.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) %>% 
  rename(discharge_cumecs_value = value) %>% 
  rename(discharge_cumecs_quality = quality)

cc_d <- cc_d %>%
  pivot_wider(
    names_from = varname,
    values_from = c(discharge_cumecs_value, discharge_cumecs_quality, site),
    names_glue = "CC_{.value}"
  ) %>% 
  select(-var)

cc_dat <- left_join(cc_h, cc_d, by = c("CC_site" = "CC_site", "time" = "time"))

# --------------------------------------------------------------    
# 113006A Tully River at Euramo

# Tully River at Euramo Rainfall data  
tre_r <- read_csv("Data/Raw/113006A.R.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) %>%
  rename(rainfall_mm_value = value) %>% 
  rename(rainfall_mm_quality = quality)

tre_r <- tre_r %>%
  pivot_wider(
    names_from = varname,
    values_from = c(rainfall_mm_value, rainfall_mm_quality, site),
    names_glue = "TRE_{.value}"
  ) %>% 
  select(-var)

# Tully River at Euramo Height data  
tre_h <- read_csv("Data/Raw/113006A.H.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) %>%
  rename(height_metres_value = value,
         height_metres_quality = quality) %>%
  arrange(site, time) %>%
  mutate(height_deriv_value = height_metres_value - lag(height_metres_value)) %>%
  pivot_wider(
    names_from = varname,
    values_from = c(site, height_metres_value, height_deriv_value, height_metres_quality),
    names_glue = "TRE_{.value}"
  ) %>%
  select(-var)

# Tully River at Euramo Discharge data  
tre_d <- read_csv("Data/Raw/113006A.Q.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) %>% 
  rename(discharge_cumecs_value = value) %>% 
  rename(discharge_cumecs_quality = quality)

tre_d <- tre_d %>%
  pivot_wider(
    names_from = varname,
    values_from = c(discharge_cumecs_value, discharge_cumecs_quality, site),
    names_glue = "TRE_{.value}"
  ) %>% 
  select(-var)

tre_dat <- left_join(tre_h, tre_d, by = c("TRE_site" = "TRE_site", "time" = "time"))
tre_dat <- left_join(tre_dat, tre_r, by = c("TRE_site" = "TRE_site", "time" = "time"))

# ---------------------------------------------------
# 113015A Tully River at Tully Gorge National Park      

# Tully River at Tully Gorge National Park Height data  
trg_h <- read_csv("Data/Raw/113015A.H.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) %>%
  rename(height_metres_value = value) %>% 
  rename(height_metres_quality = quality)%>%
  arrange(site, time) %>%
  mutate(height_deriv_value = height_metres_value - lag(height_metres_value)) 

trg_h <- trg_h %>%
  pivot_wider(
    names_from = varname,
    values_from = c(site, height_metres_value, height_deriv_value, height_metres_quality),
    names_glue = "TRG_{.value}"
  ) %>% 
  select(-var)

# Tully River at Tully Gorge National Park Rainfall data  
trg_r <- read_csv("Data/Raw/113015A.R.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) %>%
  rename(rainfall_mm_value = value) %>% 
  rename(rainfall_mm_quality = quality)

trg_r <- trg_r %>%
  pivot_wider(
    names_from = varname,
    values_from = c(rainfall_mm_value, rainfall_mm_quality, site),
    names_glue = "TRG_{.value}"
  ) %>% 
  select(-var)

# Tully River at Tully Gorge National Park Discharge data  
trg_d <- read_csv("Data/Raw/113015A.Q.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) %>% 
  rename(discharge_cumecs_value = value) %>% 
  rename(discharge_cumecs_quality = quality)

trg_d <- trg_d %>%
  pivot_wider(
    names_from = varname,
    values_from = c(discharge_cumecs_value, discharge_cumecs_quality, site),
    names_glue = "TRG_{.value}"
  ) %>% 
  select(-var)

trg_dat <- left_join(trg_h, trg_d, by = c("TRG_site" = "TRG_site", "time" = "time"))
trg_dat <- left_join(trg_dat, trg_r, by = c("TRG_site" = "TRG_site", "time" = "time"))

# ------------------------------------------------------------
# 114001A Murray River at Upper Murray

# Murray River at Upper Murray Rainfall data  
mru_r <- read_csv("Data/Raw/114001A.R.CSV") %>%
  mutate(time = format(time, "%Y-%m-%d %H")) %>%
  rename(rainfall_mm_value = value) %>% 
  rename(rainfall_mm_quality = quality)

mru_r <- mru_r %>%
  pivot_wider(
    names_from = varname,
    values_from = c(rainfall_mm_value, rainfall_mm_quality, site),
    names_glue = "MRU_{.value}"
  ) %>% 
  select(-var)

# ---------------------------------------------------------------   

dat1 <- left_join(trg_dat, tre_dat, by = c("time" = "time"))
dat2 <- left_join(cc_dat, mru_r, by = c("time" = "time"))

dat <- left_join(dat1, dat2, by = c("time" = "time"))

# vis_miss(dat, warn_large_data = FALSE) #note only 3 cells have NAa, but they need to be removed 
dat_na <- na.omit(dat) #remove the three rows with NA values 

# vis_miss(dat_na, warn_large_data = FALSE) # data is 100% present 

write_csv(dat, "Data/dat.csv")


dat_lag <- dat %>%  select(c(time, TRE_height_metres_value, TRG_rainfall_mm_value))

dat_lag <- dat_lag %>%
  mutate(
    rain = TRG_rainfall_mm_value,
    height = TRE_height_metres_value
  )
 
model <- lm(height ~ rain, data = dat_lag)

