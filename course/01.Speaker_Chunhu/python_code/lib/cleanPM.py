import numpy as np
from lib.lib import getHour
import time
from lib.cal_factor_2s import cal_factor_2s
#PM三個數值相同，且原始資料大於50；或原始資料<1 均以缺漏值處理
def SetPMNa(d1, d2,d3):
    if (d1==d3 and d2==d3 and d1==d3 and d1>50) or (d1 < 1):
        d1=np.nan
    else:
        pass
    return d1

def clean_pm25(row):
    _ret = np.nanmax([row['pm25_clean_forward'],row['pm25_clean_backward']])
    return _ret

def clean_pm1(row):
    _ret = np.nan
    if ~np.isnan(row['pm25_clean']):
        _ret = row['pm1']
    return _ret

def clean_pm10(row):
    _ret = np.nan
    if ~np.isnan(row['pm25_clean']):
        _ret = row['pm10']
    return _ret

def shift_in_row(database):
    database['pm25_d1'] = database['pm25_clean'].shift(1)
    database['pm25_d2'] = database['pm25_clean'].shift(2)
    database['pm25_d3'] = database['pm25_clean'].shift(3)
    database['pm25_d4'] = database['pm25_clean'].shift(4)
    database['pm25_d5'] = database['pm25_clean'].shift(5)
    return database

def ratio_in_row(row):
    _ret = np.nan
    ratio_front =  row['pm25_c'] / row['mean_front']
    if (ratio_front<10) :
        _ret = row['pm25_c']
    else:
        _ret = np.nan
    return _ret

# if PM sample size < 2/3 per hour, Set PM value to NULL
def SetNanHour(df_hour, time_col, log_interval, PM_data,PM='pm25'):
    hour=getHour(time_col)
    HourSample1=60*(60/int(log_interval))
    HourSample_df=df_hour.loc[df_hour['Hour']==hour].reset_index(drop=True)
    HourSample2=HourSample_df[PM][0]
    if (HourSample2/HourSample1) > (2/3):
        return PM_data
    else:
        return np.nan



def PM1AsPM25(cPM1, cPM25):
    if float(cPM1)==np.nan:
        pass
    elif float(cPM1)>float(cPM25):
        cPM1=cPM25
    return cPM1

def RemovePMGhosPeak(csv_data, PM1='pm1', PM25='pm25', PM10='pm10'):
    # print("刪除原始資料 >50 且 PM1=PM2.5=PM10 或是 PM <1 的異常值")
    # 刪除 >50 且 PM1=PM2.5=PM10的原始資料異常值
    csv_data['pm1_c'] = csv_data.apply(lambda row: SetPMNa(row[PM1], row[PM25], row[PM10]), axis=1)
    csv_data['pm25_c'] = csv_data.apply(lambda row: SetPMNa(row[PM25], row[PM10], row[PM1]), axis=1)
    csv_data['pm10_c'] = csv_data.apply(lambda row: SetPMNa(row[PM10], row[PM1], row[PM25]), axis=1)

    # 刪除剩下無法刪除之資料開始
    csv_data['pm25_clean'] = csv_data['pm25_c']
    csv_data_1 = csv_data.copy()
    for i in range(5):
        csv_data_1 = shift_in_row(csv_data_1)
        csv_data_1['mean_front'] = csv_data_1.loc[:,
                                   ['pm25_d1', 'pm25_d2', 'pm25_d3', 'pm25_d4', 'pm25_d5']].mean(axis=1)
        csv_data_1['pm25_clean'] = csv_data_1.apply(ratio_in_row, axis=1)
    try:
        csv_data_2 = csv_data.copy().sort_values(by=['fk-lab-id', 'aslung_id', 'datatime(UTC+0)'], ascending=False)  # 遞減排序
    except:
        csv_data_2 = csv_data.sort_index(ascending=False)
    for i in range(5):
        csv_data_2 = shift_in_row(csv_data_2)
        csv_data_2['mean_front'] = csv_data_2.loc[:,
                                   ['pm25_d1', 'pm25_d2', 'pm25_d3', 'pm25_d4', 'pm25_d5']].mean(axis=1)
        csv_data_2['pm25_clean'] = csv_data_2.apply(ratio_in_row, axis=1)
    try:
        csv_data_2 = csv_data_2.sort_values(by=['fk-lab-id', 'aslung_id', 'datatime(UTC+0)'], ascending=True)  # 遞增排序
    except:
        csv_data_2 = csv_data_2.sort_index(ascending=True)

    csv_data['pm25_clean_forward'] = csv_data_1['pm25_clean']
    csv_data['pm25_clean_backward'] = csv_data_2['pm25_clean']
    csv_data['pm25_clean'] = csv_data.apply(clean_pm25, axis=1)
    csv_data['pm1_clean'] = csv_data.apply(clean_pm1, axis=1)
    csv_data['pm10_clean'] = csv_data.apply(clean_pm10, axis=1)
    # 刪除剩下無法刪除之資料結束
    return csv_data

def CheckHourData(csv_data, time_col,log_interval):
    csv_data['Hour'] = csv_data.apply(lambda row: getHour(row[time_col]), axis=1)
    HourCount = csv_data[['Hour', 'cPM1', 'cPM2.5']]
    HourCount = HourCount.groupby(HourCount['Hour']).count().reset_index()
    csv_data['cPM1'] = csv_data.apply(
        lambda row: SetNanHour(HourCount, row[time_col], log_interval, row['cPM1'], PM='cPM1'), axis=1)
    csv_data['cPM2.5'] = csv_data.apply(
        lambda row: SetNanHour(HourCount, row[time_col], log_interval, row['cPM2.5'], PM='cPM2.5'), axis=1)
    csv_data = csv_data.drop(
        columns=['pm25_clean_backward', 'pm25_clean_forward', 'pm1_c', 'pm25_c', 'pm10_c', 'pm1_clean',
                 'pm25_clean', 'pm10_clean', 'Hour'])
    return csv_data

# if PM sample size < 2/3 per hour, Set PM value to NULL
def SetNanHour(df_hour, time_col, log_interval, PM_data,PM='pm25'):
    hour=getHour(time_col)
    HourSample1=60*(60/int(log_interval))
    HourSample_df=df_hour.loc[df_hour['Hour']==hour].reset_index(drop=True)
    HourSample2=HourSample_df[PM][0]
    if (HourSample2/HourSample1) > (2/3):
        return PM_data
    else:
        return np.nan

def PM1AsPM25(cPM1, cPM25):
    if float(cPM1)==np.nan:
        pass
    elif float(cPM1)>float(cPM25):
        cPM1=cPM25
    return cPM1