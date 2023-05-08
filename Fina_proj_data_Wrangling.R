##Armand Uysal and Kenny
## Group 51 
## Final Project: Data Wrangling
##5/6/2023

library(dplyr)
library(stringr)

df_1_2020<- read.csv("KCSO_Offense_Reports__2020_to_Present.csv")
df_2_2019 <- read.csv("KCSO_Incident_Dataset__Historic_to_2019.csv") 

#these two data frames will be bind in `df_bind` together and then merges with the SPD data frame below



#deletes irrelevant columns
# this cleaning is simply to add 2019 KCSO data to the 2020 KSCO data
#I will bind these two very similar data frames and then join that data frame with the SPD data Frame

df_1_2020$nibrs_code =NULL

df_2_2019$FCR = NULL
df_1_2020$reporting_area =NULL
df_1_2020$district = NULL
df_1_2020$precinct = NULL
df_1_2020$ID = NULL
df_2_2019$Incident.Block.Location = NULL
df_1_2020$created_at = NULL
df_1_2020$updated_at = NULL
df_2_2019$created_at = NULL
df_2_2019$updated_at = NULL
df_1_2020$hour_of_day = NULL
df_1_2020$day_of_week = NULL
df_2_2019$hour_of_day =NULL
df_2_2019$day_of_week = NULL 


#renames columns in df_1_2020 to match df_2_2019

colnames(df_1_2020)[colnames(df_1_2020) == "nibrs_code_name"] <- "incident_type"
colnames(df_1_2020)[colnames(df_1_2020) == "block_address"] <- "address_1"

#this rbind is for both of th KCSO data frames


 df_bind <- rbind(df_1_2020, df_2_2019)


## SPD data frame cleaning 
 
df_3 <- read.csv("SPD_Crime_Data__2008-Present.csv")

#getting only the needed data from jan 1st 2019 in the SPD data

clean_df_3_SPD <- df_3[!grepl("2008|2009|2010|2011|2012|2013|2014|2015|2016|2017|2018", df_3$Report.DateTime), ]
#cleaning more columns from cleaned_df_3_SPD and df_bind

clean_df_3_SPD$Offense.Start.DateTime = NULL
clean_df_3_SPD$Offense.End.DateTime = NULL
clean_df_3_SPD$Offense.ID = NULL
clean_df_3_SPD$Group.A.B = NULL
clean_df_3_SPD$Offense.Parent.Group = NULL
clean_df_3_SPD$Precinct = NULL
clean_df_3_SPD$Sector = NULL
clean_df_3_SPD$Offense.Code = NULL
clean_df_3_SPD$Beat = NULL
clean_df_3_SPD$X100.Block.Address = NULL
clean_df_3_SPD$Longitude = NULL
clean_df_3_SPD$Latitude = NULL
# renames MCPP column
colnames(clean_df_3_SPD)[colnames(clean_df_3_SPD) == "MCPP"] <- "Seattle_neighborhoods"

#cleanig for the bind KCSO data

df_bind$case_number = NULL
df_bind$state = NULL
df_bind$zip = NULL
df_bind$address_1 = NULL

#setting nre df name for cleaned_df_3_SPD
SPD_df <- clean_df_3_SPD

#cleaning df_bind and getting rid of Seattle data rows 

KCSO_df <- df_bind[!grepl("SEATTLE", df_bind$city), ]
# clarifying col names for both datasets
colnames(SPD_df)[colnames(SPD_df) == "incident_datetime"] <- "Seattle_incidents"


colnames(KCSO_df)[colnames(KCSO_df) == "incident_datetime"] <- "King_County_incidents"

##SPD removing column 

SPD_df$Report.Number = NULL

## adding columns for proper merge on both datasets
SPD_df$ID <- 1:nrow(SPD_df)
KCSO_df$ID <- 1:nrow(KCSO_df)
## joining the prepared data for KCSO and SPD 

df <- full_join(SPD_df, KCSO_df, by = "ID")



## New categorical variable 
## adds a column for the whether the crime is property related or not True/false 


df$PROPERTY <- df$Crime.Against.Category == "PROPERTY"






#Adds numeric variable column for university related crimes

df$crime_type <- df$Seattle_neighborhoods == "UNIVERSITY"

df[c(df$crime_type == TRUE), "crime_type"] = "1"


df[c(df$crime_type == FALSE), "crime_type"] = "0"

## creating summarization data frame 

summary_df <- summary(df)

## rearrange columns

df2<-df[,c("Report.DateTime","Crime.Against.Category","PROPERTY","Offense","Seattle_neighborhoods","crime_type","ID","King_County_incidents","incident_type","city")]



write.csv(df2, "C:/Users/Armand/Documents/INFO 201//final_project_done.csv", row.names=TRUE)
