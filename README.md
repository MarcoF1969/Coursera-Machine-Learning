# Coursera-Machine-Learning
Repository for Coursera Machine Learning exercise. 
The R code contains the code for the Coursera Machine Learning exercise w.r.t. the dumbbell / biceps curl. The
R Markdown file is on Rpubs: http://rpubs.com/mfolpmer/260062
## Introduction
For the Coursera Machine Learning exercise two files are provided, training input and testing input. The files are related to a dumbbell biceps curl exercise in which test persons were asked to perform a biceps curl while wearing a belt. Sensors were attached to the belt, the dumbbell, the fore-arm and arm. While performing the exercise the test persons were assigned to 5 classes, so A, or B, ... or E. If the exercise (or part of the exercise, a movement) was executed correctly, the observation was assigned to class A. Classes B to E were used for several types of errors the test persons could perform. The Coursera exercise is to fit a predictive classification model to the training input and predict the outcomes for the testing input. 

## The program

1. Preparation

   In the first part of the program the relevant libraries are called and the data is read to R files training_input and testing_input. 

2. Data preparation
The training_input itself is partitioned into training data and testing data using caret's createDataPartition. Reason for this is that we want to establish unbiased accuracy instead of an optimistic one using the training dataset. Next, we remove all columns for which we have missing data using the counts per column of data unequal to NA using command col_ind = colSums(!is.na(training)). Also, we remove all columns that do not contain predictor data. We apply the same removal of columns to the testing data. We did not remove the user_name since the same test persons are available in testing_input. This means that we can use the test person's identity (say Adelmo) as a predictor since the same type of information is available in the testing input. We also removed highly correlated variables using as a cutoff 0.9 and -0.9 for negative correlations. For exploratory data analysis we generated boxplots to have an impression of the distribution of each feature for each class (A through E). Inspection of these graphs leads to the conclusion that data is often very skewed. 

3. Data fitting
We fit the data to a random forest. We limit the number of trees to 50 (using ntree = 50 in the train command). 
The results are equally good and performance is heavily impacted by the numer of trees. We keep track of run time and with these settings the training is completed after 14 minutes. Since the data are often skewed we use the Yeo-Johnson tranformation (Box-Cox cannot handle negative input data) and subsequently we center and scale the predictors. A 10-fold cross validation is used and the train procedure tunes over the mtry parameter. Since we use the option VerboseIter is True, we receive output regaring the estimation. For each fold, the mtry parameter is tuned over 3 values: 2, 26 and 50. 

4. Training output
The training output first confirms that the training set has 15,699 samples. It uses approximately 14,130 samples per fold which corresponds indeed to 10-fold cross validation (14,130 is approx. 9/10 * 15,699). By default, tuning was used to optimize Accuracy and Accuracy is optimized in the tuning grid used at mtry = 26. The final random forest model is estimated using this setting. 
The tuning is illustrated with the help of the regularization plot which is shown at the bottom of the R Markdown file. 

5. Model performance
The Confusion matrix of the training set shows that all samples are correctly predicted! There are only counts on the main diagonal of the Confusion matrix; Accuracy, Kappa, specificity and sensitivity are all equal to 1. Although the cross validation helps to avoid overfitting it is best practice to test this also using the test dataset. The Confusion matrix of the test dataset shows some counts that are not on the main diagonal but Accuracy and Kappa are still very high (both at 99%). With the help of the plot(varImp(modelFit)) statement we investigate the most important variables. It turns out that yaw_belt, pitch_forearm, and pitch_belt are on the top of the list. 

6. Benchmarking against CART model
In order to assess the added value of the random forest we compared the results against a regular Classification And Regression Tree model using rpart. With the settings used the conclusion is that random forst performs significantly better, Accuracy on the testing data being only 68%. Interestingly, the CART model has also pitch_forearm and pitch_belt as top-3 predictors. 

7. Predicting the unknown outcomes in the testing input
My prediction of the 20 unknown outcomes in the testing inout file is: B A B A A E D B A A B C B A E E A B B B
