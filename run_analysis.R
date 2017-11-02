# You should create one R script called run_analysis.R that does the following.
# 1.	Merges the training and the test sets to create one data set.
# 2.	Extracts only the measurements on the mean and standard deviation for each measurement.
# 3.	Uses descriptive activity names to name the activities in the data set
# 4.	Appropriately labels the data set with descriptive variable names.
# 5.	From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(reshape2)
library(data.table)
library(dplyr)

filename <- "getdata_dataset.zip"

## Download and unzip the dataset:
if(!file.exists("./data")){dir.create("./data")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip")

# Unzip dataSet to /data directory
unzip(zipfile="./data/Dataset.zip",exdir="./data")
#read in the train data set
X_train <- read.table("train/X_train.txt")
Y_train <- read.table("train/Y_train.txt")
subject_train <- read.table("train/subject_train.txt")

#data sets that will provide activity and feature labels
activitylabels <- read.table("activity_labels.txt")
features <- read.table("features.txt")

#rename training datasets with corresponding features
colnames(X_train) <- features[,2]
#names(Y_train)
colnames(Y_train) <- "activityID"
colnames(subject_train) <- "subjectID"

#read in the test data set
X_test <- read.table("test/X_test.txt")
Y_test <- read.table("test/Y_test.txt")
subject_test <- read.table("test/subject_test.txt")

#rename training datasets with corresponding features
colnames(X_test) <- features[,2]
colnames(Y_test) <- "activityID"
colnames(subject_test) <- "subjectID"
colnames(activitylabels) <- c("activityID","Type")

#merge training data set & test dataset
train_complete <- cbind(X_train, Y_train,subject_train)
test_complete <- cbind(X_test,Y_test,subject_test)

#combine complete test and train data sets
dataset <- rbind(train_complete, test_complete)
mean_std <- dataset[,(grepl("mean",names(dataset))|grepl("std",names(dataset))|grepl("activityID",names(dataset))|grepl("subjectID",names(dataset)))]
mean_std <- mean_std[,!grepl("meanFreq",names(mean_std))]

#4. Appropriately labels the data set with descriptive variable names.
mean_stdWnames <- merge(mean_std, activitylabels, by="activityID",all.x=TRUE)

#5. From the data set in step 4, create a second, independent tidy data set with the average of each variable for each activity and each subject.
variable_means <- aggregate(. ~ activityID + subjectID, mean_stdWnames, FUN = mean, na.rm = T)
#order data by subject ID and activity ID
variable_means <- variable_means[order("subjectID", "activityID"),]
