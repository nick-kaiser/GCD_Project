## Runs the analysis for the Getting and Cleaning Data final project

## Load the dplyr library (a distilled version of plyr)
library(dplyr)

## Store strings for dataset URL and local location
file_URL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
file_loc <- "./data/dataset.zip"

## Download the dataset and unzip
download.file(file_URL, file_loc)
unzip(file_loc, exdir = "./data/")

## Read in the test set data files to data frames
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")

## Read in the training set data files to data frames
subject_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/y_train.txt")

## Assemble test data frame by binding columns
test_full <- cbind(subject_test, y_test, x_test)

## Assemble training data frame by binding columns
train_full <- cbind(subject_train, y_train, x_train)

## Merge the test and training sets by binding rows
full_set <- rbind(train_full, test_full)

## Read in the activity labels and feature names to data frames
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
feature_labels <- read.table("./data/UCI HAR Dataset/features.txt")

## Assign feature labels to the full set, adding names for the subject and
## activity columns
names(full_set) <- c("subject", "act_num", feature_labels[,2])

## Extract only descriptive columns + means and standard deviations
reduced <- select(full_set, subject, act_num, 
                  grep("mean()", names(full_set), fixed = TRUE), 
                  grep("std()", names(full_set), fixed = TRUE))

## Replace numbers for activities with descriptive terms and remove the act_num
## column
reduced <- mutate(reduced, activity = activity_labels[act_num,2],
                  .before = act_num) %>% select(-act_num)

## Write the tidy data set with the complete combined activity data
write.csv(reduced, "tidy_complete.csv", row.names = FALSE)

## Create a tidy data set with the average of each variable for each activity
## and subject
subj_act_means <- reduced %>% group_by(subject, activity) %>%
    summarize(across(everything(), mean))

## Write the tidy data set with the average of each variable for each activity
## and subject
write.csv(subj_act_means, "tidy_means.csv", row.names = FALSE)
