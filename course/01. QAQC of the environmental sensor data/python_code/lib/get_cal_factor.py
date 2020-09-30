import urllib.request, json#,mysql.connector
import pandas as pd
from time import gmtime, strftime
import datetime
from run import dataurls
pd.set_option("display.max_rows", None)
pd.set_option('display.max_columns', None)

def ConVertZone(row):
    add=strftime("%z", gmtime())[0:1]
    tzone =int( strftime("%z", gmtime())[1:3])
    if(add=="+"):
        pass
    else:
        tzone=-tzone
    print(tzone)
    try:
        try:
            row=datetime.datetime.strptime(row, "%Y-%m-%dT%H:%M:%S.000Z")
        except:
            try:
                row = datetime.datetime.strptime(row, "%Y-%m-%d %H:%M:%S")
            except:
                row = datetime.datetime.strptime(row, "%Y/%m/%d %H:%M:%S")
        row=row+datetime.timedelta(hours=tzone)
        row=datetime.datetime.strftime(row,"%Y-%m-%d %H:%M:%S")[0:10]
        print(row)
    except:
        pass
    return row

def cal_factor_2s(dataurl):
    json_data=urllib.request.urlopen(dataurl).read().decode("utf-8")
    data=json.loads(json_data)
    col_name=[]
    for value in data['ASLUNG'][0]:
        col_name.append(value)
    row_data=[]
    for i in range(1, len(data['ASLUNG'])):
        if data['ASLUNG'][i] == "":
            pass
        else:
            Golden_standard = data['ASLUNG'][i]['Golden_standard']
            aslung_id = data['ASLUNG'][i]['aslung_id']
            slope1 = data['ASLUNG'][i]['slope1']
            intercept1 = data['ASLUNG'][i]['intercept1']
            region1_mae = data['ASLUNG'][i]['region1_mae']
            region1_rmse = data['ASLUNG'][i]['region1_rmse']
            break_point1 = data['ASLUNG'][i]['break_point1']
            slope2 = data['ASLUNG'][i]['slope2']
            intercept2 = data['ASLUNG'][i]['intercept2']
            region2_mae = data['ASLUNG'][i]['region2_mae']
            region2_rmse = data['ASLUNG'][i]['region2_rmse']
            r2 = data['ASLUNG'][i]['r2']
            total_mae = data['ASLUNG'][i]['total_mae']
            total_mse = data['ASLUNG'][i]['total_mse']
            sample = data['ASLUNG'][i]['sample']
            PM = data['ASLUNG'][i]['PM']
            high_conc = data['ASLUNG'][i]['high_conc']
            low_conc = data['ASLUNG'][i]['low_conc']
            Start_date = data['ASLUNG'][i]['Start_date']
            End_date = data['ASLUNG'][i]['End_date']
            add_data=[Golden_standard,aslung_id,
                      slope1, intercept1, region1_mae, region1_rmse, break_point1,
                      slope2, intercept2, region2_mae, region2_rmse,
                      r2, total_mae, total_mse, sample, PM, high_conc, low_conc, Start_date, End_date]
            row_data.append(add_data)
    row_df = pd.DataFrame(row_data,
                          columns=col_name)
    row_df['Start_date']=row_df['Start_date'].apply(ConVertZone)
    row_df['End_date'] = row_df['End_date'].apply(ConVertZone)
    return row_df







#calfactorurl = "https://script.google.com/macros/s/AKfycbwfhUbpNqk5AE4HpUg0Dp-0pT1oMKa1mxLzWWAXb3dlnhTYRN8/exec"



#print(strftime("%z", gmtime()), tzname, gmtime())


#print(cal_factor_2s(dataurls()))
#from dateutil.tz import tzlocal
#print(datetime.datetime.now(tzlocal()))

#from tzlocal import get_localzone
#print(get_localzone())