library("RSQLite")

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

data_Country <- lDataFrames[[1]]
data_League <- lDataFrames[[2]]
data_Match <- lDataFrames[[3]]
data_Player <- lDataFrames[[4]]
data_Player_Attriutes <- lDataFrames[[5]]
data_Team <- lDataFrames[[6]]
data_Team_Attributes <- lDataFrames[[7]]

write.table(data_Player['player_fifa_api_id'], file = 'id_players.txt') 
