library("RSQLite")
require("dplyr")

##load positions
positions <- read.csv("../data/player_positions.csv", sep = ",", header = T, stringsAsFactors = F)

##load field positions
field_positions <- read.csv("../data/positions.csv", sep = ",", header = T, stringsAsFactors = F)

## connect to db
con <- dbConnect(drv=RSQLite::SQLite(), dbname="../data/database.sqlite")

## list all tables
tables <- dbListTables(con)

## exclude sqlite_sequence (contains table information)
tables <- tables[tables != "sqlite_sequence"]

lDataFrames <- vector("list", length=length(tables))

## create a data.frame for each table
for (i in seq(along=tables)) {
  lDataFrames[[i]] <- dbGetQuery(conn=con, statement=paste("SELECT * FROM '", tables[[i]], "'", sep=""))
}

## create individual data.frames
## omiting na's
data_Country <- na.omit(lDataFrames[[1]])
data_League <- na.omit(lDataFrames[[2]])
data_Match <- na.omit(lDataFrames[[3]])
data_Player <- na.omit(lDataFrames[[4]])
data_Player_Attriutes <- na.omit(lDataFrames[[5]])
data_Team <- na.omit(lDataFrames[[6]])
data_Team_Attributes <- na.omit(lDataFrames[[7]])

#save players fifa's id
write.table(data_Player['player_fifa_api_id'], file = 'id_players.txt') 

#join between position and player's attributes
data <- right_join(positions, data_Player_Attriutes, by = c("id_player_fifa" = "player_fifa_api_id"))

#cleaning data, removing data that are not classified in rates
rates <- c("low", "medium", "high")
data <- data %>%
  filter(attacking_work_rate %in% rates &  defensive_work_rate %in% rates) %>%
  select(-id, -date, -player_api_id)

#setting string to number
data[data$attacking_work_rate == "low",]$attacking_work_rate = 0
data[data$attacking_work_rate == "medium",]$attacking_work_rate = 1
data[data$attacking_work_rate == "high",]$attacking_work_rate = 2
data[data$defensive_work_rate == "low",]$defensive_work_rate = 0
data[data$defensive_work_rate == "medium",]$defensive_work_rate = 1
data[data$defensive_work_rate == "high",]$defensive_work_rate = 2
data[data$preferred_foot == "left",]$preferred_foot = 0
data[data$preferred_foot == "right",]$preferred_foot = 1

#join between position and player's attributes
data <- left_join(field_positions, data, by = c("position" = "position")) %>%
  select(-position)
colnames(data)[colnames(data) == 'id'] <- 'id_position'
