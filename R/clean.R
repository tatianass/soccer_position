##################################
#+#+#+ DECLARING VARIABLES #+#+#+#
##################################
rates <- c("low", "medium", "high")
preferred_foot <- c("right", "left")
ANOVA.PATH <- "analysis/position"

##################################
#+#+#+ REMOVING UNNECESSARY DATA #
##################################
#cleaning data, removing data that are not classified in rates
df <- sqllite_to_dataframe(con)

## create individual data.frames
## omiting na's
data_Country <- na.omit(df[[1]])
data_League <- na.omit(df[[2]])
data_Match <- na.omit(df[[3]])
data_Player <- na.omit(df[[4]])
data_Player_Attriutes <- na.omit(df[[5]])
data_Team <- na.omit(df[[6]])
data_Team_Attributes <- na.omit(df[[7]])

#join between position and player's attributes
data <- right_join(positions, data_Player_Attriutes, by = c("id_player_fifa" = "player_fifa_api_id"))

data <- data %>%
  filter(attacking_work_rate %in% rates &  defensive_work_rate %in% rates) %>%
  select(-id, -date, -player_api_id)

#setting string to number
data[data$attacking_work_rate == rates[1],]$attacking_work_rate = 0
data[data$attacking_work_rate == rates[2],]$attacking_work_rate = 1
data[data$attacking_work_rate == rates[3],]$attacking_work_rate = 2
data[data$defensive_work_rate == rates[1],]$defensive_work_rate = 0
data[data$defensive_work_rate == rates[2],]$defensive_work_rate = 1
data[data$defensive_work_rate == rates[3],]$defensive_work_rate = 2
data[data$preferred_foot == preferred_foot[2],]$preferred_foot = 0
data[data$preferred_foot == preferred_foot[1],]$preferred_foot = 1

#join between position and player's attributes
data <- left_join(field_positions, data, by = c("position" = "position")) %>%
  select(-position)
colnames(data)[colnames(data) == 'id'] <- 'id_position'

##################################
#+#+#+ CHOOSING BEST ARGUMENTS #+#
##################################
#fitting data to anova
aov_type <- lm(id_position~.,data=data)

#saving result
anova_report(aov_type, ANOVA.PATH)

#choosing only the 
data <- data %>%
  select(-id_player_fifa, -short_passing, -acceleration, -sprint_speed, -balance, -long_shots, -gk_positioning, -gk_reflexes)
