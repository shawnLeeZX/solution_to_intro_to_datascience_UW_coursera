### Step 1: Read and summarize the data
## Using R, read the file seaflow_21min.csv and get the overall counts
## for each category of particle. You may consider using the functions
## read.csv and summary.

## Answer Questions 1 and 2.

seaflow_data <- read.csv(file = "seaflow_21min.csv", header = TRUE, sep = ",")
summary(seaflow_data$pop)
summary(seaflow_data)

### Step 2: Split the data into test and training sets
## Divide the data into two equal subsets, one for training and one for
## testing. Make sure to divide the data in an unbiased manner.  You
## might consider using either the createDataPartition function or the
## sample function, although there are many ways to achieve the goal.

## Answer Question 3.

library(caret)
train_index <- createDataPartition(seaflow_data$pop, p = 0.5, list = FALSE)
train_data <- seaflow_data[train_index,]
test_data <- seaflow_data[-train_index,]
mean(train_data$time)

### Step 3: Plot the data
## Plot pe against chl_small	and color by pop

## I recommend using the function ggplot in the library ggpplot2 rather
## than using base R functions, but this is not required.

## Answer Question 4.

library(ggplot2)
ggplot(seaflow_data, aes(x=chl_small, y=pe, colour=pop)) + geom_point()

### Step 4: Train a decision tree.
formula <- formula( pop ~
    fsc_small + fsc_perp + fsc_big + pe + chl_big + chl_small
)
library(rpart)
decision_tree <- rpart(formula, method = "class", data = train_data)
library(rpart.plot)
rpart.plot(decision_tree)

### Step 5: Evaluate the decision tree on the test data.
prediction.dt <-  predict(decision_tree, test_data, type = "class")
result.dt <- test_data$pop == prediction.dt
accuracy.dt <- sum(result.dt) / length(prediction.dt)
accuracy.dt

### Step 6: Build and evaluate a random forest.
library(randomForest)
random_forest <- randomForest(formula, data = train_data)
prediction.rf <- predict(random_forest, test_data, type = "class")
result.rf <- test_data$pop == prediction.rf
accuracy.rf <- sum(result.rf) / length(prediction.rf)
accuracy.rf
importance(random_forest)

### Step 7: Train a support vector machine model and compare results.
library(e1071)
svm <- svm(formula, data = train_data)
prediction.svm <- predict(svm, test_data, type = "class")
result.svm <- test_data$pop == prediction.svm
accuracy.svm <- sum(result.svm) / length(prediction.svm)
accuracy.svm

### Step 8: Construct confusion matrices
table(pred = prediction.dt, true = test_data$pop)
table(pred = prediction.rf, true = test_data$pop)
table(pred = prediction.svm, true = test_data$pop)

### Step 9: Sanity check the data
## As a data scientist, you should never trust the data, especially if
## you did not collect it yourself. There is no such thing as clean
## data. You should always be trying to prove your results wrong by
## finding problems with the data. Richard Feynman calls it
## "bending over backwards to show how you're maybe wrong." This is even
## more critical in data science, because almost by definition you are
## using someone else's data that was collected for some other purpose
## rather than the experiment you want to do. So of course it's
## going to have problems.

## The measurements in this dataset are all supposed to be continuous
## (fsc_small, fsc_perp, fsc_big, pe, chl_small, chl_big), but one is
## not. Using plots or R code, figure out which field is corrupted.

ggplot(seaflow_data, aes(x=time, y=fsc_big)) + geom_point()

## Answer Question 13

## There is more subtle issue with data as well. Plot time vs. chl_big,
## and you will notice a band of the data looks out of place. This band
## corresponds to data from a particular file for which the sensor may
## have been miscalibrated. Remove this data from the dataset by
## filtering out all data associated with file_id 208, then repeat the
## experiment for all three methods, making sure to split the dataset
## into training and test sets after filtering out the bad data.

ggplot(seaflow_data, aes(x=time, y=chl_big, colour=pop)) + geom_point()
filtered_data <- seaflow_data[seaflow_data$file_id != 208,]
train_index_new <- createDataPartition(filtered_data$pop, p = 0.5, list = FALSE)
train_data_new <- filtered_data[train_index_new,]
test_data_new <- filtered_data[-train_index_new,]
svm_new <- svm(formula, data = train_data_new)
prediction.svm.new <- predict(svm_new, test_data_new, type = "class")
result.svm.new <- test_data_new$pop == prediction.svm.new
accuracy.svm.new <- sum(result.svm.new) / length(prediction.svm.new)
delta <- accuracy.svm.new - accuracy.svm
delta

## Answer Question 14
