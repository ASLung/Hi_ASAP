##Questionnaire data processing
#remove previous memory in R.
rm(list=ls())

location <- "D:/"

cmd1 <- paste0("setwd('",location,"HiASAP/2020_Training_Course/Dataset/Questionnaire_TAD/output')")
eval(parse(text=cmd1))

way <- paste0(location,"HiASAP/2020_Training_Course/Dataset/Questionnaire_TAD")

Q <- read.csv(paste0(way,"/Questionnaire_Raw.csv"))

A_Age<-c()
for(i in 1:dim(Q)[1]){
    A_Age[i]<-107-Q$A_Birth[i]
}

A_Gender2 <- c()
for(i in 1:dim(Q)[1]){
    if(Q$A_Gender[i]==1){
        A_Gender2[i]<-1
    }else{
        A_Gender2[i]<-0
    }
}

C_BMI <- c()
for(i in 1:dim(Q)[1]){
    C_BMI[i]<-Q$C_Weight[i]/((Q$C_Height[i]/100)^2)
}

Qfinal<-data.frame(subset(Q,select=c(S_no,Season)),A_Age,A_Gender2,C_BMI)

colnames(Qfinal)<-c("S_no","Season","Age","Gender","BMI")
outputname<-"2020_Training_Course_Questionnaire.csv"
write.csv(Qfinal,outputname,row.names=FALSE,na="")

##TAD data processing
TAD <- read.csv(paste0(way,"/TAD_Raw.csv"))

Loc_Home <- c()
Loc_In <- c()
Loc_Out <- c()
Loc_Trans_In <- c()
Loc_Trans_Out <- c()
Loc_Trans <- c()
Loc_In_All <- c()
Loc_Out_All <- c()
Vent_Closed <- c()
Vent_Opened <- c()
Vent_AC <- c()
Act_Sleep <- c()
Act_Commute <- c()
Act_Work <- c()
Act_Cook <- c()
Act_Worship <- c()
Act_Shopping <- c()
Act_Exercise <- c()
Act_Eat <- c()
Act_Bath <- c()
Act_Sedentary <- c()
Act_Housework <- c()
Act_Other <- c()
S_Exhaust <- c()
S_Cooking <- c()
S_ETS <- c()
S_Dust <- c()
S_Incense <- c()
S_MosquitoCoil <- c()
S_Aromatic <- c()
S_Josspaper <- c()
S_OpenedBurning <- c()
S_Factory <- c()
S_Garbage <- c()
S_Other <- c()
S_Incense_JPaper <- c()


