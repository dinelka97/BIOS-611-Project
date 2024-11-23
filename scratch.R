# Example data frame
df <- data.frame(
  name = c("Alice", "Bob", "Charlie"),
  age = c(25, 30, 35),
  gender = c("F", "M", "M"),
  stringsAsFactors = FALSE
)

# Vector of column names to convert to factors
factor_cols <- c("name", "gender")

# Using apply to convert specified columns to factors
df[factor_cols] <- apply(df[factor_cols], 2, as.factor)

# Print the updated data frame
str(df)
