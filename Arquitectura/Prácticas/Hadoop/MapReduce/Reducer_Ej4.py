# Toma datos de la entrada <key\tval> y los procesa

import sys

AcumuladosH = 0
AcumuladosM = 0
KeyAnt = None
generoAnt = None
minHombres = 999999
DistminH   = -1
for line in sys.stdin:
    DataIn = line.strip().split("\t")
    if len(DataIn) != 2:
        # Hay algo raro, ignora esta linea
        continue

    esteKey, esteGenero  = DataIn

    if KeyAnt and KeyAnt != esteKey:
        print (KeyAnt, "Hombres \t", AcumuladosH)
        print (KeyAnt, "Mujeres \t", AcumuladosM)
        if (AcumuladosH<minHombres):
            minHombres=AcumuladosH;
            DistminH=KeyAnt;
        KeyAnt = esteKey;
        generoAnt=esteGenero;
        AcumuladosH = 0
        AcumuladosM = 0
    KeyAnt = esteKey
    generoAnt = esteGenero
    if esteGenero=="H":
        AcumuladosH +=1
    else:
        AcumuladosM += 1

if KeyAnt != None:
    if (AcumuladosH<minHombres):
        minHombres=AcumuladosH;
        DistminH=KeyAnt;
    print (KeyAnt, "Hombres \t", AcumuladosH)
    print (KeyAnt, "Mujeres \t", AcumuladosM)
    print("El distrito y candidato con menor preferencia de los hombres fue ", DistminH, "con ", minHombres, " votos." )
                                                                                                                          