for(i in 1:dim(TAD)[1]){
    ifelse(TAD$Place1[i]==1 | TAD$Place2[i]==1,Loc_Home[i]<-1,Loc_Home[i]<-0)
    ifelse(TAD$Place1[i]==1 | TAD$Place1[i]==2 | TAD$Place1[i]==3 | TAD$Place1[i]==4 | TAD$Place1[i]==5 | TAD$Place1[i]==6 | TAD$Place1[i]==7 | TAD$Place1[i]==8 | TAD$Place1[i]==61 | TAD$Place2[i]==1 | TAD$Place2[i]==2 | TAD$Place2[i]==3 | TAD$Place2[i]==4 | TAD$Place2[i]==5 | TAD$Place2[i]==6 | TAD$Place2[i]==7 | TAD$Place2[i]==8 | TAD$Place2[i]==61,Loc_In[i]<-1,Loc_In[i]<-0)
    ifelse(TAD$Place1[i]==17 | TAD$Place1[i]==18 | TAD$Place1[i]==19 | TAD$Place1[i]==20 | TAD$Place1[i]==21 | TAD$Place1[i]==22 | TAD$Place1[i]==23 | TAD$Place1[i]==63 | TAD$Place2[i]==17 | TAD$Place2[i]==18 | TAD$Place2[i]==19 | TAD$Place2[i]==20 | TAD$Place2[i]==21 | TAD$Place2[i]==22 | TAD$Place2[i]==23 | TAD$Place2[i]==63,Loc_Out[i]<-1,Loc_Out[i]<-0)
    ifelse(TAD$Place1[i]==11 | TAD$Place1[i]==12 | TAD$Place1[i]==13 | TAD$Place1[i]==14 | TAD$Place2[i]==11 | TAD$Place2[i]==12 | TAD$Place2[i]==13 | TAD$Place2[i]==14,Loc_Trans_In[i]<-1,Loc_Trans_In[i]<-0)
    ifelse(TAD$Place1[i]==16 | TAD$Place1[i]==9 | TAD$Place1[i]==10 | TAD$Place1[i]==15 | TAD$Place1[i]==62 | TAD$Place2[i]==16 | TAD$Place2[i]==9 | TAD$Place2[i]==10 | TAD$Place2[i]==15 | TAD$Place2[i]==62,Loc_Trans_Out[i]<-1,Loc_Trans_Out[i]<-0)
    ifelse(TAD$Place1[i]==11 | TAD$Place1[i]==12 | TAD$Place1[i]==13 | TAD$Place1[i]==14 | TAD$Place1[i]==9 | TAD$Place1[i]==10 | TAD$Place1[i]==15 | TAD$Place1[i]==62 | TAD$Place2[i]==11 | TAD$Place2[i]==12 | TAD$Place2[i]==13 | TAD$Place2[i]==14 | TAD$Place2[i]==9 | TAD$Place2[i]==10 | TAD$Place2[i]==15 | TAD$Place2[i]==62,Loc_Trans[i]<-1,Loc_Trans[i]<-0)
    ifelse(TAD$Place1[i]==1 | TAD$Place1[i]==2 | TAD$Place1[i]==3 | TAD$Place1[i]==4 | TAD$Place1[i]==5 | TAD$Place1[i]==6 | TAD$Place1[i]==7 | TAD$Place1[i]==8 | TAD$Place1[i]==61 | TAD$Place1[i]==11 | TAD$Place1[i]==12 | TAD$Place1[i]==13 | TAD$Place1[i]==14 | TAD$Place2[i]==1 | TAD$Place2[i]==2 | TAD$Place2[i]==3 | TAD$Place2[i]==4 | TAD$Place2[i]==5 | TAD$Place2[i]==6 | TAD$Place2[i]==7 | TAD$Place2[i]==8 | TAD$Place2[i]==61 | TAD$Place2[i]==11 | TAD$Place2[i]==12 | TAD$Place2[i]==13 | TAD$Place2[i]==14,Loc_In_All[i]<-1,Loc_In_All[i]<-0)
    ifelse(TAD$Place1[i]==16 | TAD$Place1[i]==17 | TAD$Place1[i]==18 | TAD$Place1[i]==19 | TAD$Place1[i]==20 | TAD$Place1[i]==21 | TAD$Place1[i]==22 | TAD$Place1[i]==23 | TAD$Place1[i]==63 | TAD$Place1[i]==9 | TAD$Place1[i]==10 | TAD$Place1[i]==15 | TAD$Place1[i]==62 | TAD$Place2[i]==16 | TAD$Place2[i]==17 | TAD$Place2[i]==18 | TAD$Place2[i]==19 | TAD$Place2[i]==20 | TAD$Place2[i]==21 | TAD$Place2[i]==22 | TAD$Place2[i]==23 | TAD$Place2[i]==63 | TAD$Place2[i]==9 | TAD$Place2[i]==10 | TAD$Place2[i]==15 | TAD$Place2[i]==62,Loc_Out_All[i]<-1,Loc_Out_All[i]<-0)
    ifelse(TAD$Ventilation1[i]==1 | TAD$Ventilation2[i]==1,Vent_Closed[i]<-1,Vent_Closed[i]<-0)
    ifelse(TAD$Ventilation1[i]==2 | TAD$Ventilation1[i]==3 | TAD$Ventilation2[i]==2 | TAD$Ventilation2[i]==3,Vent_Opened[i]<-1,Vent_Opened[i]<-0)
    ifelse(TAD$Ventilation1[i]==4 | TAD$Ventilation1[i]==5 | TAD$Ventilation2[i]==4 | TAD$Ventilation2[i]==5,Vent_AC[i]<-1,Vent_AC[i]<-0)
    ifelse(TAD$Activity1[i]==1 | TAD$Activity2[i]==1,Act_Sleep[i]<-1,Act_Sleep[i]<-0)
    ifelse(TAD$Activity1[i]==2 | TAD$Activity2[i]==2,Act_Commute[i]<-1,Act_Commute[i]<-0)
    ifelse(TAD$Activity1[i]==3 | TAD$Activity2[i]==3,Act_Work[i]<-1,Act_Work[i]<-0)
    ifelse(TAD$Activity1[i]==4 | TAD$Activity2[i]==4,Act_Cook[i]<-1,Act_Cook[i]<-0)
    ifelse(TAD$Activity1[i]==5 | TAD$Activity2[i]==5,Act_Worship[i]<-1,Act_Worship[i]<-0)
    ifelse(TAD$Activity1[i]==6 | TAD$Activity2[i]==6,Act_Shopping[i]<-1,Act_Shopping[i]<-0)
    ifelse(TAD$Activity1[i]==7 | TAD$Activity2[i]==7,Act_Exercise[i]<-1,Act_Exercise[i]<-0)
    ifelse(TAD$Activity1[i]==8 | TAD$Activity2[i]==8,Act_Eat[i]<-1,Act_Eat[i]<-0)
    ifelse(TAD$Activity1[i]==9 | TAD$Activity2[i]==9,Act_Bath[i]<-1,Act_Bath[i]<-0)
    ifelse(TAD$Activity1[i]==10 | TAD$Activity2[i]==10,Act_Sedentary[i]<-1,Act_Sedentary[i]<-0)
    ifelse(TAD$Activity1[i]==11 | TAD$Activity2[i]==11,Act_Housework[i]<-1,Act_Housework[i]<-0)
    ifelse(TAD$Activity1[i]==64 | TAD$Activity2[i]==64,Act_Other[i]<-1,Act_Other[i]<-0)
    ifelse(TAD$AP1[i]==1 | TAD$AP2[i]==1 | TAD$AP3[i]==1,S_Exhaust[i]<-1,S_Exhaust[i]<-0)
    ifelse(TAD$AP1[i]==2 | TAD$AP2[i]==2 | TAD$AP3[i]==2,S_Cooking[i]<-1,S_Cooking[i]<-0)
    ifelse(TAD$AP1[i]==3 | TAD$AP2[i]==3 | TAD$AP3[i]==3,S_ETS[i]<-1,S_ETS[i]<-0)
    ifelse(TAD$AP1[i]==4 | TAD$AP2[i]==4 | TAD$AP3[i]==4,S_Dust[i]<-1,S_Dust[i]<-0)
    ifelse(TAD$AP1[i]==5 | TAD$AP2[i]==5 | TAD$AP3[i]==5,S_Incense[i]<-1,S_Incense[i]<-0)
    ifelse(TAD$AP1[i]==6 | TAD$AP2[i]==6 | TAD$AP3[i]==6,S_MosquitoCoil[i]<-1,S_MosquitoCoil[i]<-0)
    ifelse(TAD$AP1[i]==7 | TAD$AP2[i]==7 | TAD$AP3[i]==7,S_Aromatic[i]<-1,S_Aromatic[i]<-0)
    ifelse(TAD$AP1[i]==8 | TAD$AP2[i]==8 | TAD$AP3[i]==8,S_Josspaper[i]<-1,S_Josspaper[i]<-0)
    ifelse(TAD$AP1[i]==9 | TAD$AP2[i]==9 | TAD$AP3[i]==9,S_OpenedBurning[i]<-1,S_OpenedBurning[i]<-0)
    ifelse(TAD$AP1[i]==10 | TAD$AP2[i]==10 | TAD$AP3[i]==10,S_Factory[i]<-1,S_Factory[i]<-0)
    ifelse(TAD$AP1[i]==11 | TAD$AP2[i]==11 | TAD$AP3[i]==11,S_Garbage[i]<-1,S_Garbage[i]<-0)
    ifelse(TAD$AP1[i]==65 | TAD$AP2[i]==65 | TAD$AP3[i]==65,S_Other[i]<-1,S_Other[i]<-0)
    ifelse(TAD$AP1[i]==5 | TAD$AP2[i]==5 | TAD$AP3[i]==5 | TAD$AP1[i]==8 | TAD$AP2[i]==8 | TAD$AP3[i]==8,S_Incense_JPaper[i]<-1,S_Incense_JPaper[i]<-0)
}

