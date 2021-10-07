# To remove previous memory in R.
rm(list=ls())

location <- "D:/"

# To set the output file
cmd1 <- paste0("setwd('",location,"HiASAP/PM/output')")
eval(parse(text=cmd1))

# To read the PM (AS-LUNG) data
way <- paste0(location,"HiASAP/PM/Raw_Data")
aa <- dir(path=way)
for(i in 1:length(aa)){
    way2 <- paste0(way,"/",aa[i])
    aa1 <- dir(path=way2,pattern="AS")
    for(p in 1:length(aa1)){
        ASLUNG <- data.frame()
        fileloc <- paste0(way2,"/",aa1[p])
        bb <- list.files(fileloc,pattern='csv')
        filename <- paste0(fileloc,"/",bb[1])
        cc <- read.csv(filename)
        ASLUNG <- cc
        for(k in 2:length(bb)){
            filename <- paste0(fileloc,"/",bb[k])
            cc <- read.csv(filename)
            ASLUNG <- rbind(ASLUNG,cc)
        }
        
        # To select the variables of time, temperature, relative humidity, CO2, corrected PM1 and corrected PM2.5
        ASLUNGt <- data.frame(subset(ASLUNG,select=c(datatime,date,time,sht_t,sht_h,co2,cPM1,cPM2.5)))
        
        # To exclude the time without PM2.5 data
        ASLUNGt<-ASLUNGt %>% 
            filter(!(is.na(cPM2.5)))
        
        # To create the "Season" variable (fall=0 and winter=1)
        Season <- c()
        for(i in 1:dim(ASLUNGt)[1]){
            if(substr(ASLUNGt$date[i],1,4)==2018){
                Season[i]<-0
            }else{
                Season[i]<-1
            }
        }
        
        # To create the variable of type of AS-LUNG (outdoor=1, indoor=2 and personal=3)
        AL_Type <- c()
        if(substr(aa1[p],9,9)=="O"){
            AL_Type<-1
        }else{
            if(substr(aa1[p],9,9)=="I"){
                AL_Type<-2
            }else{
                AL_Type<-3
            }
        }
        
        ifelse(substr(aa1[p],9,9)=="O",AL_Type<-1,ifelse(substr(aa1[p],9,9)=="I",AL_Type<-2,3))
        
        ASLUNGt <- data.frame(Season,AL_Type,ASLUNGt)
        
        outputname<-paste0("PM_",substr(bb[k],10,14),"_",Season[i]+1,"_",substr(aa1[p],9,9),"_Orig.csv")
        write.csv(ASLUNGt,outputname,row.names=FALSE,na="")
    }
}

