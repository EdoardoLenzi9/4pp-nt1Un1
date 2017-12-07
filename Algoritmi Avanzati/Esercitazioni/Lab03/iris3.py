#!/usr/bin/env python2
# -*- coding: utf-8 -*-
#
# iris2.py
#
# Esperimenti con la regressione polinomiale
# e la suddivisione del dataset in due insiemi per
# l'addestramento e la validazione
#
# Richiede la presenza del file "iris.data" (dal repository UCI)
# e del file ml.py nella stessa directory.
#
# Esecuzione:
#    python2 iris3.py d
# oppure
#    chmod 755 iris3.py d   <--- una tantum
#    ./iris.py
# dove d è il grado del polinomio di regressione.
#
# Attenzione: il codice serve esclusivamente a scopi didattici
# e non è adatto a un utilizzo "serio": mancano molti accorgimenti e ottimizzazioni
# che lo renderebbero molto più complesso e difficile da capire.

############################################
#
# Moduli

import pandas
import matplotlib.pyplot as plt
import ml

# Iniziamo a utilizzare alcune funzioni di numpy
import numpy as np

# Funzioni e oggetti di sistema (usato per leggere glli argomenti dalla riga di comando)
import sys

#############################################
#
# Lettura dei parametri dalla riga di comando

# Grado del polinomio di regressione
d = int(sys.argv[1])

#############################################
#
# Lettura del file iris.data

names = [
	'Sepal width (cm)',
	'Sepal length (cm)',
	'Petal width (cm)',
	'Petal length (cm)',
	'Class'
]
iris = pandas.read_csv(
	'iris.data', 
	names=names
)

# A differenza delle altre volte, rimescoliamo le righe della matrice
# (metodo "sample") e trasformiamo subito
# il dataframe Pandas in una matrice Numpy.
D = iris.sample(frac=1,random_state=2).iloc[:,0:4].as_matrix()

#############################################
#
# Divisione del dataset

# Numero di campioni (righe)
m = len(D)

# I campioni da usare per l'addestramento del modello
m_train = int(2 * m / 3)

# Estrazione del dataset di addestramento (X: primi m_train elementi della colonna 2)
X_train = D[:m_train,2:3]
y_train = D[:m_train,3]

# La parte rimanente del dataset serve per la validazione
X_test = D[m_train:,2:3]
y_test = D[m_train:,3]

#############################################
#
# Creazione e addestramento del modello di grado d
lsq = ml.LSQ1d_poly(d)
lsq.fit(X_train, y_train)

#############################################
#
# Calcolo e stampa dei due RMSE (sui dati di addestramento e di validazione)

RMSE_train = np.sqrt(sum(
		(yi-lsq.predict(xi))**2
		for xi,yi in zip(X_train,y_train)) / m_train)
RMSE_test = np.sqrt(sum(
		(yi-lsq.predict(xi))**2
		for xi,yi in zip(X_test,y_test)) / (m - m_train))
print RMSE_train, RMSE_test

#############################################
#
# Tracciamento del grafico dei punti di addestramento e di validazione
# e della polinomiale

# Punti di addestramento
plt.plot(X_train,y_train,'.',label='Training set')

# Punti di validazione
plt.plot(X_test,y_test,'.',label='Test set')

# La polinomiale è tracciata per punti (100)
x_max = max(max(X_test),max(X_train))
x_plot = [x_max / 100 * i for i in range(101)]
y_plot = [lsq.predict(x) for x in x_plot]
plt.plot(x_plot, y_plot, label='Polyfit')

# Etichette degli assi, griglia, legenda
plt.xlabel(names[2])
plt.ylabel(names[3])
plt.grid()
plt.legend()

plt.show()