TADr <- data.frame(subset(TAD,select=c(S_no,Year,Month,Day,Date,WD,Hour,Minute_30)),Loc_Home,Loc_In,Loc_Out,Loc_Trans_In,Loc_Trans_Out,Loc_Trans,Loc_In_All,Loc_Out_All,Vent_Closed,Vent_Opened,Vent_AC,Act_Sleep,Act_Commute,Act_Work,Act_Cook,Act_Worship,Act_Shopping,Act_Exercise,Act_Eat,Act_Bath,Act_Sedentary,Act_Housework,Act_Other,S_Exhaust,S_Cooking,S_ETS,S_Dust,S_Incense,S_MosquitoCoil,S_Aromatic,S_Josspaper,S_OpenedBurning,S_Factory,S_Garbage,S_Other,S_Incense_JPaper)

S_Other2<-c()
for(i in 1:dim(TADr)[1]){
    if(TADr$S_Dust[i]==1|TADr$S_MosquitoCoil[i]==1|TADr$S_Aromatic[i]==1|TADr$S_OpenedBurning[i]==1|TADr$S_Factory[i]==1|TADr$S_Garbage[i]==1|TADr$S_Other[i]==1){
        S_Other2[i]<-1
    }else{
        S_Other2[i]<-0
    }
}

