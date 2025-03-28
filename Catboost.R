
#26/03/2025

## 1. Install + Load Packages
library(devtools)
library(remotes)
library(renv)
# devtools::install_github('catboost/catboost', subdir = 'catboost/R-package')
library(catboost)

## 2. Prep data
dat <- read_csv("Data/dat.csv")

categorical_features <- c("site")

dat$time <- as.POSIXct(dat$time, format = "%Y-%m-%d %H")

dat$year <- as.numeric(format(dat$time, "%Y"))
dat$month <- as.numeric(format(dat$time, "%m"))
dat$day <- as.numeric(format(dat$time, "%d"))
dat$hour <- as.numeric(format(dat$time, "%H"))  # note that this is NA if there is no hour value (i.e. for BOM sites )
dat <- dat %>% select(-time)

## Prepare data for training
# Split data to train, validation and test by date.
# 
# last_train_date <- dat$year = 2024, 8, 1)
# last_val_date = pd.Timestamp(2020, 3, 24)
# last_test_date = pd.Timestamp(2020, 4, 23)
# 
# train_df = main_df[main_df['Date'] <= last_train_date].copy()
# val_df = main_df[(main_df['Date'] > last_train_date) & (main_df['Date'] <= last_eval_date)].copy()
# test_df = main_df[main_df['Date'] > last_eval_date].copy()



## Train a model
training_pool <- catboost.load_pool(
  data = dat[, c("site", "rainfall_mm", "discharge_cumecs", "level_metres", 
                 "year", "month", "day", "hour")], 
  label = dat$level_metres,
  cat_features = which(names(dat) %in% categorical_features)  # Indices of categorical variables
)
