library(terra)
library(stringr)

raw <- read.csv(path, stringsAsFactors = FALSE)

df <- data.frame(
  coord = raw[11:19, 9],
  temp  = raw[11:19, 13])


df$coord <- iconv(df$coord, from = "latin1", to = "UTF-8")
df$coord <- trimws(df$coord)

pattern <- "^([NS])\\s*(\\d+)\\D+(\\d+(?:\\.\\d+)?)'\\s*([EW])\\s*(\\d+)\\D+(\\d+(?:\\.\\d+)?)'\\s*$"
m <- str_match(df$coord, pattern)m
