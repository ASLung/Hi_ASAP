#read data from the "input" folder
data_array <- read.csv(file='./input/data_community_workshop.csv')

# convert a character string type to "Date Time" type
data_time <- strptime(data_array$time, "%Y/%m/%d %H:%M")
data_array$month <- as.integer(strftime(data_time,"%m"))
data_array$hour <- as.integer(strftime(data_time,"%H"))

# create the dummy array
## for traffic type 1_traffic_passing_by
data_array$traffic_passing_by <- 0
data_array$traffic_passing_by[(data_array$site %in% c('C_1','C_2','C_3','C_4','C_5'))] <- 1

## for traffic type 2_traffic_stop_n_go
data_array$traffic_stop_n_go <- 0
data_array$traffic_stop_n_go[(data_array$site %in% c('C_6','C_8','C_9','C_10'))] <- 1

## for temple
data_array$temple <- 0
data_array$temple[(data_array$site %in% c('C_6','C_9','C_10'))] <- 1

## for market
data_array$market <- 0
data_array$market[(data_array$site %in% c('C_3'))] <- 1

## for vendor
data_array$vendor <- 0
data_array$vendor[(data_array$site %in% c('C_5'))&(data_array$hour>=16) & (data_array$hour<=21)] <- 1

## for gas station
data_array$gas_stat <- 0
data_array$gas_stat[(data_array$site %in% c('C_4'))] <- 1

## for school
data_array$school <- 0
data_array$school[(data_array$site %in% c('C_1'))] <- 1

## for season
data_array$season[data_array$month==7] <- 0
data_array$season[data_array$month==12] <- 1

# build the multiple regression model
mlr<-lm(formula= site_pm2.5 ~ traffic_passing_by + traffic_stop_n_go + temple 
        + market + gas_stat + vendor + school + season + high_level_pm2.5 + ws
        + temperature + rh, data=data_array)

# print the result of the multiple regression model in the monitor
summary(mlr)

# save the result of the multiple regression model in the "txt" file 
sink("./output/mlr_result.txt")
summary(mlr)
sink()  # returns output to the console

# save the data which is used in the multiple regression model in the "csv" file 
write.csv(data_array,file="./output/data_community_workshop_output.csv",row.names = FALSE)
