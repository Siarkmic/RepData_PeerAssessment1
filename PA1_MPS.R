
##loading data
setwd("C:/Users/siarkmi2/Documents/GitHub/RepData_PeerAssessment1")

activity.raw <- read.csv("activity.csv")

head(activity)
tail(activity)


## What is mean total number of steps taken per day?

# For this part of the assignment, you can ignore the missing values in the dataset.
library(data.table)
activity <- data.table(activity.raw)

# Make a histogram of the total number of steps taken each day
act.sumSteps <- activity[, sum(steps), by = date]
colnames(act.sumSteps)[2] <- "steps"
head(act.sumSteps)

  # The Freedman-Diaconis rule for binwidth
  # bw <- diff(range(act.sumSteps$V1 , na.rm = T)) / (2 * IQR(act.sumSteps$V1, na.rm = TRUE) / length(act.sumSteps$V1)^(1/3))
  # ggplot() + geom_histogram(aes(x), binwidth = bw)

library(ggplot2)
ggplot(act.sumSteps, aes(steps)) +
        geom_histogram(fill="lightblue", binwidth = 2500)+
        labs(x="# of Steps", y="Frequency") + 
        labs(title="Steps Daily")

# Calculate and report the mean and median total number of steps taken per day

# remove NA's
act.sumSteps.cc <- act.sumSteps[complete.cases(act.sumSteps), ]
act.meanSteps <- act.sumSteps.cc[, mean(steps),]
act.medianSteps <- act.sumSteps.cc[, median(steps),]

# Mean total number of steps taken per day
act.meanSteps
# Median total number of steps taken per day
act.medianSteps


## What is the average daily activity pattern?

# Make a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and 
# the average number of steps taken, averaged across all days (y-axis)
activity.cc <- activity[complete.cases(activity)]
act.meanStepsByint <- activity.cc[, mean(steps), by = interval]
colnames(act.meanStepsByint)[2] <- "steps"
head(act.meanStepsByint)

ggplot(act.meanStepsByint, aes(x= interval, y=steps))+
        geom_line()+
        labs(x="5-minute interval", y="average number of steps taken")+
        labs(title="the average number of steps taken, averaged across all days")

# Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?

colMax <- function(data) sapply(data, max, na.rm = TRUE)

Max <- colMax(act.meanStepsByint)
IntMax <- act.meanStepsByint[which(steps == Max[2] ),]

## Imputing missing values

# Note that there are a number of days/intervals where there are missing values (coded as NA). 
# The presence of missing days may introduce bias into some calculations or summaries of the data.

# Calculate and report the total number of missing values in the dataset (i.e. the total number of rows with NAs)
sum(!complete.cases(activity))

# Devise a strategy for filling in all of the missing values in the dataset. 
# The strategy does not need to be sophisticated. For example, you could use the mean/median for that day, 
# or the mean for that 5-minute interval, etc.
activity$date <- as.Date(activity$date, format = "%Y-%m-%d")

# Calculate the number of missing dates
datesInRange <- seq.Date(from = min(activity$date),
                           to = max(activity$date),
                           by='1 day')
dateNA <- sum(!activity$date[complete.cases(activity)] %in% datesInRange)
dateNA
# no missing dates

# calculatingt mean for interval for imputation
actMean <- activity.cc[, mean(steps), by = interval]
actMean$V1 <- round(actMean$V1)
colnames(actMean)[2] <- "impSteps"
actMean

## Create a new dataset that is equal to the original dataset but with the missing data filled in.

# Merge the replacement values
act.imp <- merge(activity, actMean, by='interval')

# Replace the missing values
act.imp$steps <- ifelse(is.na(act.imp$steps),
                        act.imp$impSteps,
                        act.imp$steps)

# Remove unnecesary data
set(act.imp, j = 'impSteps', value = NULL)

act.imp


## Make a histogram of the total number of steps taken each day and Calculate and 
## report the mean and median total number of steps taken per day. 

act.sumStepsIMP <- act.imp[, sum(steps), by = date]
colnames(act.sumStepsIMP)[2] <- "steps"
head(act.sumStepsIMP)

library(ggplot2)
ggplot(act.sumStepsIMP, aes(steps)) +
        geom_histogram(fill="lightblue", binwidth = 2500)+
        labs(x="# of Steps", y="Frequency") + 
        labs(title="Steps Daily")

# Calculate and report the mean and median total number of steps taken per day

act.meanStepsIMP <- act.sumStepsIMP[, mean(steps),]
act.medianStepsIMP <- act.sumStepsIMP[, median(steps),]

# Mean total number of steps taken per day
act.meanStepsIMP
# Median total number of steps taken per day
act.medianStepsIMP

## Do these values differ from the estimates from the first part of the assignment? 

1-act.meanSteps/act.meanStepsIMP
1-act.medianSteps/act.medianStepsIMP

## What is the impact of imputing missing data on the estimates of the total daily number of steps?

colnames(act.sumStepsIMP)[2] <- "impSteps"

act.sumSteps$date <- as.Date(act.sumSteps$date, format = "%Y-%m-%d")
act.sumStepsIMP$date <- as.Date(act.sumStepsIMP$date, format = "%Y-%m-%d")

act.all.sumSteps <- merge(act.sumSteps, act.sumStepsIMP, by = c("date") )
head(act.all.sumSteps)

library(tidyverse)

act.all.sumSteps <- act.all.sumSteps %>% 
        gather("steps", 'impSteps', key = "type", value = "steps")

head(act.all.sumSteps)

ggplot(act.all.sumSteps, aes(steps, color=type, fill=type)) +
        geom_histogram(position="dodge", alpha=0.5, binwidth = 2500)+
        labs(x="# of Steps", y="Frequency") + 
        labs(title="Steps Daily")






