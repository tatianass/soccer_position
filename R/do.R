source("load.R")
source("func.R")
source("clean.R")


txt_ext <- ".txt"
png_ext <- ".png"
csv_ext <- ".csv"

##################################
#+#+#+ SPLITTING (TRAIN/TEST) #+#+
##################################

n_label <- "positionCB"
y <- c("positionCB","positionCDM","positionCM","positionGK","positionLAM","positionLB","positionLCB","positionLCM","positionLDM","positionLM","positionLS","positionLW","positionRAM","positionRB","positionRCB","positionRCM","positionRDM","positionRM","positionRS","positionRW","positionST","positionSUB")
x <- setdiff(names(model_data), c(y, "(Intercept)"))

#transform dataframe dummies to matrix
model_data <- as.h2o(model_data)

#convert to factor
model_data$positionCB <- as.factor(model_data$positionCB)
model_data$positionCDM <- as.factor(model_data$positionCDM)
model_data$positionCM <- as.factor(model_data$positionCM)
model_data$positionGK <- as.factor(model_data$positionGK)
model_data$positionLAM <- as.factor(model_data$positionLAM)
model_data$positionLB <- as.factor(model_data$positionLB)
model_data$positionLCB <- as.factor(model_data$positionLCB)
model_data$positionLCM <- as.factor(model_data$positionLCM)
model_data$positionLDM <- as.factor(model_data$positionLDM)
model_data$positionLM <- as.factor(model_data$positionLM)
model_data$positionLS <- as.factor(model_data$positionLS)
model_data$positionLW <- as.factor(model_data$positionLW)
model_data$positionRAM <- as.factor(model_data$positionRAM)
model_data$positionRB <- as.factor(model_data$positionRB)
model_data$positionRCB <- as.factor(model_data$positionRCB)
model_data$positionRCM <- as.factor(model_data$positionRCM)
model_data$positionRDM <- as.factor(model_data$positionRDM)
model_data$positionRM <- as.factor(model_data$positionRM)
model_data$positionRS <- as.factor(model_data$positionRS)
model_data$positionRW <- as.factor(model_data$positionRW)
model_data$positionST <- as.factor(model_data$positionST)
model_data$positionSUB <- as.factor(model_data$positionSUB)

#test factor
h2o.levels(model_data$positionRCB)

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
  path <- paste("analysis/model/", n_label, sep="")
  s<-dl_perf1
  capture.output(s, file = addFileExtension(paste(path,"model_perf1", sep="_"), txt_ext))
  s<-dl_perf2
  capture.output(s, file = addFileExtension(paste(path,"model_perf2", sep="_"), txt_ext))
  s<-dl_perf3
  capture.output(s, file = addFileExtension(paste(path,"model_perf3", sep="_"), txt_ext))
  
  
  
  # Retreive test set AUC
  s<-h2o.auc(dl_perf1)
  capture.output(s, file = addFileExtension(paste(path,"auc_perf1", sep="_"), txt_ext))
  s<-h2o.auc(dl_perf2)
  capture.output(s, file = addFileExtension(paste(path,"auc_perf2", sep="_"), txt_ext))
  s<-h2o.auc(dl_perf3)
  capture.output(s, file = addFileExtension(paste(path,"auc_perf3", sep="_"), txt_ext))
  
  
  # Scoring history
  s<-h2o.scoreHistory(dl_fit3)
  capture.output(s, file = addFileExtension(paste(path,"sh_perf3", sep="_"), txt_ext))
  
  # Look at scoring history for third DL model
  png(filename=addFileExtension(paste(path,"sh_perf3", sep="_"), png_ext))
  plot(dl_fit3, 
       timestep = "epochs", 
       metric = "AUC")
  dev.off()
}

dbDisconnect()