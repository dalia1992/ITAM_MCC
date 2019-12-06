# This code represents the devices that are constantly sending packets to the kernel
# The number of devices can be modified as well as the sending rate

#Import packages
import socket 
import time
import threading 
from threading import Lock
import argparse
import pandas as pd

# Argument parser
parser = argparse.ArgumentParser()
parser.add_argument('--fun', dest='function', default='constante')
parser.add_argument('--wait', dest='x', default=0.000001, type=float)
parser.add_argument('--lambda', dest='_lambda', default=5, type=int)
parser.add_argument('--mu', dest='mu', default=0, type=float)
parser.add_argument('--var', dest='var', default=0.0001, type=float)
parser.add_argument('--inc', dest='inc', default=0.000000001, type=float)
parser.add_argument('--dev', dest='devices', default=3, type=int)
parser.add_argument('--print', dest='print_b', default=False, type=bool)
parser.add_argument('--maxtime', dest='max_time', default=0.05 , type=float)
parser.add_argument('--lag', dest='lag', default=0.2 , type=float)
parser.add_argument('--eval_lat', dest='latency', default=True, type=bool)
parser.add_argument('--experiment', dest='experiment', default='prueba')
args = parser.parse_args()

# Lock is defined to achieve synchrony
lock=Lock()

# Extract variables from parser
experiment=args.experiment
Ndevices = args.devices
fun = args.function
lag =args.lag
latency=args.latency

# Some variables are defined as global, 
#since different threads will have access to them
global x
global var2
global print_b
print_b=args.print_b 
global max_time
max_time=args.max_time*60
global stime
if(latency):
    global thread_track
    thread_track=[None]*Ndevices
    for i in range(Ndevices):
        thread_track[i]=[]
       
# Define inputs for functions that define sending rates
if fun == 'constante':
    from tiempo import constante as fun_time
    x= args.x
    var2=0
elif fun=='escalonada':
    from tiempo import escalonada as fun_time
    x= args.x
    var2=time.time()
elif fun =='normal':
    from tiempo import f_normal as fun_time
    x=args.mu
    var2=args.var
elif fun=='poisson':
    from tiempo import f_poisson as fun_time
    x= args._lambda
    var2=0
elif fun=='picos':
    x= args.x
    inc= args.inc
    var2=x
    increase=False
    from tiempo import picos as fun_time
else:
    raise ValueError('Function name not defined: please use constante, escalonada, normal, poisson, or picos')

global packets_sent
packets_sent=0

# Define Host and port for UDP communication 
HOST='localhost'
PORT=5454
# Create a socket 
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# Create a class that defines threads that send packets 
class Connect2Server():
    data_count = threading.local() # Amount of packets sent by thread
    my_index   = threading.local() # Index of thread
    def run(self):
        global var2
        global fun
        global increase
        global print_b
        global stime
        global max_time
        global packets_sent
        self.data_count.val = 0
        self.my_index.val = index
        # Define socket for thread
        # Each thread sends to a different socket
        s1 = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)		
        while time.time()-stime<max_time:
            self.data_count.val += 1
            data = str(self.my_index.val)+':'+str(self.data_count.val)
            s1.sendto(data.encode(), (HOST, PORT-(self.my_index.val+1)))
            # Depending on the throughput function a waiting time is 
            # taken before sending next message
            if(latency):
                thread_track[self.my_index.val].append(time.time())
            if(print_b):
                print('sent:', data)
            if fun=='picos':
                var2, increase =fun_time(x, inc, var2, increase)
            else:
                var2=fun_time(x, var2)

        lock.acquire
        packets_sent+=self.data_count.val
        lock.release

# Begin loops
# Send to kernel number of devices
data = 'Number of devices:  '+str(Ndevices)
s.sendto(data.encode(), (HOST, PORT))
a_dev=Connect2Server()

# ThreadInstance is used to initiate the 
stime=time.time()
for index in range(Ndevices):
    ThreadInstance = threading.Thread(target=a_dev.run, daemon=True)
    ThreadInstance.start()

# The loop verifies whether it is time to stop, saves results and stops
while True:
    if (time.time()-stime>=max_time):
        data = 'Max time reached'
        time.sleep(lag)
        #print(data)
        s.sendto(data.encode(), (HOST, PORT))
        #print('Sent packages: ' + str(packets_sent))
        if(latency):     
            #Define pandas df for latency
            app=[]
            send_time=[]
            message=[]

            for i in range(Ndevices):
                app.extend([i]*len(thread_track[i]))
                send_time.extend(thread_track[i])
                message.extend(range(1,len(thread_track[i])+1))
            
            l=len(app)
            data={'experiment':[experiment]*l,'app':app,'send_time':send_time, 'message':message, 
            'nDevices':[Ndevices]*l, 'max_time':max_time, 'out_fun':[fun]*l, 'wait':[x]*l,
             'lambda':[args._lambda]*l,'mu':[args.mu]*l,'var':[args.var]*l, 'inc':[args.inc]*l}
            DF=pd.DataFrame.from_dict(data)
            if(print_b):
                print(DF.head(5))
                print(DF.tail(5))
            DF.to_csv('~/Dropbox/ITAM_MCC/Semestre_3/Operativos/proyecto/resultados/device_experiment_'+str(experiment)+'.csv')
        exit()