S_Multiple<-c()
for(i in 1:dim(TADr)[1]){
    if(TADr$S_Exhaust[i]+TADr$S_Cooking[i]+TADr$S_ETS[i]+TADr$S_Incense_JPaper[i]+S_Other2[i]<=1){
        S_Multiple[i]<-0
    }else{
        S_Multiple[i]<-1
    }
}

S_None<-c()
for(i in 1:dim(TADr)[1]){
    if(TADr$S_Exhaust[i]==0&TADr$S_Cooking[i]==0&TADr$S_ETS[i]==0&TADr$S_Incense_JPaper[i]==0&S_Other2[i]==0){
        S_None[i]<-1
    }else{
        S_None[i]<-0
    }
}

Vent_D3_1<-c()
for(i in 1:dim(TADr)[1]){
    if(TADr$Vent_AC[i]==0 & TADr$Vent_Closed[i]==1 & Vent_Opened[i]==0){
        Vent_D3_1[i]<-1
    }else{
        Vent_D3_1[i]<-0
    }
}

Vent_D3_2<-c()
for(i in 1:dim(TADr)[1]){
    if(TADr$Vent_AC[i]==1 & TADr$Vent_Closed[i]==0 & Vent_Opened[i]==0){
        Vent_D3_2[i]<-1
    }else{
        Vent_D3_2[i]<-0
    }
}

Season <- c()
for(i in 1:dim(TADr)[1]){
    if(TADr$Year[i]==2018){
        Season[i]<-0
    }else{
        Season[i]<-1
    }
}

TADr <- data.frame(TADr,S_Other2,S_Multiple,S_None,Vent_D3_1,Vent_D3_2)

write.csv(TADr,file="2020_Training_Course_TAD.csv",row.names=FALSE)


