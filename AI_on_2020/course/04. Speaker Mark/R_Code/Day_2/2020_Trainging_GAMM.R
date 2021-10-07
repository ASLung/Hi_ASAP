# To remove previous memory in R.
rm(list=ls())

# To install the R package (only for the first time to run)
#install.packages("mgcv")

# To load the R package
library(mgcv)

location <- "D:/"

# To set the output file
cmd1 <- paste0("setwd('",location,"HiASAP/GAMM/output')")
eval(parse(text=cmd1))

outputname <- "GAMM"

# To combine PM, questionnaire, TAD and meteorological data with HRV data
PM <- read.csv(paste0(location,"HiASAP/PM/output/PM_5 min_Rooti_Time_All.csv"))
HRV <- read.csv(paste0(location,"HiASAP/HRV/output/HRV_5 minute_All.csv"))
HRV <- HRV[,c(2:25)]

PMall <- data.frame()
PMall <- merge(PM,HRV, by=c("Year","Month","Day","Month","Hour","Minute","Minute_30","S_no"))

PMall_2 <- data.frame()
QA <- read.csv(paste0(location,"HiASAP/Questionnaire_TAD/output/2020_Training_Course_Questionnaire.csv"))
PMall_2 <- merge(PMall,QA, by=c("S_no","Season"))

PMall_3 <- data.frame()
TAD <- read.csv(paste0(location,"HiASAP/Questionnaire_TAD/output/2020_Training_Course_TAD.csv"))
PMall_3 <- merge(PMall_2,TAD, by=c("Year","Month","Day","Month","Hour","Minute_30","S_no"))

Meteor <- read.csv(paste0(location,"HiASAP/Meteor/Meteor_Hourly_All.csv"))
Meteor <- Meteor[,c(1:4,14)]
PMall_4 <- merge(PMall_3,Meteor, by=c("Year","Month","Day","Month","Hour"))

## To create a subject-day variable for autocorrelation adjustment
library(lubridate)
Time_1 <- ymd(paste0(PMall_4$Year,'-',PMall_4$Month,'-',PMall_4$Day))

S_no_Day <- c()
S_no_Day <- paste0(PMall_4$S_no,"_",Time_1)

## Log-transformed HRV
lg_HRsum5 <- log10(PMall_4$HRsum5)
lg_HRmean5 <- log10(PMall_4$HRmean5)
lg_SDNN5 <- log10(PMall_4$SDNN5)
lg_RMSSD5 <- log10(PMall_4$RMSSD5)
lg_LFHF5 <- log10(PMall_4$LFHF5)
lg_LF5 <- log10(PMall_4$LF5)
lg_HF5 <- log10(PMall_4$HF5)
lg_VLF5 <- log10(PMall_4$VLF5)
lg_TP5 <- log10(PMall_4$TP5)

# To create the activity indexes
Activitymean <- (PMall_4$MeanX5^2+PMall_4$MeanY5^2+PMall_4$MeanZ5^2)^0.5
Activitymax <- (PMall_4$MaxX5^2+PMall_4$MaxY5^2+PMall_4$MaxZ5^2)^0.5

# To create the variable of the time of day
Time<-PMall_4$Hour*12+PMall_4$Minute/5+1

Age_G<-c()
for(i in 1:dim(PMall_4)[1]){
    ifelse(PMall_4$Age[i]<60,Age_G[i]<-0,Age_G[i]<-1)
}

BMI_G<-c()
for(i in 1:dim(PMall_4)[1]){
    if(PMall_4$BMI[i]>=24){
        BMI_G[i]<-1
    }else{
        BMI_G[i]<-0
    }
}

PMfinal <- data.frame(PMall_4,lg_HRsum5,lg_HRmean5,lg_SDNN5,lg_RMSSD5,lg_LFHF5,lg_LF5,lg_HF5,lg_VLF5,lg_TP5,Activitymean,Activitymax,Time,S_no_Day,Age_G,BMI_G)
write.csv(PMfinal,file=paste0(outputname,".csv"),row.names=FALSE)

