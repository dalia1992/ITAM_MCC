# Toma datos de la entrada <key\tval> y los procesa
import sys
numDistritos = 0
distritoAnt = None

for line in sys.stdin:
    DataIn = line.strip().split("\t")
    if len(DataIn) != 2:
        # Hay algo raro, ignora esta linea
        continue

    esteDistrito, esteValor  = DataIn

    if distritoAnt and distritoAnt != esteDistrito:
        distritoAnt = esteDistrito;
        numDistritos += 1

    distritoAnt = esteDistrito
numDistritos +=1
print ("Numero de Distritos: \t", numDistritos)


