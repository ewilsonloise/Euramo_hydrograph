# 2025 ----

# 1. Install + Load Packages ----
# library(devtools)
# library(remotes)
# library(renv)
# devtools::install_github('catboost/catboost', subdir = 'catboost/R-package')
library(catboost)
library(tidyverse)
library(rsample) 

# 2. Prep data ----
dat <- read_csv("Data/dat.csv")

# Note that catboost can't handle date/time strings
dat$time <- as.POSIXct(dat$time, format = "%Y-%m-%d %H")

dat$year <- as.numeric(format(dat$time, "%Y"))
dat$month <- as.numeric(format(dat$time, "%m"))
dat$day <- as.numeric(format(dat$time, "%d"))
dat$hour <- as.numeric(format(dat$time, "%H"))

# 3. Subset data ----
set.seed(123)

# Create a random sample
n <- nrow(dat)
train_idx <- sample(1:n, size = 0.6 * n)  # 60% for training
remaining <- setdiff(1:n, train_idx)      # Remaining 40%for test and validation

# Split remaining data into test (20%) and validation (20%)
test_idx <- sample(remaining, size = 0.5 * length(remaining)) # Uses 50% of left over data, e.g., 20% of original data
validate_idx <- setdiff(remaining, test_idx)

# Create the subsets
train_data <- dat[train_idx, ]
test_data <- dat[test_idx, ]
validate_data <- dat[validate_idx, ]

# Check that it split up correctly 
cat("Train:", nrow(train_data), "rows\n")
cat("Test:", nrow(test_data), "rows\n")
cat("Validate:", nrow(validate_data), "rows\n")

# 4. Define features and target variable  ----
target <- c("TRE_height_metres_value") 
features <- setdiff(names(train_data), c(target, # Exclude 'quality' columns and 'time' from features
                                         "TRG_height_metres_quality", "TRG_discharge_cumecs_quality", "TRG_rainfall_mm_quality", 
                                         "TRE_height_metres_value", "TRE_height_metres_quality", "TRE_discharge_cumecs_quality", 
                                         "TRE_rainfall_mm_quality", "CC_height_metres_value", "CC_height_metres_quality", 
                                         "CC_discharge_cumecs_quality", "MRU_rainfall_mm_quality", "time"))


# Convert categorical features to factor, the model should register that this is then a categorical variable bc it is a factor
train_data$TRG_site <- as.factor(train_data$TRG_site)
train_data$TRE_site <- as.factor(train_data$TRE_site)
train_data$CC_site <- as.factor(train_data$CC_site)
train_data$MRU_site <- as.factor(train_data$MRU_site)


test_data$TRG_site <- as.factor(test_data$TRG_site)
test_data$TRE_site <- as.factor(test_data$TRE_site)
test_data$CC_site <- as.factor(test_data$CC_site)
test_data$MRU_site <- as.factor(test_data$MRU_site)

# print(features)

# Split into X (features) and Y (target)
x_train <- train_data[, features]  # Feature variables for training set
y_train <- train_data[, target]    # Target variable for training set

x_test <- test_data[, features]    # Feature variables for test set
y_test <- test_data[, target]      # Target variable for test set

# 5. Pool Data for CatBoost ----
train_pool <- catboost.load_pool(
  data = x_train, 
  label = y_train)


test_pool <- catboost.load_pool(
  data = x_test, 
  label = y_test)

# 6. Define Model Parameters ----
params <- list(
  loss_function = "RMSE",  # "RMSE" being used for regression and for being able to keep the NA values 
  iterations = 1000,       # If overfitting = reduce iterations, if underfitting = increase iterations
  depth = 6,               # Tree depth: common range 3-10, smaller values can prevent overfitting
  learning_rate = 0.02,     # Lower range: 0.01 - 0.05, higher range: 0.1 - 0.3
  verbose = 100,           # Show progress every 100 iterations
  l2_leaf_reg = 10,        # L2 regularization parameter (higher values prevent overfitting)
  random_seed = 42,        # Set random seed for reproducibility
  early_stopping_rounds = 50 
)

# 7. Train the Model ----
model <- catboost.train(train_pool, params = params)


# 8 Make predictions ----
predictions <- catboost.predict(model, test_pool)

# 9 Evaluate model performance ----
# library(Metrics)
# rmse(y_test, predictions)  
# mae(y_test, predictions) 

