##Create the data directory
if(!file.exists("./data")){dir.create("./data")}
##Download the file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/Dataset.zip",method="auto")
##unzip the file
unzip(zipfile="./data/Dataset.zip",exdir="./data")
##Store the file path
path_rf <- file.path("./data" , "UCI HAR Dataset")
##Ignore all the intertial data and use only the following data sets
##test/subject_test.txt (Subject data part 1)
##test/X_test.txt   (Feature data part 1)
##test/y_test.txt   (Activity data part 1)
##train/subject_train.txt (Subject data part 2)
##train/X_train.txt (Feature data part 2)
##train/y_train.txt (Activity data part 2)
##Read and merge data respectively for Subject, Activity and Features
dataSubject1  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)
dataSubject2 <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataActivity1  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivity2 <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)
dataFeatures1  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeatures2 <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)
dataSubject <- rbind(dataSubject1, dataSubject2)
dataActivity<- rbind(dataActivity1, dataActivity2)
dataFeatures<- rbind(dataFeatures1, dataFeatures2)
##Set names for variables
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2
##Merge Data from Subject, Activity and Features into one single dataset
Data <-cbind(dataFeatures, cbind(dataSubject, dataActivity))
##Extract measurements on the mean and standard deviation among the features.
subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
##Subset the data by names in interest
selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
##Uses descriptive activity names to name the activities in the data set
activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
Data <- merge(Data, activityLabels, by.x = "activity", by.y = "V1")
library(dplyr)
Data <- rename(Data, activityName = V2)
Data <- Data[,2:69]
##Appropriately labels the data set with descriptive variable names
##prefix t is replaced by time
##Acc is replaced by Accelerometer
##Gyro is replaced by Gyroscope
##prefix f is replaced by frequency
##Mag is replaced by Magnitude
##BodyBody is replaced by Body
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))
##Creates a second,independent tidy data set and ouput it
library(plyr);
Data2<-aggregate(. ~subject + activityName, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activityName),]
write.table(Data2, file = "averagepersubjectactivity.txt",row.name=FALSE)
