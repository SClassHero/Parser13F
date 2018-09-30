rm(list = ls(all = TRUE))
#Use packages.install("packagename") if you have not installed the following libarary:

library(XML)
library(xml2)
library(RCurl)
library(dplyr)
library(stringr)
library(psych)
#The first part download the list of all the 13F filings txt file
#Read the list of master file from 1999 to 2nd quarter of 2013
masterIndex9913<- read.table("MasterIndexList.txt")
for (j in 1:nrow(masterIndex9913)) {
#V1 in this master index datasets is the path to the *idx file on SEC server
masterindex_link <- masterIndex9913$V1[j]
masterindex_link <-as.character(masterindex_link)

#output file name
listname13F<-paste("List13F",substr(masterindex_link,47,50),substr(masterindex_link,52,55),".csv")
listname13Famend<-paste("List13F",substr(masterindex_link,47,50),substr(masterindex_link,52,55),"_A",".csv")

list_all_o <- read.table(file=masterindex_link, skip=10, sep = "|", fill=TRUE, quote = "")

str(list_all_o)
#Extract original 13-F form. Things we want to do but have not been able to accomplished:
##Other variable we want to extract from 13F but is not in the table: SEC file number, 
#Under the text Form13F Cover Page, it should have an expression like: "Report fo the Calendar Year or quarter ended: date". We want to extract this date
#We want to add these variable next to each filing. Each obs in this listo file is a filings.
#For now this code only extract the list of the filings and their url
list_rawo <- filter(list_all_o,V3 == "13F-HR") #take all the filings and keep only 13F filings. 
write.csv(list_rawo, file="list_raw_o.csv")
list_rawo <- read.csv("list_raw_o.csv")
listo <- list_rawo

#V5 variable has the path to the .txt file
listo$V5 <- as.character(listo$V5) #turn the path into a character from a factor
listo$V2 <- gsub(",","",listo$V2) #get rid of commas in names so that we can save as csv without quotes

#Path variable will have the path to the info table .xml file

listo$path <- substr(listo$V5,1,nchar(listo$V5)-4) #create a new variable path
listo$path <- gsub("-","",listo$path)
listo$path <- paste("https://www.sec.gov/Archives/", listo$path, sep = "")
listo$V5 <- paste("https://www.sec.gov/Archives/",listo$V5, sep = "") 

#rename the column
listo$X <-NULL
names(listo) <- c("CIK", "Investor", "formtype", "fdate", "url",'folderpath')

#Actually, for filing before June 2013, we do not have a separate xml infotable, so all the info is
#contained in the txt file. V5 is the variable leading to the text file. Path file is leading to the folder
#which contained the txt file and other related file. 
#write to a list file for all the 13F in the quarter, idealy file name should have <formType><year><quarter>.csv to keep track easily. The original 13F is 13F, Amended is 13FA
write.csv(listo, file=listname13F) 

#Amended 13F form: things that I want to do but haven't been able to accomplish with this code:

#after extracting these files, we want to select only the txt files that contain the string: "This filing lists"
#A secondary criteria after staisfiying the above: It should contain the string: [X] adds new holdings entries and should not contain: [X] is a restatement. It should be [_] is a restatement instead.
#Because the filing manager only supposed to tick X into one of the two check box. The filing is either a restatement or add new holding entries, not both.
#for filing that contains "this filing lists" it suppose to be an "adds new holding entries" category. So including this secondary criteria may not be neccesary.
#If the file checked both: a filing error, consider an exception, have to set aside and read manually.
#Other variable we want to extract from 13F but is not in the table: SEC file number, 
#Under the text Form13F Cover Page, it should have an expression like: "Report fo the Calendar Year or quarter ended: date". We want to extract this date
#the following code only select form type 13F-HR/A which is amended 13F.

list_rawo <- filter(list_all_o,V3 == "13F-HR/A") #take all the filings and keep only 13F filings
write.csv(list_rawo, file="list_raw_o.csv")
list_rawo <- read.csv("list_raw_o.csv")
listo <- list_rawo

#V5 variable has the path to the .txt file
listo$V5 <- as.character(listo$V5) #turn the path into a character from a factor
listo$V2 <- gsub(",","",listo$V2) #get rid of commas in names so that we can save as csv without quotes

#Path variable will have the path to the info table .xml file

listo$path <- substr(listo$V5,1,nchar(listo$V5)-4) #create a new variable path
listo$path <- gsub("-","",listo$path)
listo$path <- paste("https://www.sec.gov/Archives/", listo$path, sep = "")
listo$V5 <- paste("https://www.sec.gov/Archives/",listo$V5, sep = "") 
#rename the column
listo$X <-NULL
names(listo) <- c("CIK", "Investor", "formtype", "fdate", "url",'folderpath')
#Actually, for filing before June 2013, we do not have a separate xml infotable, so all the info is
#contained in the txt file. V5 is the variable leading to the text file. Path file is leading to the folder
#which contained the txt file and other related file. 
write.csv(listo, file=listname13Famend)
if (j/10 == floor(j/10)) {print(j)}  #print every 10th value to monitor progress of the loop
}
