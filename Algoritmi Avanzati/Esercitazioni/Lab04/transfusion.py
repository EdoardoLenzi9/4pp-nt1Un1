#!/usr/bin/env python2
# -*- coding: utf-8 -*-
#
# transfusion.py
#
# Esperimenti con la regressione logistica, discesa lungo il gradiente
#
# Richiede la presenza del file "transfusion.data" (dal repository UCI)
# nella stessa directory
#
# Esecuzione:
#    python2 transfusion.py
# oppure
#    chmod 755 transfusion.py   <--- una tantum
#    ./transfusion.py
#
# Attenzione: il codice serve esclusivamente a scopi didattici
# e non è adatto a un utilizzo "serio": mancano molti accorgimenti e ottimizzazioni
# che lo renderebbero molto più complesso e difficile da capire.

############################################
#
# Moduli

# Lettura del file CSV
import pandas

# Algebra delle matrici
import numpy as np

# Tracciamento di grafici
import matplotlib.pyplot as plt

############################################
#
# Parametri

# Frazione di dati da usare per l'addestramento del modello
# (il resto dervirà per la validazione)
training_fraction = .75

# Learning rate iniziale
eta = 1.0e-3

############################################
#
# Lettura dei dati

# Il file è già in formato CSV corretto, con una riga di intestazione,
# ma i dati sono interi, quindi dobbiamo specificare che
# li vogliamo in virgola mobile.
dataset = pandas.read_csv('transfusion.data', dtype=np.float64)

# Trasformiamo il dataset in una matrice Numpy
D = dataset.as_matrix()

# Mescoliamo le righe del dataset
np.random.shuffle(D)

# Ricaviamo il numero di righe per l'addestramento
m = len(D)
m_t = int(np.round(training_fraction * m))

# Le prime m_t righe del dataset rimescolato servono per l'addestramento (X_t, y_t)
D_t = D[:m_t]
X_t = D_t[:,:4]
y_t = D_t[:,4]

# Le righe rimanenti servono per la validazione (X_v, y_v)
D_v = D[m_t:]
X_v = D_v[:,:4]
y_v = D_v[:,4]

# Normalizziamo le colonne di input riscalandole rispetto al loro massimo
for i in range(4):
    # Il coefficiente di scala per una colonna è dato dal massimo
    # che la colonna assume nel sottoinsieme di addestramento
    s = np.max(X_t[:,i])
    # Le corrispondenti colonne dell'insieme di addestramento e di validazione vanno riscalate
    # rispetto allo stesso valore
    X_t[:,i] /= s
    X_v[:,i] /= s


############################################
#
# Funzioni

# La funzione sigmoide 1 / (1 + e^-t)
def sigmoid(t):
    return 1.0 / (1.0 + np.exp(-t))

# Data una matrice di input e un vettore di pesi,
# calcola il vettore delle previsioni del modello logit
def prediction(X, beta):
    return sigmoid(X.dot(beta))

# Dato il vettore degli output desiderati y, quello
# degli output previsti yp, la matrice di input e
# l'indice del peso k, calcola la derivata parziale rispetto a beta_k
# della soma degli scarti al quadrato
def partial_derivative(y, yp, X, k):
    return 2.0 * np.sum((yp - y) * yp * (1.0 - yp) * X[:,k])

# Costruisce il vettore delle derivate parziali
def gradient(y, yp, X):
    return np.array([partial_derivative(y, yp, X, k)
                        for k in range(4)])

# Dato il vettore degli output desiderati y e quello
# degli output previsti yp, restituisce l'RMSE.
def RMSE(y, yp):
    return np.sqrt(np.sum((y - yp)**2) / len(y))

############################################
#
# Discesa lungo il gradiente

# Inizializzazione dei pesi: beta può partire da valori casuali, oppure da zero.
#beta = np.zeros(4)
beta = np.random.random(4)

# Prima previsione yp_t e RMSE corrispondente error_t sull'insieme di addestramento
yp_t = prediction(X_t,beta)
error_t = RMSE(y_t, yp_t)

# Prima previsione yp_v e RMSE corrispondente error_v sull'insieme di validazione
yp_v = prediction(X_v, beta)
error_v = RMSE(y_v, yp_v)

# Manteniamo due liste che ci permetteranno di tracciare il progresso degli errori di
# addestramento e validazione mentre la discesa lungo il gradiente ha luogo.
training_errors = [error_t]
validation_errors = [error_v]


# Ripetizione del passo di discesa. Fissiamo un limite a 200 iterazioni per convenienza
for i in range(200):

    # Calcolo del gradiente
    grad = gradient(y_t, yp_t, X_t)

    # Ricerca di un passo eta adeguato: questo ciclo sposta le beta
    # attuali in direzione opposta al gradiente, e ripete l'operazione
    # dimezzando il passo se le cose peggiorano.
    while True:

        # Sposta il vettore dei pesi contro il gradiente
        beta1 = beta - eta * grad

        # Calcola la nuova previsione e il nuovo errore
        yp1 = prediction(X_t, beta1)
        error1 = RMSE(y_t, yp1)

        # Se il passo peggiora le cose, allora eta è troppo grande: dimezzare e riprovare
        if error1 >= error_t:
            eta /= 2
            # Se però eta è diventato troppo piccolo, allora smettiamo di provarci:
            if eta < 1.0e-20:
                break

        # Altrimenti, eta è adeguato
        else:
            # Aumentare leggermente eta per la prossima iterazione
            eta *= 1.1
            # Aggiornare i valori di beta, yp ed error_t
            error_t = error1
            beta = beta1
            yp_t = yp1
            # Uscire dal ciclo interno e passare all'iterazione successiva
            break

    # Se eta è diventato troppo piccolo, terminiamo prematuramente anche il ciclo esterno
    if eta < 1.0e-20:
        break

    # Calcoliamo anche la previsione e l'errore per l'insieme di validazione
    # con le nuove beta
    yp_v = prediction(X_v, beta)
    error_v = RMSE(y_v, yp_v)

    # Stampiamo l'errore corrente
    print (error_t, error_v)

    # Aggiungiamo i due errori alle rispettive liste per il diagramma a fine ciclo.
    training_errors.append(error_t)
    validation_errors.append(error_v)

############################################
#
# Disegno del diagramma

# Curva dell'RMSE sui dati di addestramento
plt.plot(training_errors, label='Training')

# Curva dell'RMSE sui dati di validazione
plt.plot(validation_errors, label='Validation')

# Aggiungiamo una legenda, una griglia e le etichette degli assi
plt.legend()
plt.grid()
plt.xlabel('Training iteration')
plt.ylabel('RMSE')

# Visualizziamo il grafico.
plt.show()
