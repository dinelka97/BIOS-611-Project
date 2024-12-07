# libraries ---------------------------------------------------------------
library(magrittr)
library(tidyverse)
library(magrittr)
library(ggplot2)
library(pROC)
library(readr)
library(glue)

# load data -----------------------------------------------------------
rm(list = ls())
df <- read_csv("src_data/train.csv")

# data formatting ---------------------------------------------------------
class(df);str(df)
glimpse(df)
factor_cols <- c("person_home_ownership", "loan_intent", "loan_grade", 
                 "cb_person_default_on_file", "loan_status")
numeric_cols <- c("person_age", "person_income", "person_emp_length", "loan_amnt", "loan_int_rate", "loan_percent_income",
                  "cb_person_cred_hist_length")

df[factor_cols] <- lapply(df[factor_cols], as.factor)
df[numeric_cols] <- lapply(df[numeric_cols], as.numeric)

str(df)

  ## -- some variables have long categories (actually just loan_intent)

levels(df$loan_intent) <- c("debt_rec", "edu", "home", "med", "personal", "bus")

  ## -- outlier detection
det_out <- function(data){
  df <- data
  df_long <- 
    df %>%
    select(-id) %>%
    pivot_longer(cols = where(is.numeric), names_to = "variable", values_to = "value")
  
  plot <- ggplot(df_long, aes(x = value)) +
    geom_boxplot(outlier.colour = "darkred") +
    facet_wrap(~variable, scales = "free_x") +
    labs(title = glue("Detecting Outliers"), x = "", y = "Frequency") +
    theme(plot.title = element_text(hjust = 0.5, size = 17, face = "bold"),
          strip.text = element_text(size = 14),
          axis.text.x = element_text(size = 12),
          axis.text.y = element_text(size = 12),
          axis.title.y = element_text(size = 13))
  
  #return(plot)
  ggsave(glue("figures/outliers.png"), plot, width = 15, height = 10, units = "in", dpi = 750)
  
}

det_out(df)

## -- remove outliers

rem_out <- function(col){
  if (is.numeric(col)) {
    lower_bound <- quantile(col, 0.25) - 1.5 * IQR(col)
    upper_bound <- quantile(col, 0.75) + 1.5 * IQR(col)
    return(col >= lower_bound & col <= upper_bound)
  } else {
    return(rep(TRUE, length(col)))  # Non-numeric columns are kept as is
  }
}

outliers_removed <- sapply(df, rem_out)

df_remout <- df[apply(outliers_removed, 1, all), ] # dataframe after removing outliers


## -- discrepant data points (age == 125)

df %<>%
  filter(!person_age > 100 | person_emp_length > 100)


## -- missing values

length(which(rowSums(is.na(df)) > 0)) == 0

## -- check for duplicates

unique(df %>% select(-id))

## export final pre-processed data

saveRDS(df, "derived_data/df_pproc.rds")
saveRDS(df_remout, "derived_data/df_remout.rds")






