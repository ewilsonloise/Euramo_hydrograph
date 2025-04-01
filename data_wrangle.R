
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
    df <- df %>% rename(quality_level = quality)
  }
  
  # Ensure all quality columns exist
  df <- df %>%
    mutate(
      quality_rainfall = ifelse(!"quality_rainfall" %in% names(df), NA, quality_rainfall),
      quality_discharge = ifelse(!"quality_discharge" %in% names(df), NA, quality_discharge),
      quality_level = ifelse(!"quality_level" %in% names(df), NA, quality_level)
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

dat1 <- dat1 %>% 
  arrange(site, time) #arraginig by site and time to ensure that the derivative calculation is correct

dat1$level_derivative <- NA #assigning a blank column for the derivative calc

dat1 <- dat1 %>% 
  mutate(level_derivative = level_metres - lag(level_metres))

write_csv(dat1, "Data/dat.csv")



