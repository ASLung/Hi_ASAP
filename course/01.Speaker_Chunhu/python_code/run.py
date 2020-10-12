import os
import warnings
warnings.filterwarnings("ignore", category=RuntimeWarning)
def dataurls():
    calfactorurl = "https://script.google.com/macros/s/AKfycbwfhUbpNqk5AE4HpUg0Dp-0pT1oMKa1mxLzWWAXb3dlnhTYRN8/exec"
    return calfactorurl

if __name__ == "__main__":
    options = ["ASLung calibration factor from reference instrument", "Data cleaning and calibrate ASLung raw data"]
    def let_user_pick(options):
        print("Please choose:")
        for idx, element in enumerate(options):
            print("{}) {}".format(idx + 1, element))
        iii = input("Please select which you want to do: ")
        return int(iii)

    iii = let_user_pick(options)

    if iii == 1:
        os.system('python ASLungCalFractor_2Segment_Regesssion_AI.py')
    elif iii == 2:
        os.system('python AS_LungQAQC_0908_2S.py')
        print("===========================================================================================================")
        print("If there is any error, the log message will save in the folder of log.")
        print("Then check the dataset format.")
        print("===========================================================================================================")


