import machine
import pycom
import time
from network import WLAN
import urequests



# Configure second UART bus on pins P3(TX1) and P4(RX1)
uart1 = machine.UART(1, baudrate=9600)
uart1.init(baudrate=9600, bits=8, parity=None, stop=2)

machine.main('main.py')
print('==========SETUP==========\n')

wlan = WLAN(mode=WLAN.STA)

url = "http://0.0.0.0:5000/collect/"

nets = wlan.scan()
for net in nets:
    if net.ssid == 'ChristineLagarde':
        print('Network found!')
        wlan.connect(net.ssid, auth=(net.sec, 'pardonmyfrench'), timeout=5000)
        while not wlan.isconnected():
            machine.idle() # save power while waiting
        print('WLAN connection succeeded!')
        break

data = []

def http_post():
    global url
    global data
    data_string = str(data)
    #urequests.request("POST", url, data_string)

def post_and_clear():
    http_post()
    data = []

def collect_data():
    line = uart1.readline()
    add_new_line_to_data(line)

def is_line_in_data(line):
    global data
    if line in data:
        print('Chip already scanned!')
        return False
    else:
        return True

def add_new_line_to_data(line):
    global data
    if is_line_in_data(line):
        data.append(line)
        return True
    else:
        return False

print('==========STARTED==========\n')

while True:
    print(collect_data())
    time.sleep(5)
    print(collect_data())
    time.sleep(5)
    post_and_clear()
