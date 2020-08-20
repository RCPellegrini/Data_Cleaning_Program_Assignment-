## Step0: Downloading and Reading data

library(data.table)
fileurl = 'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip'
if (!file.exists('./UCI HAR Dataset.zip')){
  download.file(fileurl,'./UCI HAR Dataset.zip', mode = 'wb')
  unzip("UCI HAR Dataset.zip", exdir = getwd())
}

features <- read.csv('./UCI HAR Dataset/features.txt', header = FALSE, sep = ' ')
features <- as.character(features[,2])

training_set_x <- read.table('./UCI HAR Dataset/train/X_train.txt')
training_activity_label_y <- read.csv('./UCI HAR Dataset/train/y_train.txt', header = FALSE, sep = ' ')
training_subject <- read.csv('./UCI HAR Dataset/train/subject_train.txt',header = FALSE, sep = ' ')

training_data <-  data.frame(training_subject, training_labels_y, training_set_x)
names(training_data) <- c(c('subject', 'activity_label'), features)

test_set_x <- read.table('./UCI HAR Dataset/test/X_test.txt')
test_activity_label_y <- read.csv('./UCI HAR Dataset/test/y_test.txt', header = FALSE, sep = ' ')
test_subject <- read.csv('./UCI HAR Dataset/test/subject_test.txt', header = FALSE, sep = ' ')

test_data <-  data.frame(test_subject, test_labels_y, test_set_x)
names(test_data) <- c(c('subject', 'activity_label'), features)

#head(training_data)
#head(test_data)



## Step1: Merging data
merged_data <- rbind(training_data, test_data)

#View(merged_data)

## Step2: Extracts mean and standard deviation measurements for each measurement

mean_std_columns <- grep("mean|std", features)

View(mean_std_columns)

mean_std_columns <- mean_std_columns +2 ## add +2 because the features.txt don´t
# have the first two columns (subject and activity labels)

mean_std_data <- merged_data[,c(1,2, mean_std_columns)]

View(mean_std_data) 

## STep 3: Uses descriptive activity names to name the activities in the data set
#### Read activity_labels.txt to get the names related to the numbers in 
#### activity_label column.

activity_labels <- read.table('./UCI HAR Dataset/activity_labels.txt', header = FALSE)

activity_labels <- as.character(activity_labels[,2])

activity_labels

mean_std_data$activity_label <- activity_labels[mean_std_data$activity_label]

## Step 4: Appropriately labels the data set with descriptive variable names.
  ### From README.txt I took the following information:
      #- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
      #- Triaxial Angular velocity from the gyroscope. 
      #- A 561-feature vector with time and frequency domain variables. 
          #### Acc = Accelerometer
          #### Gyro = Gyroscope
          #### t = TimeDomain_
          #### f = FrequencyDomain_

  ### Others:
          #### Mag = Magnitude
          #### std = _StandardDeviation_
          #### change "-" for "_"

descrip_names <- names(mean_std_data)
descrip_names <- gsub("mean", "Mean", descrip_names)
descrip_names <- gsub("std", "StandardDeviation", descrip_names)
descrip_names <- gsub("^t", "TimeDomain_", descrip_names)
descrip_names <- gsub("^f", "FrequencyDomain_", descrip_names)
descrip_names <- gsub("Acc", "Accelerometer", descrip_names)
descrip_names <- gsub("Gyro", "Gyroscope", descrip_names)
descrip_names <- gsub("Mag", "Magnitude", descrip_names)
descrip_names <- gsub("-", "_", descrip_names)
descrip_names <- gsub("[(][)]", "", descrip_names)
descrip_names <- gsub("Freq_", "Frequency_", descrip_names)
descrip_names <- gsub("MeanFreq", "MeanFrequency", descrip_names)

names(mean_std_data) <- descrip_names

## Step5: From mean_std_data, create an independent tidy data 
# set with the average of each variable for each activity and each subject.
    # - Upload your data set as a txt file created with write.table() using 
    # row.name=FALSE
### Usisng stats aggregate

tidyData <- aggregate(mean_std_data[,3:81], by = list(activity_label = mean_std_data$activity_label, subject = mean_std_data$subject),FUN = mean)
write.table(x = tidyData, file = "tidyData.txt", row.names = FALSE)