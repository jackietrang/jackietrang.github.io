## Multilateral Development Institution Data

foo <- read.csv("https://tinyurl.com/yb4phxx8") #read dataset

#column names
names(foo)

# dimesions of the data set
dim(foo)

#quick look at the data structure
head(foo)

#take note of the colums representing calendar dates:
date.columns <- c(11, 12, 14, 15, 16, 17, 18, 25)

### Data Preprocessing

for(i in date.columns)  #loop through the "date.columns
{
  #Find missing values
  which_values_are_missing <- which(as.character(foo[, i]) == "")
  #Replace them by NAs
  foo[which_values_are_missing, i] <- NA
  #Turn values into dates
  foo[, i] <- as.Date(as.character(foo[, i])) #change all dates into Date class
}

#Only get number bigger than 2009-01-01
y <- foo$CirculationDate
foo1 <- foo[which(y >= "2009-01-01"), ]
foo1

#Elimitate missing values in circulation date and other Date columns 
library(dplyr)
foo2 <- foo1 %>% filter(!is.na(foo1$CirculationDate))
foo2 <- foo2 %>% filter(!is.na(foo1$CirculationDate))
foo2 <- foo2 %>% filter(!is.na(foo1$ApprovalDate))
foo2 <- foo2 %>% filter(!is.na(foo1$OriginalCompletionDate))
foo2 <- foo2 %>% filter(!is.na(foo1$RevisedCompletionDate))

#sort foo2 with ascending circulationdate
foo2sorted <- foo2[order(foo2$CirculationDate),]
foo2sorted
count(foo2sorted)


#---------- Done with condition, now move to the questions
## 1a) The difference between OrigianlCompletion date and Approval date in montsh

diff1 = round((foo2sorted$OriginalCompletionDate - foo2sorted$ApprovalDate)/(325.25/12)) #Divide by(325.25/12) to turn days into months
mean_diff1 <- sum(diff1)/length(diff1) #in months
mean_diff1 #in months
median(diff1) #in months
quantile(diff1) #in months


##### diff1 in days
ddiff1 = foo2sorted$OriginalCompletionDate - foo2sorted$ApprovalDate 
mean_ddiff1 <- sum(ddiff1)/length(ddiff1) #in days
mean_ddiff1 #in days
median(ddiff1) #in days
quantile(ddiff1) #in days

##1b)The change of delay overtime

delay_sorted <- round(foo2sorted$RevisedCompletionDate - foo2sorted$OriginalCompletionDate) #delay duration sorted by Circulation date
time_sorted <- c(foo2sorted$CirculationDate) #sorted circulation date in ascending orer 
mean_delay <- sum(delay_sorted)/length(delay_sorted) #average delay
mean_delay
median(delay_sorted) #median delay
quantile(delay_sorted) #quantile of delay


###Graph to see if the duration actually decreases. 
library(ggplot2)
ggplot(data = foo2sorted, aes(x=foo2sorted$CirculationDate, y=as.numeric(foo2sorted$RevisedCompletionDate - foo2sorted$OriginalCompletionDate)))+
  geom_line(color="#E69F01")+
  geom_point()+
  ggtitle("Delay time across Circulation Date")+
  xlab("Circulation date")+
  ylab("Days")

###linear regression to assess the relationship between delay and circulation date
regression_1 <- lm((as.numeric(delay_sorted) ~ as.numeric(time_sorted)), data = foo2sorted)
summary(regression_1)


##1c
diff2 = round((foo2sorted$RevisedCompletionDate - foo2sorted$ApprovalDate)) #actual completion duration
mean_diff2 <- sum(diff2)/length(diff2)
mean_diff2
median(diff2)
quantile(diff2)


#--------------Question 2
###Filter Revisedcompletion date from 2010
x <- foo2sorted$RevisedCompletionDate #RevisedCompletion date between 2010 and now
foo3 <- foo2sorted[which(x >= "2010-01-01"),]
foo3 %>% filter(!is.na(foo3$Rating)) #eliminate NAs

###Table of percentages in rating

prop.table(table(foo3$Rating))



#---------- Question3
PATA <- foo3[foo3$Type == "PATA", ] #filter only PATA projects from 2010
count(PATA)
###Table of percentages in rating

prop.table(table(PATA$Rating))

#----------Question 4
foo2 %>% filter(!is.na(foo2$RevisedAmount)) #filter out NAs
foo2 %>% filter(!is.na(foo2$Rating))

foo2Rev <- foo2[order(foo2$RevisedAmount),] 
print(foo2Rev)
First10 <- foo2Rev[2:166,] #because the first 1 was NA; top 10%
Last10 <- foo2Rev[1486:1650,] #bottom 10%

#Rating of each group regarding mean, median, interquartile
count(First10)
sum(First10$Rating)/length(First10$Rating)
median(First10$Rating)
quantile(First10$Rating)

count(Last10)
sum(Last10$Rating)/length(Last10$Rating)
median((Last10$Rating))
quantile(Last10$Rating)

#Finding correlation r
FirstandLast <- c(First10,Last10)
cor(FirstandLast$RevisedAmount, FirstandLast$Rating)


  
##Can you draw a causal conclusion about the effect of budget size on ratings? Why or why not?
  ###Hint: Compare other characteristics “Dept,” “Division,” “Cluster,” “Country.” 
data.frame(First10$Dept,Last10$Dept, First10$Division,Last10$Division, First10$Country, Last10$Country)
###Characterisitcs of each group 
First10 %>% count(Dept)
Last10 %>%count(Dept)


First10 %>% count(Country)
Last10 %>% count(Country)


First10 %>% count(Division)
Last10 %>% count(Division)

##------------------------------END--------------------------------



