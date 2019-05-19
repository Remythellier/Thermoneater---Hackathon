import time
import datetime

data = []

def empty_data():
    global data
    data = []
    return True

def get_data():
    global data
    if len(data) > 0:
        return data
    else:
        print('no data, try again...')
        return []
