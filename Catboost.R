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
features

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
  loss_function = "RMSE",  # "RMSE" being used for regression 
  iterations = 1000,       # If overfitting = reduce iterations, if underfitting = increase iterations
  depth = 6,               # Tree depth: common range 3-10, smaller values can prevent overfitting
  learning_rate = 0.02,     # Lower range: 0.01 - 0.05, higher range: 0.1 - 0.3
  verbose = 100,           # Show progress every 100 iterations
  l2_leaf_reg = 10,        # L2 regularization parameter (higher values prevent overfitting)
  random_seed = 42,        # Set random seed for reproducibility
  logging_level = 'Verbose', 
  od_type = 'Iter', #over fitting detector
  od_wait = 50 #If no validation improvement in 50 rounds, stop. od wait value = 5-10% of iterations 
)

# 7. Cross-validation grid search -----

cv_params <- list(
  loss_function = "RMSE",     
  iterations = 4000,          # Max iterations before early stopping kicks in, went from 1000 to 2000
  depth = 4,                  # Tree depth
  learning_rate = 0.02,       
  verbose = 100,              # Print progress every 100 rounds
  l2_leaf_reg = 20,           # Regularization
  random_seed = 42,           
  logging_level = 'Verbose'   
)


catboost_cv <- catboost.cv(
  train_pool,
  params = cv_params,
  fold_count = 5,
  type = "TimeSeries",
  partition_random_seed = 42,
  shuffle = FALSE,
  stratified = FALSE,
  early_stopping_rounds = 50
)

head(catboost_cv)

best_iter <- which.min(catboost_cv$test.RMSE.mean)
best_rmse <- min(catboost_cv$test.RMSE.mean)


catboost_cv$Iteration <- seq_len(nrow(catboost_cv))

library(ggplot2)

rmse_4000 <- ggplot(catboost_cv, aes(x = Iteration)) +
  geom_line(aes(y = test.RMSE.mean), color = "blue", linewidth = 1) +
  geom_line(aes(y = train.RMSE.mean), color = "darkgreen", linetype = "dashed") +
  geom_vline(xintercept = best_iter, color = "red", linetype = "dotted") +
  annotate("text",
           x = best_iter,
           y = best_rmse,
           label = paste("Best Iter:", best_iter),
           hjust = -0.1, vjust = -1, color = "red", size = 3.5) +
  labs(
    title = "Cross-validated RMSE vs Iteration",
    subtitle = "Blue = Validation RMSE | Dashed Green = Training RMSE",
    x = "Iteration",
    y = "RMSE"
  ) +
  theme_minimal()


# Get final training and test RMSE from the best iteration
best_iter <- which.min(catboost_cv$test.RMSE.mean)

test_rmse <- catboost_cv$test.RMSE.mean[best_iter]
train_rmse <- catboost_cv$train.RMSE.mean[best_iter]
rmse_gap_ratio <- (test_rmse - train_rmse) / train_rmse

cat("Best Iteration:", catboost_cv$Iteration[best_iter], "\n")
cat("Test RMSE:", round(test_rmse, 4), "\n")
cat("Train RMSE:", round(train_rmse, 4), "\n")
cat("RMSE Gap Ratio:", round(rmse_gap_ratio * 100, 2), "%\n")

# Interpret the gap
if (rmse_gap_ratio > 0.2) {
  cat("Likely overfitting: test RMSE is significantly higher than train RMSE.\n")
} else if (rmse_gap_ratio < 0.05) {
  if (test_rmse > 2 && train_rmse > 2) {
    cat("Likely underfitting: both RMSEs are high and close together.\n")
  } else {
    cat("Model is well balanced with minimal gap.\n")
  }
} else {
  cat("Acceptable gap between test and train RMSE — likely well-generalized.\n")
}





# 8. Train the Model ----
model <- catboost.train(train_pool, test_pool, params = params)

# 9. Make predictions ----
predictions <- catboost.predict(model, test_pool)

# 10. Evaluate model performance ----
## Metrics and stats  ----
library(Metrics)

range_y <- range(y_test[[1]])
### RMSE  ----
rmse_relative <- rmse(y_test[[1]], predictions) / diff(range_y)
cat("Relative RMSE:", round(100 * rmse_relative, 2), "%\n")

cat("RMSE:", rmse(y_test[[1]], predictions), "\n")
cat("MAE:", mae(y_test[[1]], predictions), "\n")

### R²  ----
ss_res <- sum((y_test[[1]] - predictions)^2)
ss_tot <- sum((y_test[[1]] - mean(y_test[[1]]))^2)
r_squared <- 1 - ss_res / ss_tot
cat("R²:", round(r_squared, 4), "\n")


### Prediction diagnostics  ----
results_df <- tibble(
  Actual = y_test[[1]],
  Predicted = predictions
)

ggplot(results_df, aes(x = Actual, y = Predicted)) +
  geom_point(alpha = 0.4) +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Predicted vs Actual", x = "Actual", y = "Predicted")



# Check for overfitting/ underfitting 





# 11. Evaluate feature importance  ----
## Feature importance scores ----
importance <- catboost.get_feature_importance(model, pool = train_pool, type = "FeatureImportance")
importance_df <- data.frame(Feature = features, Importance = importance)

print(head(importance_df_sorted, 10))

## Plot feature importance using ggplot ----
ggplot(importance_df_sorted, aes(x = reorder(Feature, Importance), y = Importance)) +
  geom_col() +
  coord_flip() +
  labs(title = "Feature Importance", x = "Feature", y = "Importance")





