require("RSQLite")
require("dplyr")
require("neuralnet")
# Load the H2O library and start up the H2O cluster locally on your machine
library(h2o)
h2o.init(nthreads = -1, #Number of threads -1 means use all cores on your machine
         max_mem_size = "8G")  #max mem size is the maximum memory to allocate to H2O

##load positions
positions <- read.csv("../data/player_positions.csv", sep = ",", header = T, stringsAsFactors = F)

##load field positions
field_positions <- read.csv("../data/positions.csv", sep = ",", header = T, stringsAsFactors = F)

## connect to db
con <- dbConnect(drv=RSQLite::SQLite(), dbname="../data/database.sqlite")
