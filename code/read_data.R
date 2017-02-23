
# Finds the names of the projects
repositories = read.csv("repositories_info.csv", colClasses = c("NULL", "character", NA, NA, NA, NA, NA))

# Reads the data of the projects
read_metrics_data <- function(..., type) {
  param_list = list(...)
  if (length(param_list) == 1 && is.vector(param_list[1])){
    files = lapply(as.list(as.vector(unlist(param_list[1]))), function(i) paste(type, "/", i, "-", type, ".csv", sep = ""))
  }
  else {
    files = lapply(param_list, function(i) paste(type, "/", i, "-", type, ".csv", sep = ""))
  }
  contents = lapply(files, 
                      function(file){
                        filename = unlist(strsplit(file, "/"))[2]
                        Project_Name = gsub(paste("-", type, ".csv", sep = ""), "", filename)
                        print(Project_Name)
                        cbind(Project_Name, read.csv(file, stringsAsFactors = FALSE))
                      }
                    )
  alldata = do.call(rbind, contents)
  return(alldata)
}


# INSTRUCTIONS
# First execute the following line to import this component
# source("read_data.R")

# Then you can see the project names and number of files by printing repositories
# print(repositories)

# You can select to load a single project using
# ActionBarSherlock = read_metrics_data("ActionBarSherlock", type = "Class")
# ActionBarSherlock = read_metrics_data("ActionBarSherlock", type = "Method")
# ActionBarSherlock = read_metrics_data("ActionBarSherlock", type = "Package")
# where "type" must be "Class", "Method" or "Package".

# You can select to load more than one projects by giving them all as arguments
# projdata = read_metrics_data("Android-Bootstrap", "DroidPlugin", "JSON-java", type = "Class")
# or as a list e.g.
# projdata = read_metrics_data(c("Android-Bootstrap", "DroidPlugin", "JSON-java"), type = "Class")
# where "type" must be "Class", "Method" or "Package".

# As an example, you can select some projects from repositories, e.g. for the first four
# projdata = read_metrics_data(repositories$Project_Name[1:4], type = "Class")
# or you can select all projects with more than 500 and less than 1000 classes with the commands
# selected_repositories = repositories[repositories$Num_of_Classes > 500 & repositories$Num_of_Classes < 1000,]
# projdata = read_metrics_data(selected_projects$Project_Name, type = "Class")

# You can select to load projects at random using the following command
# where you can also set the size of the projects and the seed
# set.seed(0); random_index = sample(length(repositories$Project_Name), 10)
# randdata = read_metrics_data(repositories$Project_Name[random_index], type = "Class")

# You can select to read all projects using
# alldata = read_metrics_data(repositories$Project_Name, type = "Class")