# Select no-raining and awake period
PMfinal_A_NR <- PMfinal[which(PMfinal$Precp==0 & PMfinal$Sleep5==4),]

# To run the GAMM for each HRV indices
lg_SDNN<-gamm(lg_SDNN5~PM2.5+Loc_Out+Season+Age_G+BMI_G+s(Activitymean,bs=c("tp"))+Gender+TEM+s(Time,bs=c("cc")),data=PMfinal_A_NR,random=list(S_no=~1),correlation=corCAR1(form=~Time|S_no_Day))
lg_LFHF<-gamm(lg_LFHF5~PM2.5+Loc_Out+Season+Age_G+BMI_G+s(Activitymean,bs=c("tp"))+Gender+TEM+s(Time,bs=c("cc")),data=PMfinal_A_NR,random=list(S_no=~1),correlation=corCAR1(form=~Time|S_no_Day))
lg_HRsum<-gamm(lg_HRsum5~PM2.5+Loc_Out+Season+Age_G+BMI_G+s(Activitymean,bs=c("tp"))+Gender+TEM+s(Time,bs=c("cc")),data=PMfinal_A_NR,random=list(S_no=~1),correlation=corCAR1(form=~Time|S_no_Day))
lg_HRmean<-gamm(lg_HRmean5~PM2.5+Loc_Out+Season+Age_G+BMI_G+s(Activitymean,bs=c("tp"))+Gender+TEM+s(Time,bs=c("cc")),data=PMfinal_A_NR,random=list(S_no=~1),correlation=corCAR1(form=~Time|S_no_Day))
lg_RMSSD<-gamm(lg_RMSSD5~PM2.5+Loc_Out+Season+Age_G+BMI_G+s(Activitymean,bs=c("tp"))+Gender+TEM+s(Time,bs=c("cc")),data=PMfinal_A_NR,random=list(S_no=~1),correlation=corCAR1(form=~Time|S_no_Day))
lg_LF<-gamm(lg_LF5~PM2.5+Loc_Out+Season+Age_G+BMI_G+s(Activitymean,bs=c("tp"))+Gender+TEM+s(Time,bs=c("cc")),data=PMfinal_A_NR,random=list(S_no=~1),correlation=corCAR1(form=~Time|S_no_Day))
lg_HF<-gamm(lg_HF5~PM2.5+Loc_Out+Season+Age_G+BMI_G+s(Activitymean,bs=c("tp"))+Gender+TEM+s(Time,bs=c("cc")),data=PMfinal_A_NR,random=list(S_no=~1),correlation=corCAR1(form=~Time|S_no_Day))
lg_VLF<-gamm(lg_VLF5~PM2.5+Loc_Out+Season+Age_G+BMI_G+s(Activitymean,bs=c("tp"))+Gender+TEM+s(Time,bs=c("cc")),data=PMfinal_A_NR,random=list(S_no=~1),correlation=corCAR1(form=~Time|S_no_Day))
lg_TP<-gamm(lg_TP5~PM2.5+Loc_Out+Season+Age_G+BMI_G+s(Activitymean,bs=c("tp"))+Gender+TEM+s(Time,bs=c("cc")),data=PMfinal_A_NR,random=list(S_no=~1),correlation=corCAR1(form=~Time|S_no_Day))

# Directly show results in the Console window 
summary(lg_SDNN$gam)
summary(lg_LFHF$gam)
summary(lg_HRsum$gam)
summary(lg_HRmean$gam)
summary(lg_RMSSD$gam)
summary(lg_LF$gam)
summary(lg_HF$gam)
summary(lg_VLF$gam)
summary(lg_TP$gam)

# To print out GAMM results to txt file
sink("GAMM_Results.txt") # redirect console output to a file
print(summary(lg_SDNN$gam))
print(summary(lg_LFHF$gam))
print(summary(lg_HRsum$gam))
print(summary(lg_HRmean$gam))
print(summary(lg_RMSSD$gam))
print(summary(lg_LF$gam))
print(summary(lg_HF$gam))
print(summary(lg_VLF$gam))
print(summary(lg_TP$gam))
sink()  # close connection to file




