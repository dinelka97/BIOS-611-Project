library(tidyr)
library(dplyr)
library(glue)
library(ggplot2)
library(Rtsne)

# load data ---------------------------------------------------------------

## this is the data that has already been pre-processed

df_comp <- readRDS("derived_data/df_pproc.rds")
df_remout <- readRDS("derived_data/df_remout.rds")
#str(df)

set.seed(123)

# PCA ---------------------------------------------------------------------

pca <- function(data, label=NULL){
  df <- data
  df_numeric <- df[,sapply(df, is.numeric)] %>% select(-id)
  pca <- prcomp(df_numeric, center = TRUE, scale = TRUE)
  
  title_add <- ifelse(label == "", "(not removing outliers)", "(after removing outliers)")
  
  df_pca <- data.frame(pca$x)
  df_pca$loan_status <- df$loan_status
  
  ## -- how many PCs explain a good amount of variance?
  
  var <- pca$sdev^2 / sum(pca$sdev^2)  # Variance explained by each component
  cumvar <- cumsum(var)
  df_scree <- data.frame(x = factor(glue("PC{1:7}"), levels = c(glue("PC{1:7}"))), var = var, cumvar = cumvar)
  
  var_exp <- ggplot(data=df_scree, aes(x = x)) +
    geom_bar(aes(y = var), stat = "identity", fill = "slateblue4", alpha = 0.8) +
    geom_point(aes(y = cumvar), color = "darkred", size = 2) +
    geom_line(aes(y = cumvar, group = 1), color = "darkred") +
    labs(
      title = glue("PC variance explained {title_add}"),
      x = "Principal Component",
      y = "Variance Explained",
      fill = "Variance"
    ) +
    theme(plot.title = element_text(hjust = 0.5, size = 18, face = "bold"),
          axis.title.x = element_text(size = 13),
          axis.title.y = element_text(size = 13))
  
  ggsave(glue("figures/pca_scree{label}.png"), var_exp, width = 20, height = 12.5, units = "in", dpi = 750)
  
  ## -- visualize the PCA results (PC1 vs PC2)
  
  pc1_pc2 <- ggplot(data=df_pca, aes(x = PC1, y = PC2, color = loan_status)) +
    geom_point() +
    scale_color_manual(values = c("1" = "darkblue", "0" = "palegreen4")) +
    labs(title = glue("Visualizing PC1 vs PC2 {title_add}")) +
    theme(plot.title = element_text(hjust = 0.5, size = 18, face = "bold"),
          axis.title.x = element_text(size = 13),
          axis.title.y = element_text(size = 13))
  
  ggsave(glue("figures/pc1_pc2{label}.png"), pc1_pc2, width = 20, height = 12.5, units = "in", dpi = 750)
  
}

pca(df_comp, label = "")
pca(df_remout, label = "_rem_outliers")



# tSNE --------------------------------------------------------------------

tsne <- function(data, label=NULL){
  df <- data
  unique_index <- which(!duplicated(df[,sapply(df, is.numeric)] %>% select(-id)))
  df_numeric <- df[!duplicated(df[,sapply(df, is.numeric)] %>% select(-id)),]
  
  tsne_result <- Rtsne(df_numeric, dims = 2, perplexity = 3, pca = FALSE, 
                       verbose = TRUE, max_iter = 100)
  
  loan_status <- df[unique_index,"loan_status"]
  
  title_add <- ifelse(label == "", "(not removing outliers)", "(after removing outliers)")
  
  tsne_data <- data.frame(
    tSNE1 = tsne_result$Y[, 1],
    tSNE2 = tsne_result$Y[, 2],
    loan_status = loan_status$loan_status
  )
  
  ## -- visualize the tSNE results
  
  tsne_img <-
    ggplot(tsne_data, aes(x = tSNE1, y = tSNE2, color = loan_status)) +
      geom_point() +
      scale_color_manual(values = c("1" = "darkblue", "0" = "palegreen4")) +
      labs(title = glue("Visualizing tSNE1 vs tSNE2 {title_add}")) +
      theme(plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
            axis.title.x = element_text(size = 13),
            axis.title.y = element_text(size = 13))
  
  ggsave(glue("figures/tsne{label}.png"), tsne_img, width = 20, height = 12.5, units = "in", dpi = 750)
  
}

tsne(df_comp, label = "")
tsne(df_remout, label = "_rem_outliers")








