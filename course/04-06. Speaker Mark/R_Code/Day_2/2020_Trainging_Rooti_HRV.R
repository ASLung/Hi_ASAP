# To remove previous memory in R.
rm(list=ls())

# To update the R packages
update.packages("lubridate")
update.packages("plyr")
update.packages("tidyverse")
update.packages("jsonlite")
update.packages("data.table")

# To load the R packages
library(lubridate)
library(plyr)
library(tidyverse)
library(jsonlite)
library(data.table)

location <- "D:/"

# To set the output file
cmd1 <- paste0("setwd('",location,"HiASAP/HRV/output')")
eval(parse(text=cmd1))

# To set the raw data file
way <- paste0(location,"HiASAP/HRV/Raw_Data/")
# To set the ID list
subject<-dir(path=way, pattern="LA")

for (i in 1:length(subject)) {
      # To read the "result.json" file for getting the start time of Rooti (heart rate variability monitoring)
      Rooti_online_result<-list()
      Rooti_online_result[[i]]<- fromJSON(paste0(way, subject[i], "/OUTPUT/result.json"))
      start_time<-list()
      start_time[[i]]<-Rooti_online_result[[i]]$activity$startTime
      start_time[[i]]<-as.POSIXct(start_time[[i]], origin="1970-01-01",tz="Asia/Taipei")
    
      # To get the 5-min SDNN data
      aa <- read.table(paste0(way, subject[i], "/OUTPUT/SDNN_5.txt"))
      test<-substr(subject[i],1,5)
      Rooti_SDNN5<-data.frame(test,aa)
      colnames(Rooti_SDNN5)[names(Rooti_SDNN5) == "V1"]<-"SDNN5"
      
      total_time<-minutes(dim(Rooti_SDNN5)[1]*5)
      Datatime<-seq.POSIXt(start_time[[i]][1],start_time[[i]][1]+total_time , by = "5 mins")
      Datatime<-Datatime[1:(length(Datatime)-1)]
      
      Rooti_SDNN5<-data.frame(Datatime, subset(Rooti_SDNN5,select=c(test,SDNN5)))
    
      # To get the 5-min RMSSD data
      aa <- read.table(paste0(way, subject[i], "/OUTPUT/RMSSD_5.txt"))
      test<-substr(subject[i],1,5)
      Rooti_RMSSD5<-data.frame(test,aa)
      colnames(Rooti_RMSSD5)[names(Rooti_RMSSD5) == "V1"]<-"RMSSD5"
    
      Rooti_RMSSD5<-data.frame(Datatime, subset(Rooti_RMSSD5,select=c(test,RMSSD5)))
        
      # To get the 5-min LF/HF data
      aa <- read.table(paste0(way, subject[i], "/OUTPUT/lfhf_5.txt"))
      test<-substr(subject[i],1,5)
      Rooti_lfhf5<-data.frame(test,aa)
      colnames(Rooti_lfhf5)[names(Rooti_lfhf5) == "V1"]<-"LFHF5"
      
      # To get the 5-min LF data
      aa <- read.table(paste0(way, subject[i], "/OUTPUT/lf_5.txt"))
      test<-substr(subject[i],1,5)
      Rooti_lf5<-data.frame(test,aa)
      colnames(Rooti_lf5)[names(Rooti_lf5) == "V1"]<-"LF5"
      
      # To get the 5-min HF data
      aa <- read.table(paste0(way, subject[i], "/OUTPUT/hf_5.txt"))
      test<-substr(subject[i],1,5)
      Rooti_hf5<-data.frame(test,aa)
      colnames(Rooti_hf5)[names(Rooti_hf5) == "V1"]<-"HF5"
      
      # To get the 5-min VLF data
      aa <- read.table(paste0(way, subject[i], "/OUTPUT/vlf_5.txt"))
      test<-substr(subject[i],1,5)
      Rooti_vlf5<-data.frame(test,aa)
      colnames(Rooti_vlf5)[names(Rooti_vlf5) == "V1"]<-"VLF5"
      
      # To get the 5-min TP data
      aa <- read.table(paste0(way, subject[i], "/OUTPUT/tp_5.txt"))
      test<-substr(subject[i],1,5)
      Rooti_tp5<-data.frame(test,aa)
      colnames(Rooti_tp5)[names(Rooti_tp5) == "V1"]<-"TP5"
      
      # To get the 1-min HR data
      aa <- read.table(paste0(way, subject[i], "/OUTPUT/HR_full.txt"))
      test<-substr(subject[i],1,5)
      Rooti_HR<-data.frame(test,aa)
      colnames(Rooti_HR)[names(Rooti_HR) == "V1"]<-"HR"
      
      # To calculate the 5-min HR dat
      total_HR_time<-minutes(dim(Rooti_HR)[1]*1)
      Datatime_HR<-seq.POSIXt(start_time[[i]][1],start_time[[i]][1]+total_HR_time , by = "1 mins")
      Datatime_HR<-Datatime_HR[1:(length(Datatime_HR)-1)]
      
      Rooti_HR<-data.frame(Datatime_HR, Rooti_HR)
      Rooti_HR<-Rooti_HR %>%
        group_by(Datatime = cut(Datatime_HR, breaks="300 secs")) %>%
        summarize(
          HRsum5 = sum(HR),
          HRmean5 = floor(mean(HR)))
      Rooti_HR$Datatime <-ymd_hms(Rooti_HR$Datatime,tz="Asia/Taipei")
      
      # To get the activity data form G-sensor
      # To get the 1-min data of variations for three-axis
      aa <- read.table(paste0(way, subject[i], "/OUTPUT/Avg_XYZsum.txt"))
      test<-substr(subject[i],1,5)
      Rooti_gsensor<-data.frame(test,aa)
      colnames(Rooti_gsensor)[names(Rooti_gsensor) == "V1"]<-"Gsensor"
      
      # To calculate the 5-min data of variations for three-axis
      total_gsensor_time<-minutes(dim(Rooti_gsensor)[1]*1)
      Datatime_gsensor<-seq.POSIXt(start_time[[i]][1],start_time[[i]][1]+total_gsensor_time , by = "1 mins")
      Datatime_gsensor<-Datatime_gsensor[1:(length(Datatime_gsensor)-1)]
      
      Rooti_gsensor<-data.frame(Datatime_gsensor, Rooti_gsensor)
      Rooti_gsensor<-Rooti_gsensor %>%
        group_by(Datatime = cut(Datatime_gsensor, breaks="300 secs")) %>%
        summarize(Gsensor5 = sum(Gsensor))
      Rooti_gsensor$Datatime <-ymd_hms(Rooti_gsensor$Datatime,tz="Asia/Taipei")
      
      # To get the 1-min data of accelerations for three-axis
      aa <- list.files(paste0(way, subject[i], "/GSENSOR/"))
      bb <- read.table(paste0(way, subject[i], "/GSENSOR/",aa[1]),sep=",")
      cc <- bb
      for(j in 2:length(aa)){
          bb <- read.table(paste0(way, subject[i], "/GSENSOR/",aa[j]),sep=",")
          cc <- rbind(cc,bb)
      }
      test<-substr(subject[i],1,5)
      Rooti_gsensor_raw_data<-data.frame(test,subset(cc,select=c(V1:V5)))
      colnames(Rooti_gsensor_raw_data)<-c("S_no","Datatime","secondpoint", "X", "Y", "Z")
      Rooti_gsensor_raw_data$Datatime<-as.POSIXct(Rooti_gsensor_raw_data$Datatime, origin="1970-01-01",tz="Asia/Taipei")
      
      # To get the 5-min data of accelerations for three-axis
      Rooti_gsensor_raw_data<-Rooti_gsensor_raw_data %>% 
        group_by(Datatime = cut(Datatime, breaks="300 secs")) %>%
        summarize(meanX5 = round(mean(X),4),
                  meanY5 = round(mean(Y),4),
                  meanZ5 = round(mean(Z),4),
                  maxX5 = round(max(X),4),
                  maxY5 = round(max(Y),4),
                  maxZ5 = round(max(Z),4)
                  ) %>% 
      mutate(Datatime = ymd_hms(Datatime,tz="Asia/Taipei"))
      
      # To check whether the time of G-sensor is correct 
      gap_of_time<-seconds(Rooti_SDNN5$Datatime[1]-Rooti_gsensor_raw_data$Datatime[1])
      
      if(abs(gap_of_time)<=3){
      Rooti_gsensor_raw_data<-Rooti_gsensor_raw_data %>% 
        mutate(Datatime = Datatime +gap_of_time)
      }else{
        start_time_error_gsensor<-"Please check the start time of gsensor in GSENSOR folder and start time of activity in result.json."
        write.csv(start_time_error_gsensor,paste0("Start_time_error_in ",subject[i],"_gsensor.csv"),row.names = F)
      }
      
      # To get the sleeping index
      sleep_start_time<-list()
      in_bed_time<-list()
      sleep_idx<-list()
      Datatime_sleep<-data.frame()
      sleep_start_time[[i]]<-Rooti_online_result[[i]]$sleep$sleepStartTime
      if(!is.null(Rooti_online_result[[i]]$sleep$sleepStartTime)){
      sleep_start_time[[i]]<-as.POSIXct(sleep_start_time[[i]], origin="1970-01-01",tz="Asia/Taipei")
      in_bed_time[[i]]<-Rooti_online_result[[i]]$sleep$inBedTime
      sleep_idx[[i]]<-Rooti_online_result[[i]]$sleep$slp_idx
      for (s in 1:length(sleep_start_time[[i]])) {
      Datatime_sleep_m<-data.frame(Datatime =seq.POSIXt(sleep_start_time[[i]][s],sleep_start_time[[i]][s]+minutes(in_bed_time[[i]][s]) , by = "1 mins"))
      Datatime_sleep_m<-Datatime_sleep_m[(2:nrow(Datatime_sleep_m)),]
      sleep_idx[[i]][[s]]<-sleep_idx[[i]][[s]][(1:length(Datatime_sleep_m))]
      Datatime_sleep_m<-data.frame(Datatime =Datatime_sleep_m,sleep_idx=sleep_idx[[i]][[s]])
      Datatime_sleep<-rbind(Datatime_sleep_m,Datatime_sleep)
      Datatime_sleep$Datatime<-as.POSIXct(Datatime_sleep$Datatime, origin="1970-01-01",tz="Asia/Taipei")
      }
    
      # To check whether the time of sleeping is correct   
      Datatime_gsensor<-data.frame(Datatime = Datatime_gsensor)
      Datatime_gsensor$Datatime<-as.POSIXct(Datatime_gsensor$Datatime, origin="1970-01-01",tz="Asia/Taipei")
      if(second(Datatime_gsensor$Datatime[1])==0&second(Datatime_sleep$Datatime[1])>55){
        gap_of_time_sleep<-60-second(Datatime_sleep$Datatime[1])
      }else if(second(Datatime_gsensor$Datatime[1])==1&second(Datatime_sleep$Datatime[1])>55){
        gap_of_time_sleep<-61-second(Datatime_sleep$Datatime[1])
      }else if(second(Datatime_gsensor$Datatime[1])==2&second(Datatime_sleep$Datatime[1])>55){
        gap_of_time_sleep<-62-second(Datatime_sleep$Datatime[1])
      }else if(second(Datatime_gsensor$Datatime[1])>55&second(Datatime_sleep$Datatime[1])==0){
        gap_of_time_sleep<-second(Datatime_gsensor$Datatime[1])-60
      }else if(second(Datatime_gsensor$Datatime[1])>55&second(Datatime_sleep$Datatime[1])==1){
        gap_of_time_sleep<-second(Datatime_gsensor$Datatime[1])-61
      }else if(second(Datatime_gsensor$Datatime[1])>55&second(Datatime_sleep$Datatime[1])==2){
        gap_of_time_sleep<-second(Datatime_gsensor$Datatime[1])-62
      }else{
      gap_of_time_sleep<-second(Datatime_gsensor$Datatime[1])-second(Datatime_sleep$Datatime[1])
      }
      
      if(abs(gap_of_time_sleep)<=3){
      Datatime_sleep<-Datatime_sleep %>%
        mutate(Datatime = Datatime +gap_of_time_sleep) %>% 
        full_join(Datatime_gsensor,by = "Datatime")
      Datatime_sleep<-Datatime_sleep %>%
        group_by(Datatime = cut(Datatime, breaks="300 secs")) %>%
        summarize(sleep_idx5 = max(sleep_idx,na.rm=F)
        ) %>% 
        mutate(Datatime = ymd_hms(Datatime,tz="Asia/Taipei"))
      }else{
        start_time_error_sleep<-"Please check the start time of Sleep and start time of activity in result.json."
        write.csv(start_time_error_sleep,paste0("Start_time_error_in ",subject[i],"_sleep.csv"),row.names = F)
      }
      }
      
      # To combine all Rooti data for each subject
      Rooti_SDNN5<-Rooti_SDNN5 %>% 
        select(test, Datatime, SDNN5)
      Rooti_total<-data.frame(Rooti_SDNN5,Rooti_RMSSD5$RMSSD5,Rooti_lfhf5$LFHF5,Rooti_lf5$LF5,Rooti_hf5$HF5,Rooti_vlf5$VLF5,Rooti_tp5$TP5)
      colnames(Rooti_total)[names(Rooti_total) == "Rooti_RMSSD5.RMSSD5"]<-"RMSSD5"
      colnames(Rooti_total)[names(Rooti_total) == "Rooti_lfhf5.LFHF5"]<-"LFHF5"
      colnames(Rooti_total)[names(Rooti_total) == "Rooti_lf5.LF5"]<-"LF5"
      colnames(Rooti_total)[names(Rooti_total) == "Rooti_hf5.HF5"]<-"HF5"
      colnames(Rooti_total)[names(Rooti_total) == "Rooti_vlf5.VLF5"]<-"VLF5"
      colnames(Rooti_total)[names(Rooti_total) == "Rooti_tp5.TP5"]<-"TP5"
      Rooti_total<-Rooti_total %>% 
        full_join(Rooti_gsensor,by = "Datatime")
      Rooti_total<-Rooti_total %>% 
        full_join(Rooti_gsensor_raw_data,by = "Datatime")
      if(!is.null(Rooti_online_result[[i]]$sleep$sleepStartTime)){
      Rooti_total<-Rooti_total %>% 
        full_join(Datatime_sleep,by = "Datatime")
      }else{
        Rooti_total$sleep_idx5<-NA
      }
      Rooti_total<-Rooti_total %>% 
        full_join(Rooti_HR,by = "Datatime")
    
      Rooti_total$sleep_idx5[is.na(Rooti_total$sleep_idx5)] <- 4
      
      Rooti_total<-Rooti_total %>% 
        filter(!(is.na(test)))
      
      S_no<-substr(subject[i],1,5)
      Rooti_total<-data.frame(S_no,Rooti_total)
      
      Rooti_total<-Rooti_total %>% 
        select(S_no,Datatime,HRsum5,HRmean5,SDNN5,RMSSD5,LFHF5,LF5,HF5,VLF5,TP5,Gsensor5,meanX5,meanY5,meanZ5,maxX5,maxY5,maxZ5,sleep_idx5)
      
      # To exclude data of ineffective time (bad time) and extreme data
      badtime_path <- list.files(paste0(way, subject[i], "/OUTPUT/bad_time.txt"))
      
      bad_time<-list()
      if(length(badtime_path)==0){
          bad_time[[i]]<-Rooti_online_result[[i]]$Q_factor$bad_min
      }else{
          bad_time <- read.table(paste0(way, subject[i], "/OUTPUT/bad_time.txt"))
          for (j in 1:nrow(bad_time[[i]])) {
              bad_time[[i]][j]<-start_time[[i]][1]+minutes(bad_time[[i]][j])
          }
      }
      
      bad_time[[i]]<-data.frame(V1 = bad_time[[i]][[1]])
      bad_time[[i]]$V1<-as.POSIXct(bad_time[[i]]$V1, origin="1970-01-01",tz="Asia/Taipei")
    
      Rooti_total$bad_time<-0
      for (q in 1:(nrow(bad_time[[i]]))) {
      for (k in 1:(nrow(Rooti_total)-1)) {
        if(!(Rooti_total$Datatime[k]<=bad_time[[i]]$V1[q])&!(bad_time[[i]]$V1[q]<Rooti_total$Datatime[k+1])&(Rooti_total$bad_time[k]==0)){
          Rooti_total$bad_time[k]<-0
        }else if(!(Rooti_total$Datatime[k]<=bad_time[[i]]$V1[q])&!(bad_time[[i]]$V1[q]<Rooti_total$Datatime[k+1])&(Rooti_total$bad_time[k]==1)){
          Rooti_total$bad_time[k]<-1
        }else if((Rooti_total$Datatime[k]<=bad_time[[i]]$V1[q])&(bad_time[[i]]$V1[q]<Rooti_total$Datatime[k+1])&(Rooti_total$bad_time[k]==1)){
          Rooti_total$bad_time[k]<-1
        }else if((Rooti_total$Datatime[k]<=bad_time[[i]]$V1[q])&(bad_time[[i]]$V1[q]<Rooti_total$Datatime[k+1])&(Rooti_total$bad_time[k]==0)){
          Rooti_total$bad_time[k]<-1
        }
      }
      }
      for (q in 1:nrow(bad_time[[i]])) {
        for (k in nrow(Rooti_total)) {
          if(!(Rooti_total$Datatime[k]<=bad_time[[i]]$V1[q])&!(bad_time[[i]]$V1[q]<=(Rooti_total$Datatime[k]+minutes(4)))&(Rooti_total$bad_time[k]==0)){
            Rooti_total$bad_time[k]<-0
          }else if(!(Rooti_total$Datatime[k]<=bad_time[[i]]$V1[q])&!(bad_time[[i]]$V1[q]<=(Rooti_total$Datatime[k]+minutes(4)))&(Rooti_total$bad_time[k]==1)){
            Rooti_total$bad_time[k]<-1
          }else if((Rooti_total$Datatime[k]<=bad_time[[i]]$V1[q])&(bad_time[[i]]$V1[q]<=(Rooti_total$Datatime[k]+minutes(4)))&(Rooti_total$bad_time[k]==1)){
            Rooti_total$bad_time[k]<-1
          }else if((Rooti_total$Datatime[k]<=bad_time[[i]]$V1[q])&(bad_time[[i]]$V1[q]<=(Rooti_total$Datatime[k]+minutes(4)))&(Rooti_total$bad_time[k]==0)){
            Rooti_total$bad_time[k]<-1
          }
        }
      }
      Rooti_total<-Rooti_total %>% 
        filter(!(bad_time==1)) %>% 
        filter(SDNN5>0 & SDNN5<400 & LFHF5>0.01 & HRmean5>40 & HRmean5<200) %>% 
        select(-c(bad_time))
    
    write.csv(Rooti_total, paste0("HRV_",subject[i],".csv"),row.names = F)
}


