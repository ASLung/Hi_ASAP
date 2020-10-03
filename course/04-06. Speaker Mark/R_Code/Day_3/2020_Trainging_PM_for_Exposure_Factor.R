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
        
        # To calculate 5-min average PM data for exposure factor (based on ASLUNG time)    
        library('lubridate')
        date_1<-c(ymd(as.character(ASLUNGt$date)))
        time<-substr(ASLUNGt$time,1,5)
        date_2<-paste(date_1,time)
        mm<-c(as.numeric(substr(date_2,16,16)))
        mm5<-c()
        for (l in 1:length(mm)) {
            if(mm[l]<5){
                mm5[l]<-"0~4"
            }else{
                mm5[l]<-"5~9"
            }
        }
        date_3 <- paste0(substr(date_2,1,15),mm5)
        date_4<-as.data.frame(table(date_3))
        ALFinal<-data.frame()
        for(j in 1:dim(date_4)[1]){
            ALFinal[j,1]<-date_4[j,1]
            ALFinal[j,2]<-substr(bb[k],10,14)
            ALFinal[j,3]<-mean(as.numeric(ASLUNGt[which(date_3==date_4[j,1]),1]),na.rm = TRUE) # 0=hot 1=cold
            ALFinal[j,4]<-mean(as.numeric(ASLUNGt[which(date_3==date_4[j,1]),2]),na.rm = TRUE) # 1=outdoor 2=indoor 3=Personal
            ALFinal[j,5]<-mean(as.numeric(ASLUNGt[which(date_3==date_4[j,1]),6]),na.rm = TRUE)
            ALFinal[j,6]<-mean(as.numeric(ASLUNGt[which(date_3==date_4[j,1]),7]),na.rm = TRUE)
            ALFinal[j,7]<-mean(as.numeric(ASLUNGt[which(date_3==date_4[j,1]),9]),na.rm = TRUE)
            ALFinal[j,8]<-mean(as.numeric(ASLUNGt[which(date_3==date_4[j,1]),10]),na.rm = TRUE)
            ALFinal[j,9]<-mean(as.numeric(ASLUNGt[which(date_3==date_4[j,1]),8]),na.rm = TRUE)
            ALFinal[j,10]<-date_4[j,2]
        }
        colnames(ALFinal)<-c("Date","S_no","Season","AL_Type","TEM","HUM","PM1","PM2.5","CO2","Freq")
        # To exclude the 5-min intervals which contained less than half of expected number of data
        if(substr(aa1[p],9,9)=="O"){
            ALFinal2 <- ALFinal[which(ALFinal$Freq>=3),]
        }else{
            ALFinal2 <- ALFinal[which(ALFinal$Freq>=10),]
        }

        ALFinal2 <- data.frame(subset(ALFinal2,select=c(Date,S_no,Season,AL_Type,TEM,HUM,PM1,PM2.5,CO2)))
        outputname<-paste0("PM_",substr(bb[k],10,14),"_",Season[i]+1,"_",substr(aa1[p],9,9),"_5 min_ASLUNG_Time.csv")
        write.csv(ALFinal2,outputname,row.names=FALSE,na="")
    }
}

# To combine PM data for all subjects
way <- paste0(location,"HiASAP/PM/output")
bb <- list.files(way,pattern='ASLUNG_Time')
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

outputname<-paste0("PM_5 min_ASLUNG_Time_All.csv")
write.csv(ALfinal,outputname,row.names=FALSE)

