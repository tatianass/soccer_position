source("load.R")
source("func.R")
source("clean.R")


txt_ext <- ".txt"
png_ext <- ".png"
csv_ext <- ".csv"

##################################
#+#+#+ SPLITTING (TRAIN/TEST) #+#+
##################################

f_matrix <- getFormulaMatrix(data)

model_data <- as.data.frame(model.matrix(f_matrix, data))

n_label <- "positionCB"
y <- c("positionCB","positionCDM","positionCM","positionGK","positionLAM","positionLB","positionLCB","positionLCM","positionLDM","positionLM","positionLS","positionLW","positionRAM","positionRB","positionRCB","positionRCM","positionRDM","positionRM","positionRS","positionRW","positionST","positionSUB")
x <- setdiff(names(model_data), c(y, "(Intercept)"))

#transform dataframe dummies to matrix
model_data <- as.h2o(model_data)

model_data[, 2:23] <- lapply(model_data[, 2:23], as.factor)
model_data$positionCB <- as.factor(model_data$positionCB)
levels(model_data$positionCB)

# Partition the data into training, validation and test sets
splits <- h2o.splitFrame(data = model_data, 
                         ratios = c(0.7, 0.15),  #partition data into 70%, 15%, 15% chunks
                         seed = 1)  #setting a seed will guarantee reproducibility
train <- splits[[1]]
valid <- splits[[2]]
test <- splits[[3]]
##################################
#+#+#+ NEURAL NETWORk H2O #+#+#+#+
##################################
for(n_label in y){
  # Train a default DL
  # First we will train a basic DL model with default parameters. The DL model will infer the response 
  # distribution from the response encoding if it is not specified explicitly through the `distribution` 
  # argument.  H2O's DL will not be reproducible if it is run on more than a single core, so in this example, 
  # the performance metrics below may vary slightly from what you see on your machine.
  # In H2O's DL, early stopping is enabled by default, so below, it will use the training set and 
  # default stopping parameters to perform early stopping.
  dl_fit1 <- h2o.deeplearning(x = x,
                              y = n_label,
                              training_frame = train,
                              model_id = "dl_fit1",
                              seed = 1)
  
  # Train a DL with new architecture and more epochs.
  # Next we will increase the number of epochs used in the GBM by setting `epochs=20` (the default is 10).  
  # Increasing the number of epochs in a deep neural net may increase performance of the model, however, 
  # you have to be careful not to overfit your model to your training data.  To automatically find the optimal number of epochs, 
  # you must use H2O's early stopping functionality.  Unlike the rest of the H2O algorithms, H2O's DL will 
  # use early stopping by default, so for comparison we will first turn off early stopping.  We do this in the next example 
  # by setting `stopping_rounds=0`.
  dl_fit2 <- h2o.deeplearning(x = x,
                              y = n_label,
                              training_frame = train,
                              model_id = "dl_fit2",
                              #validation_frame = valid,  #only used if stopping_rounds > 0
                              epochs = 20,
                              hidden= c(10,10),
                              stopping_rounds = 0,  # disable early stopping
                              seed = 1)
  
  # Train a DL with early stopping
  # This example will use the same model parameters as `dl_fit2`. This time, we will turn on 
  # early stopping and specify the stopping criterion.  We will also pass a validation set, as is
  # recommended for early stopping.
  dl_fit3 <- h2o.deeplearning(x = x,
                              y = n_label,
                              training_frame = train,
                              model_id = "dl_fit3",
                              validation_frame = valid,  #in DL, early stopping is on by default
                              epochs = 20,
                              hidden = c(10,10),
                              score_interval = 1,           #used for early stopping
                              stopping_rounds = 3,          #used for early stopping
                              stopping_metric = "AUC",      #used for early stopping
                              stopping_tolerance = 0.0005,  #used for early stopping
                              seed = 1)
  
  
  # Let's compare the performance of the three DL models
  dl_perf1 <- h2o.performance(model = dl_fit1,
                              newdata = test)
  dl_perf2 <- h2o.performance(model = dl_fit2,
                              newdata = test)
  dl_perf3 <- h2o.performance(model = dl_fit3,
                              newdata = test)
  
  # Print model performance
  dl_perf1
  dl_perf2
  dl_perf3
  
  # Retreive test set AUC
  h2o.auc(dl_perf1)  
  h2o.auc(dl_perf2)  
  h2o.auc(dl_perf3)  
  
  # Scoring history
  h2o.scoreHistory(dl_fit3)
  
  # Look at scoring history for third DL model
  plot(dl_fit3, 
       timestep = "epochs", 
       metric = "AUC")
}

dbDisconnect()