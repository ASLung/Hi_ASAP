#!/usr/bin/env python
# coding: utf-8

from multiprocessing import freeze_support,cpu_count,Queue,Process
from lib.lib import *
import warnings
import datetime
from lib.cleanPM import *
from lib.SetNaN import *
from lib.cal_PM import PM_factor_and_Cal_data2
from lib.cal_factor_2s import *
from run import dataurls

cpu=cpu_count()
ml_num=cpu-4
freeze_support()
warnings.filterwarnings("ignore", category=RuntimeWarning)

import shutil
#pd.set_option("display.max_rows", None)
pd.set_option('display.max_columns', None)

#Error='ASLung_RawData_Error'
Cal='ASLung_Calibrated_Data'
Raw="ASLung_RawData"
Log='log'
#Finish='ASLung_RawData_BK'
CreateFolder(Cal)
CreateFolder(Log)
CreateFolder(Raw)
#CreateFolder(Error)
#CreateFolder(Finish)
CurrentPath=os.getcwd()
DataPath=os.path.join(CurrentPath, Raw)
calfactorurl=dataurls()
CalFactor2=cal_factor_2s(calfactorurl)
#print(CalFactor2)
tzone=GetTimeZone()
#print(tzone)

#print(CalFactor2)
CalFactor2['start_timestamp']=CalFactor2['Start_date'].apply(aslung_id_time, column='start')
CalFactor2['end_timestamp']=CalFactor2['End_date'].apply(aslung_id_time, column='end')
CSV_Files=FindSubFiles(DataPath)
cal_data = pd.DataFrame() #把所有資料合併成 DataFrame的資料集




