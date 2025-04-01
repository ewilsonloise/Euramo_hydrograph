
#26/03/2025

## 1. Install + Load Packages
library(devtools)
library(remotes)
library(renv)
# devtools::install_github('catboost/catboost', subdir = 'catboost/R-package')
library(catboost)
library(tidyverse)
library(rsample) 

## 2. Prep data
dat <- read_csv("Data/dat.csv")

categorical_features <- c("site")

dat$time <- as.POSIXct(dat$time, format = "%Y-%m-%d %H")

dat$year <- as.numeric(format(dat$time, "%Y"))
dat$month <- as.numeric(format(dat$time, "%m"))
dat$day <- as.numeric(format(dat$time, "%d"))
dat$hour <- as.numeric(format(dat$time, "%H"))


set.seed(123)

# Create a random sample of row indices
n <- nrow(dat)
train_idx <- sample(1:n, size = 0.6 * n)  # 60% for training
remaining <- setdiff(1:n, train_idx)      # Remaining 40%

# Split remaining data into test (20%) and validation (20%)
#note that this method was used to ensure that there is no repeated data being used
test_idx <- sample(remaining, size = 0.5 * length(remaining)) #uses 50% of left over data, e.g. 20% of OG data
validate_idx <- setdiff(remaining, test_idx)

# Create the subsets
train_data <- dat[train_idx, ]
test_data <- dat[test_idx, ]
validate_data <- dat[validate_idx, ]

#check that it split up correctly 
cat("Train:", nrow(train_data), "rows\n")
cat("Test:", nrow(test_data), "rows\n")
cat("Validate:", nrow(validate_data), "rows\n")



  




## Train a model
training_pool <- catboost.load_pool(
  data = dat[, c("site", "rainfall_mm", "discharge_cumecs", "level_metres", 
                 "year", "month", "day", "hour")], 
  label = dat$level_metres,
  cat_features = which(names(dat) %in% categorical_features)  # Indices of categorical variables
)
