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
data_Player_Attriutes <- na.omit(df[[5]])

#join between position and player's attributes
data <- right_join(positions, data_Player_Attriutes, by = c("id_player_fifa" = "player_fifa_api_id"))

data <- data %>%
  filter(attacking_work_rate %in% rates &  defensive_work_rate %in% rates & position %in% field_positions$position) %>%
  select(-id, -date, -player_api_id)

##################################
#+#+#+ CHOOSING BEST ARGUMENTS #+#
##################################
data_aov <- data
#setting string to number
data_aov[data_aov$attacking_work_rate == rates[1],]$attacking_work_rate = 0
data_aov[data_aov$attacking_work_rate == rates[2],]$attacking_work_rate = 1
data_aov[data_aov$attacking_work_rate == rates[3],]$attacking_work_rate = 2
data_aov[data_aov$defensive_work_rate == rates[1],]$defensive_work_rate = 0
data_aov[data_aov$defensive_work_rate == rates[2],]$defensive_work_rate = 1
data_aov[data_aov$defensive_work_rate == rates[3],]$defensive_work_rate = 2
data_aov[data_aov$preferred_foot == preferred_foot[2],]$preferred_foot = 0
data_aov[data_aov$preferred_foot == preferred_foot[1],]$preferred_foot = 1

#join between position and player's attributes
data_aov <- left_join(field_positions, data_aov, by = c("position" = "position")) %>%
  select(-position)
colnames(data_aov)[colnames(data_aov) == 'id'] <- 'id_position'

#fitting data to anova
aov_type <- lm(id_position~.,data=data_aov)

#saving result
anova_report(aov_type, ANOVA.PATH)

#choosing only the variables with hight significance (confidance > 0.05)
data <- data %>%
  select(-id_player_fifa, -short_passing, -acceleration, -sprint_speed, -balance, -long_shots, -gk_positioning, -gk_reflexes)



f_matrix <- getFormulaMatrix(data)

model_data <- as.data.frame(model.matrix(f_matrix, data))