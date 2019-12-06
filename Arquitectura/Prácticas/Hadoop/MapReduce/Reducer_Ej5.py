# Toma datos de la entrada <key\tval> y los procesa

import sys

Acumulados = 0
horaAnt = None

for line in sys.stdin:
    DataIn = line.strip().split("\t")
    if len(DataIn) != 2:
        # Hay algo raro, ignora esta linea
        continue

    estaHora, esteValor  = DataIn

    if horaAnt and horaAnt != estaHora:
        print (horaAnt, "\t", Acumulados)
        horaAnt = estaHora;
        Acumulados = 0

    horaAnt = estaHora
    Acumulados += 1

if horaAnt != None:
    print (horaAnt, "\t", Acumulados)

