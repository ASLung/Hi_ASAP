# To remove previous memory in R.
rm(list=ls())

location <- "D:/"

# To set the output file
cmd1 <- paste0("setwd('",location,"HiASAP/Exposure_Factor/output')")
eval(parse(text=cmd1))

outputname <- "Exposure_Factor"

# To create variables of outdoor, indoor and personal data of ASLUNG
PM <- read.csv(paste0(location,"HiASAP/PM/output/PM_5 min_ASLUNG_Time_All.csv"))
ALP <- PM[which(PM$AL_Type==3),]
colnames(ALP)[names(ALP) == c("TEM","HUM","PM1","PM2.5","CO2")]<-c("ALP_TEM","ALP_HUM","ALP_PM1","ALP_PM2.5","ALP_CO2")
ALP_2 <- ALP[,c(1:9,11:15)]

ALI <- PM[which(PM$AL_Type==2),]
colnames(ALI)[names(ALI) == c("TEM","HUM","PM1","PM2.5","CO2")]<-c("ALI_TEM","ALI_HUM","ALI_PM1","ALI_PM2.5","ALI_CO2")
ALI_2 <- ALI[,c(2:6,8,11:15)]

ALO <- PM[which(PM$AL_Type==1),]
colnames(ALO)[names(ALO) == c("TEM","HUM","PM1","PM2.5","CO2")]<-c("ALO_TEM","ALO_HUM","ALO_PM1","ALO_PM2.5","ALO_CO2")
ALO_2 <- ALO[,c(2:6,8,11:15)]

# To combine data
PMall <- data.frame()
PMall <- merge(ALP_2,ALI_2, by=c("Year","Month","Day","Month","Hour","Minute","S_no"))
PMall <- merge(PMall,ALO_2, by=c("Year","Month","Day","Month","Hour","Minute","S_no"))

PMall_2 <- data.frame()
TAD <- read.csv(paste0(location,"HiASAP/Questionnaire_TAD/output/2020_Training_Course_TAD.csv"))
PMall_2 <- merge(PMall,TAD, by=c("Year","Month","Day","Month","Hour","Minute_30","S_no"))

Meteor <- read.csv(paste0(location,"HiASAP/Meteor/Meteor_Hourly_All.csv"))
Meteor <- Meteor[,c(1:4,14)]
PMfinal <- merge(PMall_2,Meteor, by=c("Year","Month","Day","Month","Hour"))

write.csv(PMfinal,file=paste0(outputname,".csv"),row.names=FALSE)

# To select no-raining, awake and at-home period 
PMfinal_A_NR_Home <- PMfinal[which(PMfinal$Precp==0 & PMfinal$Act_Sleep==0 & PMfinal$Loc_Home==1),]

# To determine a final regression model by the stepwise regression method
# To remain the variables which you are interested
aa <- PMfinal_A_NR_Home[,c(9,13,23,50,51,52,62,63,66,67)]

# To use the stepwise regression method to identify and select the most useful explanatory variables from a list of 
# several plausible independent variables
Final_Model <- step(lm(ALP_PM2.5~.,data=aa),direction="both")
summary(Final_Model)

# In order to explain the set of dummy variables of trinary variable (window open, window closed and AC-on), 
# we add the dummy variable of "Vent_D3_2" into the final model 
Final_Model_2 <- lm(ALP_PM2.5 ~ ALO_PM2.5+S_Incense_JPaper+S_Other2+Vent_D3_1+Vent_D3_2+Season, data = aa)
summary(Final_Model_2)

# To determine the partial R2 of each independent variable
M1 <- lm(ALP_PM2.5 ~ 1, data = aa)
M2 <- lm(ALP_PM2.5 ~ ALO_PM2.5, data = aa)
M3 <- lm(ALP_PM2.5 ~ ALO_PM2.5+S_Incense_JPaper, data = aa)
M4 <- lm(ALP_PM2.5 ~ ALO_PM2.5+S_Incense_JPaper+S_Other2, data = aa)
M5 <- lm(ALP_PM2.5 ~ ALO_PM2.5+S_Incense_JPaper+S_Other2+Vent_D3_1, data = aa)
M6 <- lm(ALP_PM2.5 ~ ALO_PM2.5+S_Incense_JPaper+S_Other2+Vent_D3_1+Vent_D3_2, data = aa)

Partial_R2_1 <- rsq.partial(Final_Model_2,M6)
Partial_R2_2 <- rsq.partial(M6,M5)
Partial_R2_3 <- rsq.partial(M5,M4)
Partial_R2_4 <- rsq.partial(M4,M3)
Partial_R2_5 <- rsq.partial(M3,M2)
Partial_R2_6 <- rsq.partial(M2,M1)

## To print out GAMM results to txt file
sink("Exposure_Factor_Results.txt") # redirect console output to a file
print("Stepwise")
print(Final_Model)
print("Final model")
print(summary(Final_Model_2))
print("Partial R2 of Season")
print(Partial_R2_1)
print("Partial R2 of Vent_D3_2")
print(Partial_R2_2)
print("Partial R2 of Vent_D3_1")
print(Partial_R2_3)
print("Partial R2 of S_Other2")
print(Partial_R2_4)
print("Partial R2 of S_Incense_JPaper")
print(Partial_R2_5)
print("Partial R2 of ALO_PM2.5")
print(Partial_R2_6)
sink()  # return output to the terminal





