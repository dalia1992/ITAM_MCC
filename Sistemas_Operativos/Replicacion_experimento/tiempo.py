#Funciones de tasas de tiempo
import time
from scipy.stats import poisson
from numpy.random import normal

def constante(x=5, init_time=0):
    time.sleep(x)
    return(init_time)

def escalonada(x=5, init_time=0):
    if (time.time()-init_time>x):
        time.sleep(x)
        init_time = time.time()
    return (init_time)

def f_poisson(x=5, init_time=0):
    time.sleep(poisson.rvs(x)/100000)
    return(init_time)

def f_normal(mu=0, var=1):
    time.sleep(abs(normal(mu, var)))
    return (var)

def picos(x=5, inc=0.05, wait_time=5, increase=True):
    time.sleep(wait_time)
    if (increase):
        if (wait_time<x-inc):
            wait_time+=inc
        else:
            increase=False
            wait_time-=inc
    elif (wait_time-inc>=0):
        wait_time-=inc
    else:
        increase=True
        wait_time+=inc
    return (wait_time, increase)




