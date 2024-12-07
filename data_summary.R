library(tidyr)
library(dplyr)
library(readr)
library(glue)
library(ggplot2)

rm(list = ls())

# data summaries ----------------------------------------------------------

df <- readRDS("derived_data/df_pproc.rds")
str(df)


  ## -- labeling the column names

labels <- c(
  "Unique identifier", "Age", "Income level", 
  "Home ownership status (own, rent, mortgage, other)",
  "Length of employment", "Purpose of obtaining loan", 
  "Credibility of loan", "Loan amount", "Loan interest rate",
  "Loan amount as a percentage of income", "Default indicator",
  "Length of credit history", "Loan Approval Status"
)

d_type <- c(
  "num", "num", "num", "categorical", "num", "categorical",
  "categorical", "num", "float", "float", "categorical", "numeric",
  "categorical"
)

vars <- data.frame(
  var_name = colnames(df), label = labels, data_type = d_type
)

write.csv(vars, "derived_data/df_colLabel.csv", row.names = FALSE)

  ## -- distribution of variables (both numeric and factor)

dist_var <- function(data, type, nbins = 10){
  df <- data
  df_long <- 
    df %>%
    select(-id) %>%
    pivot_longer(cols = where(glue("is.{type}")), names_to = "variable", values_to = "value")
  
  geom_layer <- if (type == "factor") {
    geom_bar(fill = "slateblue4")
  } else {
    geom_histogram(bins = nbins, fill = "darkblue", color = "black", alpha = 0.7)
  }
  
  plot <- ggplot(df_long, aes(x = value)) +
    geom_layer +
    facet_wrap(~variable, scales = "free_x") +
    labs(title = glue("Distribution of {type} variables"), x = "", y = "Frequency") +
    theme(plot.title = element_text(hjust = 0.5, size = 17, face = "bold"),
          strip.text = element_text(size = 14),
          axis.text.x = element_text(size = 12),
          axis.text.y = element_text(size = 12),
          axis.title.y = element_text(size = 13))
  
  ggsave(glue("figures/dist_{type}.png"), plot, width = 20, height = 12.5, units = "in", dpi = 750)

}

dist_num <- dist_var(df, "numeric", nbins = 25)
dist_fac <- dist_var(df, "factor")










