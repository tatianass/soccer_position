require("RSQLite")
require("dplyr")
require("neuralnet")

##load positions
positions <- read.csv("../data/player_positions.csv", sep = ",", header = T, stringsAsFactors = F)

##load field positions
field_positions <- read.csv("../data/positions.csv", sep = ",", header = T, stringsAsFactors = F)

## connect to db
con <- dbConnect(drv=RSQLite::SQLite(), dbname="../data/database.sqlite")
