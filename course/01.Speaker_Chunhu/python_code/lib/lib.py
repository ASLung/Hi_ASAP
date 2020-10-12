import datetime
import os
import pandas as pd
import time
from time import gmtime, strftime

#combine date and time
def time_combine(d1,d2):
    return d1+datetime.timedelta(d2)

def date_time_combine(d1,d2):
    try:
        date_timestamp=datetime.datetime.strptime(d1,"%Y-%m-%d")
    except:
        date_timestamp = datetime.datetime.strptime(d1, "%Y/%m/%d")
    time_timestamp = datetime.datetime.strptime(d2, "%H:%M:%S")
    return date_timestamp+datetime.timedelta(hours=time_timestamp.hour, minutes=time_timestamp.minute,seconds=time_timestamp.second)


# Read file name
def FindSubFiles(dirName):
    # create a list of file and sub directories
    # names in the given directory
    listOfFile = os.listdir(dirName)
    allFiles = list()
    # Iterate over all the entries
    for entry in listOfFile:
        # Create full path
        fullPath = os.path.join(dirName, entry)
        # If entry is a directory then get the list of files in this directory
        if os.path.isdir(fullPath):
            allFiles = allFiles + FindSubFiles(fullPath)
        else:
            allFiles.append(fullPath)
    return allFiles

# check 校正參數日期
def aslung_id_time(row, column='end'):
    if pd.isnull(row) or row=='':
        data_time = time.mktime(datetime.datetime.now().date().timetuple())
    else:
        try:
            row = datetime.datetime.strptime(row, '%Y-%m-%d')
        except:
            row = datetime.datetime.strptime(row, '%Y/%m/%d')
        if column == 'start':
            if row.year == 2017:  # 2017年AS-LUNG先觀測再校正
                data_time = time.mktime(datetime.datetime(2017, 1, 1).timetuple())
            else:
                data_time = time.mktime(row.timetuple())
        else:
            data_time = time.mktime(row.timetuple())
    return data_time
    #return datetime.datetime.strftime(datetime.datetime.fromtimestamp(data_time), "%Y-%m-%d")


def StrtoDate(row):
    try:
        row=datetime.datetime.strptime(row,  "%Y-%m-%d")
    except:
        row=datetime.datetime.strptime(row,  "%Y/%m/%d")
    return time.mktime(row.timetuple())

def StrtoTime(row):
    row=datetime.datetime.strptime(row,  "%H:%M:%S")
    return row

def StrtoDatatime(d1,d2):
    try:
        date_timestamp=datetime.datetime.strptime(d1,"%Y-%m-%d")
    except:
        date_timestamp = datetime.datetime.strptime(d1, "%Y/%m/%d")
    time_timestamp = datetime.datetime.strptime(d2, "%H:%M:%S")
    return date_timestamp+datetime.timedelta(hours=time_timestamp.hour, minutes=time_timestamp.minute,seconds=time_timestamp.second)

def CreateFolder(FolderName):
    try:
        os.mkdir(FolderName)
    except:
        pass


def getHour(row):
    try:
        row=datetime.datetime.strptime(row, "%H:%M:%S")
        return row.hour
    except:
        return datetime.datetime.strftime(row,"%Y-%m-%d %H:00")


def GetTimeZone():
    #print(strftime("%z", gmtime())[0:1])
    add=strftime("%z", gmtime())[0:1]
    tzone =int( strftime("%z", gmtime())[1:3])
    if(add=="+"):
        pass
    else:
        tzone=-tzone
    return tzone


def interval2(row1, row2):
    log_int=datetime.datetime.timestamp(row1)-datetime.datetime.timestamp(row2)
    return log_int


def ConToTimestamp(row):
    return datetime.datetime.timestamp(row)


def GetLogInterval(time_col):
    tt=pd.DataFrame(time_col)
    tt['t1']=tt['datatime'].apply(ConToTimestamp)
    tt['t2']=tt['t1'].shift(1)
    tt['interval']=tt['t1']-tt['t2']
    log15 = tt.loc[(tt['interval'] > 0) & (tt['interval'] < 20)]
    log30 = tt.loc[(tt['interval'] > 20) & (tt['interval'] < 40)]
    log60 = tt.loc[(tt['interval'] > 50) & (tt['interval'] < 70)]
    log500 = tt.loc[(tt['interval'] > 450) & (tt['interval'] < 550)]
    if ((len(log15) > len (log30)) & (len(log15) > len (log60)) & (len(log15) > len (log500))):
        log_interval=15
    elif ((len(log30) > len (log15)) & (len(log30) > len (log60)) & (len(log30) > len (log500))):
        log_interval = 30
    elif ((len(log60) > len (log15)) & (len(log60) > len (log30)) & (len(log60) > len (log500))):
        log_interval = 60
    elif ((len(log500) > len (log15)) & (len(log500) > len (log30)) & (len(log500) > len (log60))):
        log_interval = 500
    return log_interval