def cal_job(q,csv_data,i):
    print("Cal Job",i," Start Time: ", datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    csv_data['cPM1'] = csv_data.apply(
        lambda row: PM_factor_and_Cal_data2(row['aslung_id'],'PM1', row['pm1_clean'], row['datatime(local)'],CalFactor2,
                                           ), axis=1)
    csv_data['cPM2.5'] = csv_data.apply(
        lambda row: PM_factor_and_Cal_data2(row['aslung_id'], 'PM2.5', row['pm25_clean'], row['datatime(local)'],CalFactor2,
                                           ), axis=1)
    print("Cal Job",i," End Time: ", datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    q.put(csv_data)
    #return csv_data

#Calculate AS-Lung data in the SD card
def cal_SD_data():
    # data_num = []
    data_error = []
    #print(CSV_Files)
    for datafile in CSV_Files:
        try:
            if (datafile[-3:] == 'csv'):
                nf=datafile.split("\\")
                f = [s for s in nf if "AL-" in s][0]
                fcsv= [s for s in nf if "csv" in s][0]                
                print("Calculate data file of : ",fcsv)
                
                CreateFolder(os.path.join(Cal, f))
                #read data file
                csv_data=pd.read_csv(datafile)
                #print(csv_data.head())
                data_date = csv_data['date'][1]
                csv_data['datatime'] = csv_data.apply(lambda row: StrtoDatatime(row['date'], row['time']), axis=1)
                log_interval=GetLogInterval(csv_data['datatime'])


                csv_data=csv_data.set_index('datatime')
                csv_data = csv_data.reset_index()
                aslung_id=f[f.find('AL-'):f.find('AL-')+7] #find aslung_id
                csv_data['aslung_id']=aslung_id

                if (f.find('AL-')-1)<0:
                    pass
                else:
                    lab_id=f[0:f.find('AL-')-1] #find lab_id or location_id in the field
                    csv_data['lab_id'] = lab_id
                    print("Lab ID: ", lab_id)

                csv_data=RemovePMGhosPeak(csv_data, PM1='pm1', PM25='pm25', PM10='pm10')
                csv_data['sht_t_ext'] = csv_data['sht_t_ext'].apply(SetNan)
                csv_data['sht_h_ext'] = csv_data['sht_h_ext'].apply(SetNan)
                csv_data['sht_t'] = csv_data['sht_t'].apply(SetNan)
                csv_data['sht_h'] = csv_data['sht_h'].apply(SetNan)
                csv_data['co2'] = csv_data['co2'].apply(SetNan)
                #print(csv_data.head())
                csv_data['cPM1'] = csv_data.apply(
                    lambda row: PM_factor_and_Cal_data2(row['aslung_id'], 'PM1', row['pm1_clean'], row['datatime'],CalFactor2),
                    axis=1)
                csv_data['cPM2.5'] = csv_data.apply(
                    lambda row: PM_factor_and_Cal_data2(row['aslung_id'], 'PM2.5', row['pm25_clean'], row['datatime'],CalFactor2),
                    axis=1)
                csv_data['cPM1'] = csv_data.apply(lambda row: PM1AsPM25(row['cPM1'], row['cPM2.5']), axis=1)
                csv_data['Hour']=csv_data.apply(lambda row: getHour(row['time']), axis=1)
                csv_data=CheckHourData(csv_data, 'time',log_interval)
                csv_data.to_csv(os.path.join(Cal, f) + "/cal_"+ fcsv,encoding='UTF-8',index=False)
            cal_data.append(csv_data)
        except Exception as e:
            df_err = [aslung_id, data_date, e]
            print("data error:", e)
            data_error.append(df_err)
    today=datetime.datetime.today().strftime("%Y%m%d")

    #data_num = pd.DataFrame(data_num, columns=['aslung_id', 'DataDate', 'data number'])
    data_error = pd.DataFrame(data_error, columns=['aslung_id', 'DataDate', 'Error Code'])

    if data_error.empty:
        pass
    else:
        print(data_error)
        data_error.to_csv('log/SD_data_error_log_'+today+'.csv',index=False)

#計算網頁下載的 AS-Lung數據
def cal_database_data():
    data_num = []
    data_error = []
    for datafile in CSV_Files:
        try:
            if (datafile[-3:] == 'csv'):
                nf=datafile.split("\\")
                fcsv= [s for s in nf if "csv" in s][0]
                f = [s for s in nf if "AL-" in s][0]
                print(f)
                CreateFolder(os.path.join(Cal, f))
                print(fcsv)
                #print("File Start Time: ", datetime.datetime.now())
                csv_data=pd.read_csv(datafile)
                csv_data['datatime(UTC+0)'] =pd.to_datetime(csv_data['datatime(UTC+0)'], format='%Y-%m-%d %H:%M:%S') #csv_data.apply(lambda row: StrtoDatatime(row['date'], row['time']), axis=1)
                log_interval=GetLogInterval(csv_data['datatime(UTC+0)'])
                print(log_interval)

                try:
                    csv_data=csv_data.drop(columns=['id','description','error','sht31','height','city_name','town_name','location_name'])
                except:
                    pass

                csv_data=RemovePMGhosPeak(csv_data, PM1='pm1', PM25='pm2.5', PM10='pm10')
                csv_data['temperature'] = csv_data['temperature'].apply(SetNan)
                csv_data['rh'] = csv_data['rh'].apply(SetNan)
                csv_data['co2'] = csv_data['co2'].apply(SetNan)
                csv_data['datatime(local)']=csv_data.apply(lambda row:row['datatime(UTC+0)']+datetime.timedelta(hours=tzone), axis=1)
                print("Split calibration job to ", ml_num, "parts!")
                num=int(round(len(csv_data)/(ml_num),0))
                q=Queue()

                names = locals()
                for i in range(1, ml_num+1):
                    if i == cpu-4:
                        names['p%s'%i]=Process(target=cal_job, args=(q, csv_data[num*(i-1):len(csv_data)],i))
                    else:
                        names['p%s' % i] = Process(target=cal_job, args=(q, csv_data[num * (i - 1):num * i],i))

                for i in range(1, ml_num+1):
                    names['p%s' % i].start()

                for i in range(1, ml_num+1):
                    names['p%s' % i].join(timeout=0.1)

                for i in range(1, ml_num+1):
                    names['csv_data_F%s' % i] = q.get()

                for i in range(1, ml_num):
                    if i==1:
                        csv_data = names['csv_data_F%s' % i].append(names['csv_data_F%s' % (i+1)])
                    else:
                        csv_data = csv_data.append(names['csv_data_F%s' % (i + 1)])

                csv_data['cPM1'] = csv_data.apply(lambda row: PM1AsPM25(row['cPM1'], row['cPM2.5']), axis=1)
                csv_data['Hour']=csv_data.apply(lambda row: getHour(row['datatime(local)']), axis=1)
                csv_data = CheckHourData(csv_data, 'datatime(local)',log_interval)
                csv_data_01min=csv_data.copy().set_index('datatime(local)').groupby(['fk-lab-id','aslung_id']).resample('1T').apply(np.mean)
                csv_data_01min=csv_data_01min.reset_index()
                csv_data_05min=csv_data_01min.copy().set_index('datatime(local)').groupby(['fk-lab-id','aslung_id']).resample('5T').apply(np.mean)
                csv_data_05min=csv_data_05min.reset_index()
                csv_data_60min=csv_data_01min.copy().set_index('datatime(local)').groupby(['fk-lab-id','aslung_id']).resample('1H').apply(np.mean)
                csv_data_60min=csv_data_60min.reset_index()
                csv_data_01min.to_csv(os.path.join(Cal, f)  + "/cal_01min" + fcsv, encoding='UTF-8',index=False)
                csv_data_05min.to_csv(os.path.join(Cal, f) + "/cal_05min" + fcsv, encoding='UTF-8', index=False)
                csv_data_60min.to_csv(os.path.join(Cal, f) + "/cal_60min" + fcsv, encoding='UTF-8', index=False)
                #shutil.move(f, os.path.join(FolderName_Finish,fcsv ))
                #shutil.move(f, os.path.join(CurrentPath,FolderName_Finish + "/" + fcsv))
            else:
                pass
        except Exception as e:
            print(e)
            try:
                df_err=[fcsv,e]
            except:
                pass
            data_error.append(df_err)
    today=datetime.datetime.today().strftime("%Y%m%d")
    data_error=pd.DataFrame(data_error,columns=['FileName', 'Error Message'])

    if data_error.empty:
        pass
    else:
        print(data_error)
        data_error.to_csv('log/data_error_log_'+today+'.csv',index=False)

if __name__ == "__main__":
    options = ["Calculate AS-Lung data from SD card", "Calculate AS-Lung data from database"]
    def let_user_pick(options):
        for idx, element in enumerate(options):
            print("{}) {}".format(idx + 1, element))
        iii = input("Please select your data source: ")
        try:
            if 0 < int(iii) <= len(options):
                return int(iii)
        except Exception as e:
            print(type(e), 'Data QA/QC error due to ' + str(e))
            pass
        return None

    iii = let_user_pick(options)
    print("===========================================================================================================")
    print("Data cleaning and calibrate AS-Lung data, Please wait!")
    print("Setp of data cleaning and calibration")
    print("1. Set raw data of PM as NaN when PM >50 and PM1=PM2.5=PM10 or PM <1 ")
    print("2. Set ghost Peak as NaN")
    print("3. Set raw data of temperature, humidity and CO2 as NaN when values are less than 1")
    print("4. Get calibration factor from google drive and calibrate AS-Lung data")
    print("5. If calibrated PM1 > PM2.5, PM1 value will be set as PM2.5")
    print("6. If the missing data is more than 1/3 in an hour, the python code will automatically remove all the data in the hour")
    print("===========================================================================================================")
    if iii == 1:
        print("Calculate AS-Lung data from SD card")
        print("Start Time: ", datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        cal_SD_data()
        print("End Time: ", datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
    elif iii == 2:
        print("Calculate AS-Lung data from database")
        print("Start Time: ", datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))
        print("Parent process is %s." % (os.getpid()))
        cal_database_data()
        print("End Time: ", datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"))

