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


def GetLogInterval(time_col):
    time1 = datetime.datetime.timestamp(time_col[len(time_col)-4])
    time2 = datetime.datetime.timestamp(time_col[len(time_col)-5])
    time3 = datetime.datetime.timestamp(time_col[len(time_col)-6])
    time4 = datetime.datetime.timestamp(time_col[len(time_col)-7])
    interval=(abs(time4-time3)+abs(time3-time2)+abs(time2-time1))/3
    if interval <30 and interval > 10:
        log_interval=15
    elif interval <180 and interval > 45:
        log_interval=60
    return log_interval
