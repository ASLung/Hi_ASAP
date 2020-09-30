import numpy as np


def SetNan(row):
    data=row
    if data < 0:
        return np.nan
    else:
        return data


def SetPMNa(d1, d2,d3):
    if (d1==d3 and d2==d3 and d1==d3 and d1>50) or (d1 < 1):
        d1=np.nan
    else:
        pass
    return d1


#刪除ghost peak
def check(d1,d2):
    if (float(d2) > 10):
        return np.nan
    else:
        return d1