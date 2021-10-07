#!/usr/bin/env python
# coding: utf-8

import os
import glob
import pandas as pd
from lib.df import std_df, ASLung_df,cal_factor,SL_regress
import datetime as dt
import warnings
from lib.lib import CreateFolder
warnings.filterwarnings("ignore", category=RuntimeWarning)

pd.set_option('display.max_columns', None)
current_path=os.getcwd()
Data_Raw='ASLung_Calibration_Factor_RawData'
Data_factor='ASLung_Calibration_Factor'
CreateFolder(Data_factor)
CreateFolder(Data_Raw)
file_path=os.path.join(current_path,Data_Raw)
Standard_file_path = sorted(glob.glob(os.path.join(current_path, Data_Raw,'*standard*')), reverse=False)
ASlung_file_path = sorted(glob.glob(os.path.join(current_path, Data_Raw,'*_AL*')), reverse=False)

if __name__ == '__main__':
    options = ["Simple linear regrssion", "Two segments regression"]
    def let_user_pick(options):
        for idx, element in enumerate(options):
            print("{}) {}".format(idx + 1, element))
        iii = input("Please select regression model: ")
        return int(iii)
    iii = let_user_pick(options)
    low = 1
    high = int(input("Maximum concentration of standard PM: "))
    regression_model = iii
    #Read AS-Lung ID
    aslung_device = []
    for f in ASlung_file_path:
        fcsv=f.split("\\")[-1:][0]
        if f.find("AL-") < 0:
            asid = "AL-" + f[f.find("_AL") + 3:f.find("_AL") + 7]
        else:
            asid = "AL-" + f[f.find("AL-") + 3:f.find("AL") + 7]
        aslung_device.append(asid)
    aslung_device = set(aslung_device)
    aslung_device = [s for s in sorted(aslung_device)]
    print("AS-Lung ID : ")
    print(*aslung_device, sep=",")

    #Set data as DataFrane
    try:
        std_df_list = std_df(Standard_file_path[0])
    except Exception as e:
        print(e)
        print("Please check reference PM, there is no reference PM data in the folder of 'ASLung_Calibration_Factor_RawData'")
        print("Or please check file name of the reference PM, it should be contain the key word of 'standard'")
    std_max = std_df_list[0].copy().reset_index()[['datatime','std_PM2.5']]
    std_max_PM25 = std_max.max()['std_PM2.5']
    std_max_time = std_max.loc[(std_max['std_PM2.5'] == std_max_PM25)].reset_index()['datatime'][0]
    if regression_model == 1:
        std_df = std_df_list[0].loc[std_df_list[0].index > std_max_time]
    elif regression_model == 2:
        std_max_time2 = std_max_time+dt.timedelta(minutes=30)
        std_df = std_df_list[0].loc[std_df_list[0].index > std_max_time2]
    else:
        print("Please select regression model, 1 or 2 , not others")
    std_df.drop(std_df.tail(10).index, inplace=True)
    start_time = std_df_list[1]
    end_time = std_df_list[2]
    AS_df = ASLung_df(ASlung_file_path)

    pm_factor = pd.DataFrame()
    if regression_model == 1:
        fname = "SimpleLinearRegressFactor"
        for col in std_df.columns:
            if col == 'std_PM1':
                pm1_factor=SL_regress(std_df, AS_df, aslung_device, aslung="pm1", std="PM1", low=low, high=high)
                pm_factor=pm_factor.append(pm1_factor)
            if col == 'std_PM2.5':
                pm25_factor = SL_regress(std_df, AS_df, aslung_device, aslung="pm25", std="PM2.5", low=low, high=high)
                pm_factor = pm_factor.append(pm25_factor)
    elif regression_model == 2:
        fname = "2SegmentRegressFactor"
        for col in std_df.columns:
            if col == 'std_PM1':
                pm1_factor = cal_factor(std_df, AS_df, aslung_device, aslung="pm1", std="PM1", low=low, high=high)
                pm_factor=pm_factor.append(pm1_factor)
            if col == 'std_PM2.5':
                pm25_factor = cal_factor(std_df, AS_df, aslung_device, aslung="pm25", std="PM2.5", low=low, high=high)
                pm_factor = pm_factor.append(pm25_factor)

    pm_factor['high_conc']=high
    pm_factor['low_conc'] = low
    pm_factor['Start_date'] = dt.datetime(end_time.year, end_time.month, end_time.day)
    pm_factor['End_date'] = ''

    tdate = dt.datetime.now().__format__("%Y%m%d%H%M")
    pm_factor.to_csv(os.path.join(current_path, Data_factor)+"/"+fname+"_"+tdate+".csv", encoding="UTF-8", index=False)
