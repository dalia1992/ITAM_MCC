import socket
import threading
import argparse
import time
import pandas as pd
from threading import Lock
lock=Lock()

# Parse arguments
parser = argparse.ArgumentParser()
parser.add_argument('--PORT', dest='PORT', default=5555, type=int)
parser.add_argument('--print', dest='print_b', default=False, type=bool)
parser.add_argument('--lag', dest='lag', default=0.2, type=float)
parser.add_argument('--eval_lat', dest='latency', default=True, type=bool)
parser.add_argument('--experiment', dest='experiment', default='prueba')
args = parser.parse_args()

print_b=args.print_b
lag=args.lag
HOST='localhost'
PORT=args.PORT
latency=args.latency
experiment=args.experiment

# Define socket
s=socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.bind((HOST, PORT))

#Metrics and global variables
global stop
stop=False
global packets_received
packets_received=0

aux=True
while aux==True:
    message=(s.recv(30))
    message=message.decode('utf-8')
    # Define number of devices
    if (message[:6]=='Number'):
        nDevices=int(message.split(":  ")[1])
        if(print_b):
            print('Number of Apps: '+ str(nDevices))
        aux=False

#Define structure for time of arrival of packets
if(latency):
    global thread_track
    thread_track=[None]*nDevices
    for i in range(nDevices):
        thread_track[i]=[None]*2
        for j in range(2):
            thread_track[i][j]=[]

# Define list that will contain the different input sockets
si=[None]*nDevices
# Define input sockets
for i in range(nDevices):
    si[i]=socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    si[i].bind((HOST, PORT+(i+1)))

class ReceiveFromKernel():
    my_index   = threading.local()
    def run(self):
        global stop
        global thread_track
        global packets_received
        self.my_index.val = index
        while (stop==False): 
            message=(si[self.my_index.val].recv(30))
            message=message.decode('utf-8')
            lock.acquire()
            packets_received+=1
            lock.release()
            if(latency):
                thread_track[self.my_index.val][0].append(time.time())
                thread_track[self.my_index.val][1].append(message)
            if(print_b):
                print('App '+str(self.my_index.val) + ' received message '+ message.decode('utf-8'))


class stop_inst():
    def run(self):
        global stop
        aux=True
        while aux==True:
            message=None
            try: 
                message=(s.recv(30))
                message=message.decode('utf-8')
                if (message=='Max time reached'):
                    aux=False
                    lock.acquire()
                    stop=True
                    lock.release()
                    if(print_b):
                        print(str(message))
            except:
                0

a= ReceiveFromKernel()
c=stop_inst()

for index in range(nDevices):
    ThreadInstance = threading.Thread(target=a.run, daemon=True)
    ThreadInstance.start()

for j in range(1):
    t_stop=threading.Thread(target=c.run, daemon=True)
    t_stop.start()


while True:
    if (stop):
        time.sleep(lag)
        if(print_b):
            print('Apps max time reached!')
            print('Packets received: '+str(packets_received))
        if(latency):     
            #Define pandas df for latency
            app=[]
            arrival_time=[]
            message=[]

            for i in range(nDevices):
                app.extend([i]*len(thread_track[i][0]))
                arrival_time.extend(thread_track[i][0])
                message.extend(thread_track[i][1])
            data={'experiment':[experiment]*len(app),'app':app,'arr_time':arrival_time, 'message':message, 'nDevices':[nDevices]*len(app)}
            DF=pd.DataFrame.from_dict(data)
            DF.to_csv('~/Dropbox/ITAM_MCC/Semestre_3/Operativos/proyecto/resultados/apps_experiment_'+str(experiment)+'.csv')
        if(print_b):
            print(DF.head(5))
            print(DF.tail(5))
        exit()
  
