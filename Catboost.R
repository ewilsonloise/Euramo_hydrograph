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

# dat[] <- lapply(dat, function(x) {
#   if(is.numeric(x)) {
#     # Replace NA with NaN for numeric columns
#     x[is.na(x)] <- '-9999'
#   }
#   return(x)
# })



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
target <- c("level_metres") 
features <- setdiff(names(train_data), c(target, "quality_rainfall", "quality_level", "quality_discharge", "var", "time"))  
# Exclude 'quality' columns and 'time' from features

# Convert categorical features to factor, the model should register that this is then a categorical variable bc it is a factor
train_data$site <- as.factor(train_data$site)
test_data$site <- as.factor(test_data$site)

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
  # nan_mode = "MIN"   # Missing values are not allowed and will result in an error
)

# 7. Train the Model ----
model <- catboost.train(train_pool, params = params)


# 8 Make predictions ----
predictions <- catboost.predict(model, test_pool)

# 9 Evaluate model performance ----
# library(Metrics)
# rmse(y_test, predictions)  
# mae(y_test, predictions) 

