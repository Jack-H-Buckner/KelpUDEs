
library(readr)
library(dplyr)

# Define the file path
file_path <- "/Users/johnbuckner/github/KelpUDEs/covars/meiv2.data"

# Read the entire file to check its structure
raw_lines <- read_lines(file_path)

# Identify the valid data range (e.g., skipping first line and removing last few lines)
start_line <- 2  # Assuming the first line is the header
end_line <- length(raw_lines) - 4  # Adjust to remove extra footer lines

# Extract only the valid lines
cleaned_data <- raw_lines[start_line:end_line]

# Write the cleaned lines to a temporary file for structured reading
temp_file <- tempfile(fileext = ".txt")
writeLines(cleaned_data, temp_file)

# Read the cleaned data into a dataframe
df <- as.data.frame(read_table(file_path, 
                               #delim = " ",   # Specify tab as the delimiter
                               col_names = FALSE,  # Prevent treating the first row as column names
                               skip = 2,  # Skip the first unwanted line
                               n_max = 45) ) # Read only the valid range

names(df) <- c("year","1","2","3","4","5","6","7","8","9","10","11","12")

dat <- df %>% reshape2::melt(id.var="year")%>%
  mutate(year = year + (as.numeric(variable)-1)/12)%>%
  select(year,value)

names(dat) <- c("year","enso")
dat <- dat[order(dat$year),]
head(dat)

write.csv(dat, "/Users/johnbuckner/github/KelpUDEs/processed_data/mei.csv")



