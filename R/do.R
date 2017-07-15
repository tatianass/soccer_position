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
#+#+#+ NEURAL NETWORk #+#+#+#+#+#+
##################################
#declaring the number of neuron to be used
#in the hidden layer
numHiddenNeurons <- ncol(train)/2

#dealing with floats
numHiddenNeurons <- as.integer(numHiddenNeurons)

#gets formula
f_matrix <- getFormulaMatrix(train)

f_nn <- getFormulaNN(train)
#creating model
nn <- neuralnet(formula = f_nn, data = train, hidden = numHiddenNeurons, err.fct = "sse",
                linear.output = FALSE)
plot(nn)
nn$net.result #overall result i.e. output for each replication
nn$weights
nn$result.matrix

nn$covariate
nn$net.result[[1]]
nn1 <- ifelse(nn$net.result[[1]]>0.5,1,0)
nn1
misClasificationError = mean(train[2] != nn1)
