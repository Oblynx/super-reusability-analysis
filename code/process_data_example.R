
## PREREQUISITES
# Make sure the directory is set at the location of
# read_data.R, repositories_info.csv and the folders Class, Method, and Package
# e.g. for this directory structure:
# /home/student/Desktop/PR_assignment_data/process_data_example.R
# /home/student/Desktop/PR_assignment_data/read_data.R
# /home/student/Desktop/PR_assignment_data/repositories_info.csv
# /home/student/Desktop/PR_assignment_data/Class/
# /home/student/Desktop/PR_assignment_data/Method/
# /home/student/Desktop/PR_assignment_data/Package/
# the command should be setwd("/home/student/Desktop/PR_assignment_data/")
setwd("...")

# Import the data reading component
source("read_data.R")


## TEST 1 - Test for a repository
# Read the data for a library e.g. github__linguist
sdata = read_metrics_data("Activiti", type = "Class")
target = repositories[repositories$Project_Name == "Activiti", ]

# Drop the first 11 columns
sdata = sdata[, 12:ncol(sdata)]

# Filter the data and keep only those that have more than 30 lines of code
sdata = sdata[sdata$LOC > 30,]

# Check the data
str(sdata)
head(sdata)
summary(sdata)

# Plot the variables just to check them out
# 2 5 6 7 8 9 11 12 13 14 15 16 17 18 19 20 21 22
plot(sdata$WMC, type = 'l')

# Plot the number of lines of code in relation with the number
# of weighted methods per class as they may have some connection
plot(sdata$WMC, sdata$LOC, xlim = c(0, 50), ylim = c(20, 200))

# Distribute the stars of the repo in the classes according to the lines of code
# for each class, scale them, discretize them, and plot them in bar plot
score = target$Stars * sdata$LOC / sum(sdata$LOC)
score = scale(score, scale = TRUE, center = FALSE)
discrete_score = cut(score, breaks = 40)
plot(discrete_score)


## TEST 2 - Test for multiple repositories
# Read the data for 10 projects at random (use seed  = 0 to keep reading the same data)
set.seed(0); random_index = sample(length(repositories$Project_Name), 10)
target = repositories$Project_Name[random_index]
randdata = read_metrics_data(target, type = "Class")

# Check the data
str(randdata)
head(randdata)
summary(randdata)

# Get the project names
projects = levels(randdata$Project_Name)

# For each project name get the average number of weighted methods per class
wmc = c()
for (i in 1:length(projects)){
  projdata = randdata[randdata$Project_Name == projects[i],]
  wmc[i] = sum(projdata$WMC) / nrow(projdata)
}
barplot(wmc, main = "Average Weighted Methods per Class", names.arg = projects, las=2)

