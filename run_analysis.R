
## downloading, unzipping and reading the data
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile="./Dataset.zip", method="auto", mode="wb")
unzip("./Dataset.zip",list=TRUE)
unzip("./Dataset.zip", exdir = ".")
setwd("./UCI HAR Dataset")
activity_labels<-read.table("activity_labels.txt")
features<-read.table("features.txt")
x_test<-read.table("./test/x_test.txt")
activity_test<-read.table("./test/y_test.txt")
id_test<-read.table("./test/subject_test.txt")
x_train<-read.table("./train/x_train.txt")
activity_train<-read.table("./train/y_train.txt")
id_train<-read.table("./train/subject_train.txt")
      
## merging the "test" and the "train" datasets
X_test<-cbind(id=id_test$V1, activity_code=activity_test$V1, x_test)
X_train<-cbind(id=id_train$V1, activity_code=activity_train$V1,x_train)
X=merge(X_test, X_train, all=TRUE, sort=FALSE)

## adding the columnames 
col<-paste0( features[,2])
colnames(X)<-c("id","activity_code",col)

## extracting only the measurements on the mean and standard deviation 
keeps<-c("id","activity_code")
for (i in 3:ncol(X)){
        colname<-colnames(X)[i]
        incl.mean<-grepl("-mean()",colname)
        incl.std<-grepl("-std()",colname)
        excl.freq<-grepl("meanFreq", colname)
        if ((incl.mean==TRUE & excl.freq==FALSE) | incl.std==TRUE) {
                keeps<-c(keeps,colname)
        }
}
X1<-X[keeps]

## labeling the data set with descriptive activity names
X2<-merge(X1, activity_labels, by.x="activity_code", by.y="V1", sort=FALSE)
colnames(X2)[69]<-"activity"
TD<-X2[,c(2,69,3:68)]

## creating a new tidy data set with the average of each variable 
## for each activity and each subject
library(reshape2)
TDmelt<-melt(TD, id=c("id","activity"))
TD_final<-dcast(TDmelt, id+activity~variable, mean)

## writind the new tidy data set
write.table(TD_final, file="./tidyData_means.txt")


