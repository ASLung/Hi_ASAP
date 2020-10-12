import pandas as pd
import numpy as np
from lib.lib import date_time_combine
from lib.segmented_regress_lib_AI import pm_pwlf_assess
import datetime as dt
import statsmodels.api as sm
import time

def ConvetDatetime(row):
    try:
        datatime=dt.datetime.strptime(row, "%m/%d/%Y %H:%M:%S")
    except:
        try:
            datatime = dt.datetime.strptime(row, "%Y/%m/%d %H:%M:%S")
        except:
            datatime = dt.datetime.strptime(row, "%Y-%m-%d %H:%M:%S")
    return datatime


def std_df(Standard_file_path):
    df=pd.read_excel(Standard_file_path, sheet_name="PM values", skiprows=0)
    #df['datatime'] = pd.to_datetime(df['datatime'], format="%m/%d/%Y %H:%M:%S")
    df['datatime'] =df['datatime'].apply(ConvetDatetime)
    start_time=df['datatime'][0]
    end_time=df['datatime'][len(df)-1]
    #Grimm 負值除錯
    try:
        df = df.loc[((df['std_PM1'] > 0))]
    except:
        pass
    try:
        df = df.loc[(df['std_PM2.5'] > 0)]
    except:
        pass
    try:
        df = df.loc[(df['std_PM10'] > 0)]
    except:
        pass
    df=df.loc[(df['datatime'] >= start_time ) & (df['datatime'] <= end_time)]
    df=df.set_index('datatime').resample("1T").apply(np.mean)
    return df, start_time, end_time

def ASLung_df(ASlung_file_path):
    AS_df = pd.DataFrame()
    #print(ASlung_file_path)
    for f in ASlung_file_path:
        #print(f)
        fcsv = f.split("\\")[-1:][0]

        if (fcsv.find("AL-"))<0:
            aslung_id = fcsv[fcsv.find("AL"):fcsv.find("AL") + 6][:2]+"-"+fcsv[fcsv.find("AL"):fcsv.find("AL") + 6][-4:]
        else:
            aslung_id = fcsv[fcsv.find("AL-"):fcsv.find("AL-") + 7]

        df=pd.read_csv(f,delimiter=',',error_bad_lines=False)
        #aslung 負值除錯
        df=df.loc[(df['pm1']>0) & (df['pm25']>0) &(df['pm10']>0)]
        #日期時間相加
        df['datatime']=df.apply(lambda row:date_time_combine(row['date'], row['time']), axis=1)
        #刪除不需要的資料
        df=df.drop(columns=['date','time',"adc","acc_x","acc_y","acc_z","accx_int","accy_int","accz_int","accx_i","accy_i","accz_i","gps_lat","gps_lon","gps_alt","gps_speed","gps_dir","gps_fix","ai1_2","ai1_3","ai1_4","ERR"])
        #寫入 aslung id
        df['aslung_id']=aslung_id
        #將 aslung資料平均成 1 分鐘一筆數據
        df=df.set_index('datatime').groupby(['id','aslung_id']).resample('1T').apply(np.mean)
        df=df.reset_index()
        AS_df=AS_df.append(df)
    AS_df=AS_df.set_index('datatime')
    return AS_df

def data_merge(std_df, AS_df,aslung="pm25",std="PM2.5"):
    if aslung =="pm125" and std =="PM125":
        pass
    else:
        std_df=std_df.reset_index()
        AS_df=AS_df.reset_index()
        stdPM = std_df[['datatime', 'std_%s'%std]].copy()
        ASLungPM = AS_df[['datatime','aslung_id', '%s'%aslung]].copy().rename(columns={'%s'%aslung:'aslung_%s'%aslung})
        data=pd.merge(left=ASLungPM, right=stdPM, how='left', on='datatime')
        data=data.dropna(how='any',subset=['std_%s'%std, 'aslung_%s'%aslung]) #針對這兩個欄位去除缺漏值
    return data

def cal_factor(std_df, AS_df,aslung_device, aslung="pm25",std="PM2.5", low=0, high=200):
    data = data_merge(std_df, AS_df, aslung, std)
    sm_df=pd.DataFrame()
    for asid in aslung_device:
        as_id='%s'%asid[:2]+"-"+'%s'%asid[-4:]
        as_id2=as_id
        print("as_id: ", as_id)
        if aslung=="pm125" and std=="PM125":
            pass
        else:
            as_id=data.loc[(data['aslung_id']==as_id) & (data['std_%s'%std]<=high) & (data['std_%s'%std]>=low)]
        as_id=as_id.reset_index()
        sm=pm_pwlf_assess(as_id, aslung, std)

        sm[0]['aslung_id']='%s'%asid[:2]+"-"+'%s'%asid[-4:]
        sm[0]['Golden_standard']='y_goldenstand'
        sm[0]["PM"] = std

        sm_df = sm_df.append(sm[0])
        sm_df=sm_df[['Golden_standard','aslung_id','slope1', 'intercept1', 'region1_mae', 'region1_rmse','break_point1',
                              'slope2', 'intercept2', 'region2_mae', 'region2_rmse',
                                'r2', 'total_mae', 'total_rmse','sample','PM']]
    return sm_df


def regress(df,aslung_PM='pm25', std_PM='PM2.5'):
    xdf=df['aslung_%s'%aslung_PM]
    ydf=df['std_%s'%std_PM]
    regress = sm.add_constant(xdf)
    regress_ml_r = sm.OLS(ydf.astype(float), regress.astype(float))
    regress_ml_r2 = regress_ml_r.fit()
    return regress_ml_r2


def SL_regress(std_df, AS_df,aslung_device, aslung="pm25",std="PM2.5", low=0, high=200):
    Starttime = time.time()
    data = data_merge(std_df, AS_df, aslung, std)
    sm_df=pd.DataFrame()

    for asid in aslung_device:
        as_id='%s'%asid[:2]+"-"+'%s'%asid[-4:]
        if aslung=="pm125" and std=="PM125":
            pass
        else:
            sm=data.loc[(data['aslung_id']==as_id) & (data['std_%s'%std]<=high) & (data['std_%s'%std]>=low)]
        sl_regress = regress(sm, aslung, std)
        col_name_rest = ['Golden_standard', 'aslung_id', 'slope1', 'intercept1', 'region1_mae', 'region1_rmse',
                         'break_point1',
                         'slope2', 'intercept2', 'region2_mae', 'region2_rmse',
                         'r2', 'total_mae', 'total_rmse', 'sample', 'PM']
        factor = [
            ['y_goldenstand', as_id, sl_regress.params['aslung_%s' % aslung], sl_regress.params['const'], '', '', ''
                , '', '', '', '', sl_regress.rsquared, '', '', sl_regress.nobs, std]]
        factor = pd.DataFrame(factor, columns=col_name_rest)
        sm_df=sm_df.append(factor)

    sm_df['break_point1']=10000
    print('need %10.5f minutes' % ((time.time() - Starttime) / 60))
    return sm_df