# To calculate 5-min average PM data for Generalized Additive Mixed Model (GAMM) (based on Rooti time)      
way_Rooti <- paste0(location,"HiASAP/HRV/Raw_Data/")
aa2 <- list.files(paste0(location,"HiASAP/PM/output/"),pattern="P_Orig")
for (p in 1) {
    # To read the time of heart rate variability monitoring form Rooti
    filename <- paste0(location,"HiASAP/PM/output/",aa2[p])
    ASLUNGt <- read.csv(filename)
    Rooti_online_result<- fromJSON(paste0(way_Rooti, substr(aa2[p],4,10), "/OUTPUT/result.json"))
    start_time<-Rooti_online_result$activity$startTime
    start_time<-as.POSIXct(start_time, origin="1970-01-01",tz='Asia/Taipei')
    end_time<-Rooti_online_result$activity$endTime
    end_time<-as.POSIXct(end_time, origin="1970-01-01",tz='Asia/Taipei')
    
    from <- as.POSIXct(substr(start_time,1,16),tz="Asia/Taipei")
    to <- as.POSIXct(substr(end_time,1,16),tz="Asia/Taipei")
    sort_out_time<-data.frame(date=seq.POSIXt(from, to, by = "15 secs",tz="Asia/Taipei"))
    Date_AL<-seq.POSIXt(from, to, by = "15 secs",tz="Asia/Taipei")
    Date_AL2<-Date_AL[1:(length(Date_AL)-1)]
    
    date_1<-c(ymd(as.character(ASLUNGt$date)))
    time<-substr(ASLUNGt$time,1,8)
    date<-paste(date_1,time)
    ASLUNGt2<-data.frame(date,ASLUNGt)
    
    ASLUNGt2$date <- as.POSIXct(ASLUNGt2$date,tz="Asia/Taipei")
    ASLUNGt3<-data.frame()
    # If the start time of PM monitoring was different from the start time of HRV monitoring,
    # we add the start time of HRV monitoring to PM data to have the consistent 5-min interval
    if((substr(ASLUNGt2$date[1],1,16))!=(substr(Date_AL2[1],1,16))){
        dd <- as.POSIXct(Date_AL2[1],tz="Asia/Taipei")
        Add_Row <- data.frame()
        Add_Row <- data.frame(date=as.factor(dd),Season="",AL_Type="",datatime="",date.1="",time="",sht_t="",sht_h="",co2="",cPM1="",cPM2.5="")
        ASLUNGt3<- rbind(ASLUNGt2,Add_Row)
    }else{
        ASLUNGt3<- ASLUNGt2
    }
    ASLUNGt3 <- merge(ASLUNGt3,sort_out_time,by="date")
    
    Date_AL<-seq.POSIXt(ASLUNGt3$date[1], ASLUNGt3$date[dim(ASLUNGt3)[1]], by = "15 secs",tz="Asia/Taipei")
    Date_AL2<-c(ASLUNGt3$date)
    
    # To calculate 5-min average PM data
    ALFinal <-ASLUNGt3 %>%
        group_by(date = cut(Date_AL2, breaks="300 secs")) %>%
        summarize(
            TEM = mean(as.numeric(sht_t), na.rm = TRUE),
            HUM = mean(as.numeric(sht_h), na.rm = TRUE),
            PM1 = mean(as.numeric(cPM1), na.rm = TRUE),
            PM2.5 = mean(as.numeric(cPM2.5), na.rm = TRUE),
            CO2 = mean(as.numeric(co2), na.rm = TRUE),
            Freq = length(as.numeric(cPM2.5)))
    ALFinal$date <-ymd_hms(ALFinal$date,tz="Asia/Taipei")
    ALFinal2 <- ALFinal[which(ALFinal$Freq>=10),]
    colnames(ALFinal2)<-c("Date","TEM","HUM","PM1","PM2.5","CO2","Freq")
    
    S_no<-substr(aa2[p],4,8)        
    
    Season <- as.numeric(substr(aa2[p],10,10))-1
    
    AL_Type<-3
    
    ALFinal2 <- data.frame(S_no,Season,AL_Type,subset(ALFinal2,select=c(Date,TEM,HUM,PM1,PM2.5,CO2)))
    outputname<-paste0(substr(aa2[p],1,13),"5 min_Rooti_Time.csv")
    write.csv(ALFinal2,outputname,row.names=FALSE,na="")
}

# To combine PM data for all subjects
way <- paste0(location,"HiASAP/PM/output")
bb <- list.files(way,pattern='Rooti_Time')
filename <- paste0(way,"/",bb[1])
cc <- read.csv(filename)
ASLUNG <- cc
for(k in 2:length(bb)){
    filename <- paste0(way,"/",bb[k])
    cc <- read.csv(filename)
    ASLUNG <- rbind(ASLUNG,cc)
}

# To create the time variables (year, month, day, hour and minute) for the following data matching 
library('lubridate')
date_1 <- substr(ASLUNG$Date,1,10)
date_2 <- substr(ASLUNG$Date,12,16)
date_3 <- c(ymd_hm(paste(date_1,date_2)))
yy <- c(substr(date_3,1,4))
mn <- c(substr(date_3,6,7))
dd <- c(substr(date_3,9,10))
hh <- c(substr(date_3,12,13))
mm <- c(substr(date_3,15,16))
mm_30 <- c()
for (l in 1:length(mm)) {
    if(mm[l] < 30){
        mm_30[l] <- 1
    }else{
        mm_30[l] <- 2
    }
}
ALfinal<-data.frame()
for(j in 1:length(date_3)[1]){
    ALfinal[j,1]<-date_3[j]
    ALfinal[j,2]<-yy[j]
    ALfinal[j,3]<-mn[j]
    ALfinal[j,4]<-dd[j]
    ALfinal[j,5]<-hh[j]
    ALfinal[j,6]<-mm[j]
    ALfinal[j,7]<-mm_30[j]
    ALfinal[j,8]<-ASLUNG$S_no[j]
    ALfinal[j,9]<-ASLUNG$Season[j]
    ALfinal[j,10]<-ASLUNG$AL_Type[j]
    ALfinal[j,11]<-ASLUNG$TEM[j]
    ALfinal[j,12]<-ASLUNG$HUM[j]
    ALfinal[j,13]<-ASLUNG$PM1[j]
    ALfinal[j,14]<-ASLUNG$PM2.5[j]
    ALfinal[j,15]<-ASLUNG$CO2[j]
}
colnames(ALfinal)<-c("Date","Year","Month","Day","Hour","Minute","Minute_30","S_no","Season","AL_Type","TEM","HUM","PM1","PM2.5","CO2")

outputname<-paste0("PM_5 min_Rooti_Time_All.csv")
write.csv(ALfinal,outputname,row.names=FALSE)