# To combine HRV data for all subjects
way2 <- paste0(location,"HiASAP/HRV/output")
aa1 <- list.files(way2,pattern="HRV")

HRV <- data.frame()
filename <- paste0(way2,"/",aa1[1])
cc <- read.csv(filename)
HRV <- cc
for(k in 2:length(aa1)){
    filename <- paste0(way2,"/",aa1[k])
    cc <- read.csv(filename)
    HRV <- rbind(HRV,cc)
}

# To create the time variables (year, month, day, hour and minute) for the following data matching  
library(lubridate)
yy<-c()    
mm<-c()    
dd<-c()    
hh<-c()    
mn<-c()    
for(l in 1:dim(HRV)[1]){
    if(nchar(as.character(HRV$Datatime[l]))==14){
        yy[l] <- as.numeric(substr(HRV$Datatime[l],1,4))
        mm[l] <- as.numeric(substr(HRV$Datatime[l],6,6))
        dd[l] <- as.numeric(substr(HRV$Datatime[l],8,8))
        hh[l] <- as.numeric(substr(HRV$Datatime[l],10,11))
        mn[l] <- as.numeric(substr(HRV$Datatime[l],13,14))
    }else{
        if(nchar(as.character(HRV$Datatime[l]))==15){
            yy[l] <- as.numeric(substr(HRV$Datatime[l],1,4))
            mm[l] <- as.numeric(substr(HRV$Datatime[l],6,6))
            dd[l] <- as.numeric(substr(HRV$Datatime[l],8,9))
            hh[l] <- as.numeric(substr(HRV$Datatime[l],11,12))
            mn[l] <- as.numeric(substr(HRV$Datatime[l],14,15))
    }else{
            yy[l] <- as.numeric(substr(HRV$Datatime[l],1,4))
            mm[l] <- as.numeric(substr(HRV$Datatime[l],6,7))
            dd[l] <- as.numeric(substr(HRV$Datatime[l],9,10))
            hh[l] <- as.numeric(substr(HRV$Datatime[l],12,13))
            mn[l] <- as.numeric(substr(HRV$Datatime[l],15,16))
        }
    }
}
mn_30 <- c()
for (l in 1:length(mn)) {
    if(mn[l] < 30){
        mn_30[l] <- 1
    }else{
        mn_30[l] <- 2
    }
}
date_1 <- c(ymd_hm(paste0(yy,"-",mm,"-",dd," ",hh,":",mn)))
HRVfinal <- data.frame()
for(j in 1:dim(HRV)[1]){
    HRVfinal[j,1]<-date_1[j]
    HRVfinal[j,2]<-yy[j]
    HRVfinal[j,3]<-mm[j]
    HRVfinal[j,4]<-dd[j]
    HRVfinal[j,5]<-hh[j]
    HRVfinal[j,6]<-mn[j]
    HRVfinal[j,7]<-mn_30[j]
    HRVfinal[j,8]<-HRV[j,1]
    HRVfinal[j,9]<-HRV[j,3]
    HRVfinal[j,10]<-HRV[j,4]
    HRVfinal[j,11]<-HRV[j,5]
    HRVfinal[j,12]<-HRV[j,6]
    HRVfinal[j,13]<-HRV[j,7]
    HRVfinal[j,14]<-HRV[j,8]
    HRVfinal[j,15]<-HRV[j,9]
    HRVfinal[j,16]<-HRV[j,10]
    HRVfinal[j,17]<-HRV[j,11]
    HRVfinal[j,18]<-HRV[j,12]
    HRVfinal[j,19]<-HRV[j,13]
    HRVfinal[j,20]<-HRV[j,14]
    HRVfinal[j,21]<-HRV[j,15]
    HRVfinal[j,22]<-HRV[j,16]
    HRVfinal[j,23]<-HRV[j,17]
    HRVfinal[j,24]<-HRV[j,18]
    HRVfinal[j,25]<-HRV[j,19]
}
colnames(HRVfinal)<-c("Date","Year","Month","Day","Hour","Minute","Minute_30","S_no","HRsum5","HRmean5","RMSSD5","SDNN5","LFHF5","LF5","HF5","VLF5","TP5","Gsensor5","MeanX5","MeanY5","MeanZ5","MaxX5","MaxY5","MaxZ5","Sleep5")
outputname<-"HRV_5 minute_All.csv"
write.csv(HRVfinal,outputname,row.names=FALSE,na="")


