library(tidyverse)
library(magrittr)
library(ggplot2)
library(LaplacesDemon)
library(SuperLearner)
library(nnls)
library(mgcv)
library(earth)
library(data.table)
library(rmutil)
library(ranger)
library(xgboost)
library(Matrix)
library(splines)
library(xtable)
library(caret)
library(mvtnorm)
library(arm)
library(polspline)
library(pROC)
library(PRROC)
library(randomForest)
library(glue)

# load data ---------------------------------------------------------------
  
  ## this is the data that has already been pre-processed

df <- readRDS("derived_data/df_pproc.rds")
str(df)

# model building ---------------------------------------------------------

  ## because we want to compare methods need to ensure the same set of cross validation sets are used. Also ensure class balance.
set.seed(123)
k <- 10
df_0 <- df[df$loan_status == 0, ]
df_1 <- df[df$loan_status == 1, ]

folds <- lapply(1:k, function(i) {
  indices_0 <- sample(seq_len(nrow(df_0)), size = nrow(df_0) / k)
  indices_1 <- sample(seq_len(nrow(df_1)), size = nrow(df_1) / k)
  index <- c(indices_0, indices_1)
})

  # -- Check class balance
  #lapply(folds, function(f) table(f$loan_status))

X <- df %>% dplyr::select(-id, -loan_status)

  ## -- the super learner package algorithm did not work as expected. Can implement this manually (for both random forest & GLM)

cv_fit <- lapply(1:k, function(i) {
  train_data <- df[Reduce(c, folds[-i]), ] %>% dplyr::select(-id)
  
  glm <- glm(loan_status ~ ., data = train_data, family = "binomial")
  random_forest <- randomForest(loan_status ~ ., data = train_data)
  
  print(glue("CV fold {i} completed"))
  
  list(glm = glm, rf = random_forest)
  
})

model_eval <- function(method){
  arg_type = ifelse(method == "glm", "response", "prob")
  
  a <- lapply(1:k, function(i){
    test_data = df[folds[[i]], ] %>% dplyr::select(-id, -loan_status)
    pred_prob = predict(cv_fit[[i]][[method]], newdata = test_data, type = arg_type)
    
    if (method == "glm") {
      pred_cat <- as.numeric(unname(pred_prob) > 0.5)
    } else {
      pred_cat <- as.numeric(as.data.frame(pred_prob)[, 2] > 0.5)
    }
    
    true_cat = df$loan_status[Reduce(c, folds[i])]
    true_cat = ifelse(true_cat == 1, 0, 1)
    
    pr = pr.curve(scores.class0 = pred_cat[true_cat == 0],
                   scores.class1 = pred_cat[true_cat == 1],
                   curve = TRUE)
    list(pr_auc = pr$auc.integral, pred_prob = unname(pred_prob), true = true_cat, curve = pr$curve)
  })
    return(a)
}

aupc <- lapply(c("glm", "rf"), model_eval) ## obtain area under curve for both logistic regression and random forest
names(aupc) <- c("glm", "rf")
aupc[["glm"]]
aupc[["rf"]]

  ## -- try an ensemble learning, mixing the two using a logistic regression with the fitted probabilities from the 2 as the covariates

## -- fit the models again and obtain the fitted probabilities

ensemble <- function(method){
  arg_type = ifelse(method == "glm", "response", "prob")
  
  a <- lapply(1:k, function(i){
    test_data = df[folds[[i]], ] %>% dplyr::select(-id, -loan_status)
    #pred_prob = predict(cv_fit[[i]][[method]], newdata = test_data, type = arg_type)
    
    if (method == "glm") {
      pred_prob <- predict(cv_fit[[i]][[method]], newdata = test_data, type = arg_type)
    } else {
      pred_prob <- as.numeric(predict(cv_fit[[i]][[method]], newdata = test_data, type = arg_type)[,2])
    }
    
    list(pred_prob = unname(pred_prob))
  })
  return(a)
}

learners <- c("glm", "rf")
names(a) <- learners


## use predicted probabilities and truth to build a precision-recall curve



# Combine predictions across folds
stacked_predictions <- data.frame(
  glm = unname(unlist(ensemble("glm"))),
  rf = unname(unlist(ensemble("rf"))),
  true = unlist(lapply(1:k, function(i) df$loan_status[folds[[i]]]))
)

  ## -- ensemble model
meta_model <- glm(true ~ glm + rf, data = stacked_predictions, family = "binomial")

  ## -- extract weights

weights <- coef(meta_model)[-1]  # Exclude the intercept
weights <- pmin(weights / sum(weights), 1)  # Normalize to sum to 1
print(weights)

  ## -- under this sense using only a random forest model is probably the best way forward (or is it?)

## -- train model using random forest
df_train <- df %>% dplyr::select(-id)
rf_fit <- randomForest(loan_status ~ ., data = df %>% dplyr::select(-id))

  ## -- save model to be used in the RShiny interface

save(rf_fit, file = "loan_approval_prediction/rf_trained_model.RData")
saveRDS(df_train, "loan_approval_prediction/df_train.rds")







