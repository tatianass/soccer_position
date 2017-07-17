# Responsible for converting sqllite to dataframe
#@param {SQLiteConnection} con, object with the sqllite database
#@return {data.frame} lDataFrames, dataframe object
sqllite_to_dataframe <- function(con){
  ## list all tables
  tables <- dbListTables(con)
  
  ## exclude sqlite_sequence (contains table information)
  tables <- tables[tables != "sqlite_sequence"]
  
  lDataFrames <- vector("list", length=length(tables))
  
  ## create a data.frame for each table
  for (i in seq(along=tables)) {
    lDataFrames[[i]] <- dbGetQuery(conn=con, statement=paste("SELECT * FROM '", tables[[i]], "'", sep=""))
  }
  return(lDataFrames)
}

# Responsible for saving players fifa ids
#@param {data.frame} data_Player, dataframe with the players database
savePlayersFifaIds <- function(data_Player){
  #save players fifa's id
  write.table(data_Player['player_fifa_api_id'], file = 'id_players.txt') 
}

# Responsible for saving anova report
#@param {lm} analysis, linear model fitter with information about the anova
#@param {character} type, name of the argument  
anova_report <- function(analysis, type){
  
  #anova
  #h0: they are equal, h1: they are not (p<0.05)
  anova <- aov(analysis)
  
  file_name <- " anova sumary.txt"
  file_name <- paste(type, file_name)
  s<-summary(anova)
  capture.output(s, file = file_name)
  
  name <- " plot witch 1.png"
  name <- paste(type, name)
  png(filename=name)
  #Caso queira visualizar o gráfico
  plot(analysis, which = 1)
  dev.off()
  
  name <- " plot witch 2.png"
  name <- paste(type, name)
  png(filename=name)
  #can se that there's a positive skewness in the data
  plot(analysis, which = 2)
  dev.off()
  
  sresids <- rstandard(analysis)
  
  name <- " histogram.png"
  name <- paste(type, name)
  png(filename=name)
  hist(sresids)
  dev.off()
}

# Responsible for creating the formula to be used
# in the Neural Network
#@param {data.frame}, object with the data
#@return {formula}, nn formula
getFormulaNN <- function(data){
  n <- colnames(data)
  f <- as.formula(paste(" positionCB + positionCDM + positionCM + 
    positionGK + positionLAM + positionLB + positionLCB + positionLCM + 
                        positionLDM + positionLM + positionLS + positionLW + positionRAM + 
                        positionRB + positionRCB + positionRCM + positionRDM + positionRM + 
                        positionRS + positionRW + positionST + positionSUB ~", paste(n[!n %in% c("positionCB","positionCDM","positionCM","positionGK","positionLAM","positionLB","positionLCB","positionLCM","positionLDM","positionLM","positionLS","positionLW","positionRAM","positionRB","positionRCB","positionRCM","positionRDM","positionRM","positionRS","positionRW","positionST","positionSUB", "(Intercept)")], collapse = " + ")))
  return(f)
}

# Responsible for creating the formula to be used
# in the matrix
#@param {data.frame}, object with the data
#@return {formula}, matrix formula
getFormulaMatrix <- function(data){
  n <- colnames(data)
  f <- as.formula(paste(" ~", paste(n[!n %in% ""], collapse = " + ")))
  return(f)
}

addFileExtension <- function(name, ext){
  return(paste(name, ext, sep = ""))
}