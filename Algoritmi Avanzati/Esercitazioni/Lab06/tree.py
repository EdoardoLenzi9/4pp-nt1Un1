#!/usr/bin/env python2
# -*- coding: utf-8 -*-
#
# tree.py
#
# Creazione di un semplice albero di decisione per variabili continue in ingresso
#
# Richiede la presenza dei file "iris.data" (dal repository UCI)
# nella stessa directory.
#
# Esecuzione:
#    python2 tree.py
# oppure
#    chmod 755 tree.py   <--- una tantum
#    ./tree.py
#
# Attenzione: il codice serve esclusivamente a scopi didattici
# e non è adatto a un utilizzo "serio": mancano molti accorgimenti e ottimizzazioni
# che lo renderebbero molto più complesso e difficile da capire.

############################################
#
# Moduli

# Numpy, per il trattamento di dati matriciali e funzioni di algebra lineare
import numpy as np

# Conteggio di elementi, utile per la stima di una distribuzione
from collections import Counter

# Lettura del file CSV
import pandas as pd

# Pretty-printing delle strutture dati
import pprint

#############################################
#
# Funzioni

# Data una lista di campioni, stima la distribuzione di probabilità della popolazione
# sulla base della frequenza relativa di ciascun valore
# e la restituisce come dizionario {valore: frequenza}
def distribution(y):
	m = len(y)
	c = Counter(y)
	return {v:float(n)/m for v,n in c.items()}

# Data una distribuzione restituita dalla precedente funzione, ne calcola l'entropia
def entropy(distr):
	H = 0
	for p in distr.values():
		H -= p * np.log(p)
	return H / np.log(2)

# Data una distribuzione restituita dalla precedente funzione, ne calcola l'impurità di Gini
def gini(distr):
	G = 1.0
	for p in distr.values():
		G -= p*p
	return G

# Dato un dataset X,y, trova la colonna di X che fornisce la miglior separazione del dataset in due parti
# utilizzando la mediana come soglia, sulla base dell'entropia attesa.
def split(X, y):
	# Numero di righe e colonne del dataset
	m,n = X.shape
	# Ricorda la migliore entropia attesa (da minimizzare)
	best_EH = 1e10
	# Itera su tutte le colonne
	for j in range(n):
		# Trova la mediana della colonna
		theta = np.median(X[:,j])

		# Spezza il dataset in due parti: (X1,y1) e (X2,y2)
		selector = X[:,j] <= theta
		X1 = X[selector]
		y1 = y[selector]
		selector = X[:,j] > theta
		X2 = X[selector]
		y2 = y[selector]

		# Calcola l'entropia dei due sottoinsiemi
		H1 = entropy(distribution(y1))
		H2 = entropy(distribution(y2))
		# Calcola l'entropia attesa
		EH = (H1 * len(y1) + H2 * len(y2)) / len(y)

		# Se è la migliore entropia trovata finore, ricorda la colonna, la soglia e i due sotto-dataset con le rispettive entropie (X1,y1,H1),(X2,y2,H2)
		if EH < best_EH:
			best_EH = EH
			best_split = {
				'column': j,
				'threshold': theta,
				'split1': (X1, y1, H1),
				'split2': (X2, y2, H2)
			}
	# Restituisci la migliore suddivisione trovata
	return best_split

# Addestramento ricorsivo di un albero di decisione.
# Il nodo interno di un albero ha la forma
#   {column: j, threashold: th, yes: sottoalbero sinistro, no: sottoalbero destro}
# Una foglia ha la forma
#   {y: classe}
def create_tree(X,y):
	# Calcola l'entropia dell'intero vettore y
	H = entropy(distribution(y))
	# Se è nulla, restituisci una foglia con lo stesso valore di classe di y
	if H == 0:
		return {'y': y[0]}
	# Altrimenti, trova la miglior suddivisione
	best_split = split(X, y)
	# Restituisci il nodo interno corrispondente alla decisione migliore e costruisci ricorsivamente il sottoalbero sinistro e destro.
	return {
		'column': best_split['column'],
		'threshold': best_split['threshold'],
		'yes': create_tree(
				best_split['split1'][0],
				best_split['split1'][1]),
		'no': create_tree(
				best_split['split2'][0],
				best_split['split2'][1])
	}

# Predizione ricorsiva, dato un vettore di ingresso x e un albero di decisione tree
def predict(x, tree):
	# Se tree è una foglia, restituisci il valore di classe relativo
	if 'y' in tree:
		print 'Found: %s' % tree['y']
		return tree['y']
	# Altrimenti, effettua una chiamata ricorsiva sul sottoalbero sinistro o destro, a seconda della risposta
	# positiva o negativa alla domanda del nodo corrente
	print 'X[%d] <= %f?' % (tree['column'], tree['threshold'])
	if x[tree['column']] <= tree['threshold']:
		print('Yes')
		return predict(x,tree['yes'])
	print('No')
	return predict(x,tree['no'])

#################################################################
#
# Codice di prova

# Lettura del dataset iris
iris = pd.read_csv(
	'iris.data', 
	names=[
		'Sepal width',
		'Sepal length',
		'Petal width',
		'Petal length',
		'Class'
	]
)

# Separazione della matrice in ingresso e della colonna in uscita
X = iris.iloc[:,:4].as_matrix()
y = iris.iloc[:,4].as_matrix()

# Stampa l'entropia totale dell'uscita
H = entropy(distribution(y))
print("L'entropia della classe di uscita è %f" % H)

# Addestra un albero di decisione sulla abse del dataset
tree = create_tree(X,y)

# Spampalo in maniera ordinata
print('Albero addestrato:')
pprint.pprint(tree)

# Avvia una predizione e stampane il risultato
print('Predizione di prova')
x = [5, 3.3, 1.4, 0.2]
result = predict(x, tree)
print ("La predizione per il vettore di ingresso %s è %s." % (str(x), result))
