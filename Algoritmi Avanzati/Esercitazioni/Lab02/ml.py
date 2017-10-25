#!/usr/bin/env python2
# -*- coding: utf-8 -*-
#
# ml.py
#
# Libreria contenente alcuni algoritmi di machine learning
#
# Esecuzione:
#    Importare la libreria nel programma principale con "import ml"
#    Vedere iris2.py come esempio d'uso.
#
# Attenzione: il codice serve esclusivamente a scopi didattici
# e non è adatto a un utilizzo "serio": mancano molti accorgimenti e ottimizzazioni
# che lo renderebbero molto più complesso e difficile da capire.

############################################
#
# Moduli

# Libreria numpy per la gestione delle matrici e l'algebra lineare
import numpy as np

# Conteggio delle occorrenze di un elemento in un vettore (utile per KNN)
from collections import Counter

############################################
#
# Funzioni di utilità

# Distanza euclidea al quadrato fra i due vettori x1 e x2
def distance2 (x1, x2):
	return sum((a-b)**2 for a,b in zip(x1,x2))

############################################
#
# K-Nearest Neighbors
#
# Definiamo la classe KNN contenente un costruttore __init__, una funzione di addestramento fit
# e una funzione di valutazione di un nuovo vettore predict.

class KNN:

	# Costruttore: si limita a memorizzare il parametro K nell'oggetto
	def __init__ (self, K):
		self.K = K

	# Addestramento: si limita a memorizzare il dataset X,y nell'oggetto
	def fit (self, X, y):
		self.X = X
		self.y = y

	# Valutazione del modello (predizione): dato il vettore incognito x1,
	# ne stima la classe trovando quella più rappresentata fra i K elementi
	# del dataset di addestramento più vicini a x1
	def predict (self, x1):
		# Crea la lista delle coppie (d_i,y_i) dove i itera sul dataset, d_i è
		# la distanza dell'i-esimo elemento del dataset da x1, e y_i è la sua classe. 
		d = [
			(distance2(v,x1),c)
			for v,c in zip(self.X.as_matrix(),self.y)
		]
		# Ordina la lista per distanza crescente e ne estrae i primi K elementi.
		sorted_d = sorted(d)[:self.K]
		# Recupera le sole informaazioni di classe, scartando le distanze.
		classes = [c for d,c in sorted_d]
		# Conta le occorrenze di ciascuna classe
		count = Counter(classes)
		# Restituisce la classe più rappresentata.
		return count.most_common(1)[0][0]

##################################################
#
# Minimi quadrati a una dimensione
#
# Definiamo la classe LSQ1D contenente una funzione di addestramento fit
# e una funzione di valutazione di un nuovo vettore predict.
# Non è necessario definire il costruttore perché non ci sono parametri da impostare.

class LSQ1D:

	def fit (self, x, y):
		xm = x.as_matrix()
		ym = y.as_matrix()
		self.beta = sum(a*b for a,b in zip(xm,ym)) / sum(a*a for a in xm)

	def predict (self, x):
		return self.beta * x


##################################################
#
# Minimi quadrati a più dimensioni
#
# Definiamo la classe LSQ contenente, come sopra, una funzione di addestramento fit
# e una funzione di valutazione di un nuovo vettore predict.
# Non è necessario definire il costruttore perché non ci sono parametri da impostare.

class LSQ:

	def fit(self, X, y):
		self.beta = np.linalg.inv(X.T.dot(X)).dot(X.T).dot(y)

	def predict(self, x):
		return self.beta.dot(x)


##################################################
#
# Regressione polinomiale ai minimi quadrati a una dimensione
#
# Definiamo la classe LSQ1d_poly contenente il costruttore,
# una funzione di addestramento fit
# e una funzione di valutazione di un nuovo vettore predict.
#
# La classe agisce da "contenitore" per un oggetto LSQ (vedi sopra).

class LSQ1d_poly:

	# Costruttore: inizializzato con il grado del polinomio
	def __init__(self, d):
		self.d = d

	# Funxzione di fit: espande il vettore colonna delle x
	# in una matrice le cui colonne contengono le potenze da 0 a d,
	# poi crea e addestra un oggetto di classe LSQ
	# utilizzando la matrice creata
	def fit (self, x, y):
		m = len(x)
		X = np.empty((m,self.d+1))
		for i in range(m):
			v = 1
			for j in range(self.d+1):
				X[i,j] = v
				v *= x[i]
		self.lsq = LSQ()
		self.lsq.fit(X,y)

	# Predittore: espande lo scalare x1 in un vettore contenente le potenze
	# da 0 a d, poi passa il vettore al predittore dell'oggetto LSQ
	# e ne restituisce il risultato.
	def predict(self, x1):
		x = np.empty(self.d+1)
		v = 1
		for j in range(self.d+1):
			x[j] = v
			v *= x1
		return self.lsq.predict(x)

