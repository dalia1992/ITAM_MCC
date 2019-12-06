# Toma datos de la entrada <key\tval> y los procesa
import sys

Acumulados = 0
distritoAnt = None
minDist=-1
maxDist=-1
maxEncuestas=0
minEncuestas=99999
for line in sys.stdin:
    DataIn = line.strip().split("\t")
    if len(DataIn) != 2:
        # Hay algo raro, ignora esta linea
        continue

    esteDistrito, esteValor  = DataIn

    if distritoAnt and distritoAnt != esteDistrito:
        print ("Distrito: ", distritoAnt, ": \t", Acumulados)
        if(Acumulados > maxEncuestas):
            maxDist=distritoAnt;
            maxEncuestas=Acumulados;
        if (Acumulados < minEncuestas):
            minDist=distritoAnt;
            minEncuestas=Acumulados;
        distritoAnt = esteDistrito;
        Acumulados = 0

    distritoAnt = esteDistrito
    Acumulados += 1

if distritoAnt != None:
        print ("Distrito: ", distritoAnt, ":\t", Acumulados)
        print("Distrito con mas encuestas: ", maxDist)
        print("Distrito con menos encuestas: ", minDist)

