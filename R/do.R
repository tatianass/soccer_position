source("load.R")
source("func.R")
source("clean.R")

##################################
#+#+#+ SPLITTING (TRAIN/TEST) #+#+
##################################

f_matrix <- getFormulaMatrix(data)

#transform dataframe dummies to matrix
model <- model.matrix(f_matrix, data)

## 75% of the sample size
smp_size <- floor(0.75 * nrow(model))

## set the seed to make your partition reproductible
set.seed(123)
train_ind <- sample(seq_len(nrow(model)), size = smp_size)

train <- model[train_ind, ]
test <- model[-train_ind, ]


##################################
#+#+#+ NEURAL NETWORk H2O #+#+#+#+
##################################
#declaring the number of neuron to be used
#in the hidden layer

## Import Data to H2O Cluster
train_hex <- as.h2o(train)
test_hex <- as.h2o(test)

## Split the dataset into 80:20 for training and validation
train_hex_split <- h2o.splitFrame(train_hex, ratios = 0.8)

for(n_label in 3:30){
  ## Train a 50-node, three-hidden-layer Deep Neural Networks for 100 epochs
  modelh2o <- h2o.deeplearning(x = (24:56),
                               y = (n_label),
                               training_frame = train_hex_split[[1]],
                               validation_frame = train_hex_split[[2]],
                               hidden = c(50, 50, 50),
                               epochs = 100)
  
  ## Use the model for prediction and store the results in submission template
  raw_sub <- as.matrix(h2o.predict(modelh2o, test_hex))
  write.table(raw_sub, file = paste("analysis/",paste(names(train_hex)[n_label], ".txt",sep = ""), sep = ""), row.names=FALSE, col.names=FALSE)
  
}