#!/usr/bin/env python2
# -*- coding: utf-8 -*-
#
# iris2.py
#
# Utilizzo di alcuni algoritmi di machine learning
# definiti nella libreria "ml" definita in ml.py
#
# Richiede la presenza del file "iris.data" (dal repository UCI)
# e del file ml.py nella stessa directory.
#
# Esecuzione:
#    python2 iris2.py
# oppure
#    chmod 755 iris2.py   <--- una tantum
#    ./iris.py
#
# Attenzione: il codice serve esclusivamente a scopi didattici
# e non è adatto a un utilizzo "serio": mancano molti accorgimenti e ottimizzazioni
# che lo renderebbero molto più complesso e difficile da capire.

############################################
#
# Moduli

import pandas
import matplotlib.pyplot as plt

# Questa è la libreria definita in ml.py
import ml

#############################################
#
# Lettura del file iris.data
iris = pandas.read_csv(
	'iris.data', 
	names=[
		'Sepal width',
		'Sepal length',
		'Petal width',
		'Petal length',
		'Class'
	]
)
X = iris.iloc[:,0:4]
y = iris.iloc[:,4]

##############################################
#
# Utilizzo dell'algoritmo KNN implementato in ml.py

# Costruzione dell'oggetto. Il parametro è il valore di K (numero di vicini da considerare)
knn = ml.KNN(3)

# Addestramento dell'oggetto, passando gli elementi del dataset
knn.fit(X,y)

# Predizione del valore di classe per un vettore incognito
c = knn.predict([1.4,3.2,4.3,3])
print (c)

##############################################
#
# Utilizzo della regressione ai minimi quadrati implementata in ml.py
#
# Per sperimentare la regressione, proviamo a trovare la dipendenza fra
# la larghezza e la lunghezza dei petali (colonne 2 e 3 del dataset),
# rascurando ovviamente le classi.

# Costruzione dell'oggetto. Il costruttore non richiede parametri.
lsq = ml.LSQ1D()

# Addestramento dell'oggetto con le due colonne numeriche scelte
lsq.fit(X.iloc[:,2], X.iloc[:,3])

# Creazione di un grafico con i punti (x,y) appena considerati
plt.plot(X.iloc[:,2], X.iloc[:,3], '.')

# Aggiungiamo al grafico la retta di regressione unendo con una linea i punti (0,0)
# e (x_max,f(x_max))
x_max = max(X.iloc[:,2])
plt.plot([0, x_max], [lsq.predict(0), lsq.predict(x_max)])
plt.show()

