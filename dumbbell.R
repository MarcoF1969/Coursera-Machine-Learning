# Coursera machine learning exercise
# Marco Folpmers

library(caret)
library(pROC)
library(readr)
library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(rpart)
library(rattle)
library(corrplot)
library(beepr)
library(rmarkdown)

rm(list=ls())
graphics.off()

#setwd("C:\\Users\\marco.folpmers\\Documents\\RPROJECTS\\COURSERA")
setwd("C:\\Users\\folpmers\\Documents\\RPROJECTS")

# url_link = "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-training.csv"
# download.file(url_link, destfile="pml-training.csv", method="curl")
# url_link = "https://d396qusza40orc.cloudfront.net/predmachlearn/pml-testing.csv"
# download.file(url_link, destfile="pml-testing.csv", method="curl")


training_input = read.csv(file="pml-training.csv", header=T, sep=",", 
                    na.strings = c("", "#DIV/0!", "NA"))
testing_input = read.csv(file="pml-testing.csv", header=T, sep=",", 
                    na.strings = c("", "#DIV/0!", "NA"))


# Divide input file in training and testing
set.seed(12345)
inTraining = createDataPartition(y=training_input$classe, p=0.8, list=F)
training = training_input[inTraining, ]
testing  = training_input[-inTraining, ]

# Remove columns with missing data; identify columns with complete data
# Apply to training
col_ind = colSums(!is.na(training))
table(col_ind)

training = training %>% 
  select(which(col_ind == nrow(training))) %>% 
  select(-c(X, raw_timestamp_part_1, raw_timestamp_part_2, 
            cvtd_timestamp, new_window, num_window))

# Apply to testing
testing = testing %>% 
  select(which(col_ind == nrow(training))) %>% 
  select(-c(X, raw_timestamp_part_1, raw_timestamp_part_2, 
          cvtd_timestamp, new_window, num_window))

# Username we keep since same users are in testing_input
table(training_input$user_name)
table(testing_input$user_name)

# Remove highly correlated variables
trainCorr = cor(training[2:53])
highCorr  = findCorrelation(trainCorr, 0.90) +1 # "+1"  since defined on training[2:53]

training = training[, -highCorr]
testing  = testing[, -highCorr]

# Check corrplot
corrplot(cor(training[,2:(ncol(training)-1)]))

# Exploratory data analysis
# for (i in 1:ncol(training)){
#   print(ggplot(training, aes(x=classe, y=training[,i])) + geom_boxplot()+
#           ylab(colnames(training)[i]))
# }

# Train data; Yeo-Johnson transformation rather than Box-Cox given neg. values
set.seed(1234)
start = Sys.time()

bootControl <- trainControl(method = "cv", repeats = 1, verboseIter = T)

modelFit = train(classe ~ ., data=training, method = "rf", 
                 preProcess=c("YeoJohnson", "center", "scale"), 
                 trControl = bootControl, ntree=20)

beep()
Sys.time() - start
hours_elapsed = as.numeric(modelFit$times$everything[3]/60/60)

modelFit
# str(modelFit)

# Accuracy training
predTraining = predict(modelFit, training)
confusionMatrix(predTraining, training$classe)

# Accuracy testing
predTesting = predict(modelFit, testing)
confusionMatrix(predTesting, testing$classe)

# Regularization plot
# http://stats.stackexchange.com/questions/206139/is-there-a-way-to-return-the-standard-error-of-cross-validation-predictions-usin
# Since Random Forest, tuning over mtry

modelFit$results %>%
  mutate(accuracySD_low = Accuracy - 2*(AccuracySD/sqrt(modelFit$control$number * modelFit$control$repeats)),
         accuracySD_high= Accuracy + 2*(AccuracySD/sqrt(modelFit$control$number * modelFit$control$repeats))) %>%
  ggplot(aes(x=mtry, y=Accuracy)) + 
  geom_errorbar(aes(ymin=accuracySD_low, 
                    ymax=accuracySD_high), width=.1, colour = "gray50")+
  geom_line() +
  geom_point()


# Variable importance
plot(varImp(modelFit))

# Apply to testing_input
testing_outcome = predict(modelFit, testing_input)
testing_outcome

# Benchmark Random Forest against RPART
# Fit classification tree
modFitRPART = rpart(classe ~ ., data=training, 
               control=rpart.control(cp=0.01) )
fancyRpartPlot(modFitRPART)

# print(modFitRPART)
dotchart(modFitRPART$variable.importance[1:20], cex=0.7, main="Importance acc to RPART")


# Accuracy training RPART
predRPART = predict(modFitRPART, training, type="class")
confusionMatrix(predRPART, training$classe)

# Accuracy testing  RPART
predRPART = predict(modFitRPART, testing, type="class")
confusionMatrix(predRPART, testing$classe)


