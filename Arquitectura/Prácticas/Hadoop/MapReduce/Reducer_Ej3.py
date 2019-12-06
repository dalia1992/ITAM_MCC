# Toma datos de la entrada <key\tval> y los procesa
import sys

Acumulados = 0
cand1_dist1232=0
cand5_dist9184=0
candidatoAnt = None
distritoAnt = None
for line in sys.stdin:
    DataIn = line.strip().split("\t")
    if len(DataIn) != 2:
        # Hay algo raro, ignora esta linea
        continue

    esteCandidato, esteDistrito  = DataIn

    if candidatoAnt and (candidatoAnt != esteCandidato) :
        print ("Candidato: ",candidatoAnt,":\t", Acumulados)
        if(candidatoAnt=="CAND1 Distrito: 1232" and distritoAnt=="1232"):
            cand1_dist1232=Acumulados;
        if(candidatoAnt=="CAND5 Distrito: 9184" and distritoAnt=="9184"):
            cand5_dist9184=Acumulados;
        candidatoAnt = esteCandidato;
        distritoAnt = esteDistrito;
        Acumulados = 0

    candidatoAnt = esteCandidato
    distritoAnt = esteDistrito
    Acumulados += 1

if candidatoAnt != None:
    print ("Candidato: ",candidatoAnt,":\t", Acumulados)
    print ("El candidato 1 tuvo", cand1_dist1232, "votos en el distrito 1232")
    print ("El candidato 5 tuvo", cand5_dist9184, "votos en el distrito 9184")

                   
