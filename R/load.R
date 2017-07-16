require("RSQLite")
require("dplyr")
require("neuralnet")
require("h2o")

#inicialize h2o
localH2O = h2o.init()

##load positions
positions <- read.csv("../data/player_positions.csv", sep = ",", header = T, stringsAsFactors = F)

##load field positions
field_positions <- read.csv("../data/positions.csv", sep = ",", header = T, stringsAsFactors = F)

## connect to db
con <- dbConnect(drv=RSQLite::SQLite(), dbname="../data/database.sqlite")
