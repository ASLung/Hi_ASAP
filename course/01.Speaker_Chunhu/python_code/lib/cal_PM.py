import time
import numpy as np
from lib.cal_factor_2s import cal_factor_2s
from lib.lib import *

def PM_factor_and_Cal_data2(aslung_id,PM, aslung_data, DataTime,CalFactor2):
    #print(CalFactor2)
    date=time.mktime(DataTime.timetuple())
    #print(CalFactor2)
    try:

        factor = CalFactor2.loc[
            (CalFactor2['aslung_id'] == aslung_id) & (CalFactor2['PM'] == PM ) & (CalFactor2['start_timestamp'] < date) & (CalFactor2['end_timestamp'] > date) ].reset_index(drop=True)
        #print(factor)
        if aslung_data < factor['break_point1'][0]:
            slope=factor['slope1'][0]
            intercept=factor['intercept1'][0]
        else:
            slope=factor['slope2'][0]
            intercept=factor['intercept2'][0]
        try:
            cal_data=aslung_data*slope+intercept
        except:
            cal_data=np.nan
        if cal_data < 0 :
            cal_data=np.nan
        else:
            pass
        return cal_data

    except Exception as e:
        print("Get Error........................")
        if not factor:
            print("There is no calibration factor at the sampling time of "+DataTime+" !")
        else:
            print(e)
