# libraries ---------------------------------------------------------------

library(tidyverse)
library(magrittr)
library(ggplot2)

# load data -----------------------------------------------------------

setwd("src_data/")
df_train <- read_csv("train.csv")
df_test <- read_csv("test.csv")
df <- bind_rows(df_train, df_test)


# data formatting ---------------------------------------------------------

factor_cols <- c("person_home_ownership", "loan_intent", "loan_grade", 
                 "cb_person_default_on_file", "loan_status")

df[factor_cols] <- lapply(df[factor_cols], as.factor)


# descriptive/summary stats -----------------------------------------------

  ## data distributions of the numeric variables

# Pivot the data to long format for ggplot2
df_long <- 
  df %>%
  select(-id) %>%
  pivot_longer(cols = where(is.numeric), names_to = "variable", values_to = "value")

# Plot histograms for each numeric variable
ggplot(df_long, aes(x = value)) +
  geom_histogram(bins = 30, fill = "blue", color = "black", alpha = 0.7) +
  facet_wrap(~variable, scales = "free_x") +
  labs(title = "Histograms of Numeric Variables", x = "Value", y = "Frequency")







