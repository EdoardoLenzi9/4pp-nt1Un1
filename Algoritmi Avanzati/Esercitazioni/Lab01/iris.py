#!/usr/bin/env python2
# -*- coding: utf-8 -*-
#
# sudo apt-get install python-pandas
# sudo apt-get install python-sklearn
#
# Esecuzione:
#    python2 iris.py
# oppure
#    chmod 755 iris.py   <--- una tantum
#    ./iris.py
#
############################################
#
# Moduli

# Libreria di Python per il trattamento di dati
import pandas

# Libreria per il machine learning: importiamo
# l'implementazione della Support Vector Machine
from sklearn import svm

# Libreria per tracciare grafici
import matplotlib.pyplot as plt

##############################################
#
# Lettura dei dati

# Leggiamo il dataset contenuto nel file iris.data;
# il file non ha una riga di intestazione, quindi la forniamo
# con il parametro opzionale 'names'.
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

# Spezziamo il dataframe iris in due parti: le variabili di input
# contenute nelle prime quattro colonne e la variabile di output
# contenuta nella quinta colonna.

X = iris.iloc[:,0:4]
y = iris.iloc[:,4]

#################################################
#
# Addestramento ed utilizzo di un modello di machine learning
#
# Questo spezzone di codice serve soltanto a dimostrare che non è necessario
# sapere come funzioni un algoritmo per poterlo utilizzare.

# Creazione di un classificatore (SVC = Support Vector Classifier)
f = svm.SVC()

# Addestramento del modello con i dati letti dal file:
# la funzione fit() richiede di passare separatamente i valori di ingresso e di uscita
# degli esempi

f.fit(X,y)

# Utilizzo del modello su due esemplari diversi da quelli contenuti negli esempi
y1 = f.predict([
	[6.2,2.2,4.5,1.5],
	[3,5,4,2]
])

# Stampa della classe 'predetta' per ciascuno dei due esemplari.
print('Predicted classes for the two specimens: ' + ', '.join(y1))

################################################
#
# Visualizzazione dei dati
#
# Questo spezzone introduce l'uso di una libreria per il tracciamento dei grafici

# Dato il vettore y delle classi degli esemplari letti dal file,
# costruiamo l'insieme dei valori distinti utilizzando la struttura dati 'set'
classes = set(y)

print('Possible classes: ' + ', '.join(classes))

# Per ciascuna delle classi:
for c in classes:
	# estraiamo i soli campioni corrispondenti alla classe c
	sub_dataset = iris[iris.iloc[:,4] == c]
	# Ne aggiungiamo le prime due coordinate colonne (0 e 1) a un diagramma a dispersione
	plt.plot(
		sub_dataset.iloc[:,0],
		sub_dataset.iloc[:,1],
		'.',
		label=c
	)

# Terminata l'aggiunta dei punti corrispondenti alle varie classi,
# aggiungiamo una legenda
plt.legend()

# Visualizziamo il grafico di dispersione in una nuova finestra
plt.show()

####################################################
#
# Scrittura di un semplice algoritmo di machine learning

# Realizziamo una semplice funzione che, dato un dataset (X,y)
# di esempi classificati e dato un vettore x1 che rappresenta un
# nuovo campione, restituisce la classe dell'elemento x del dataset
# che è più vicino (in base alla distanza euclidea) a campione incognito.
def NearestNeighbor(X, y, x1):
	# m, n <- numero di righe e colonne del dataset
	m,n = X.shape

	# Ricerca dell'elemento in X più vicino a x1
	# Inizializziamo la distanza minima finora trovata a un valore molto grande 
	min_d = 1.0e30
	min_class = None
	# Per ogni valore dell'indice di riga i:
	for i in range(m):
		# x (minuscolo) contiene le coordinate X dell'i-esimo campione
		x = X.iloc[i]
		# Calcolo della distanza euclidea (in realtà calcoliamo il suo quadrato)
		# come somma dei quadrati delle differenze fra le coordinate
		d = 0
		for j in range(n):
			d += (x[j]-x1[j])**2
		# Se la distanza è minore della minima trovata finora, la ricordiamo
		# e ricordiamo pure la classe dell'esemplare corrispondente
		if d < min_d:
			min_d = d
			min_class = y[i]

	# La funzione termina restituendo la classe dell'elemento avente distanza minima da x1
	return min_class

# Ora proviamo la funzione. Definiamo un nuovo vettore con 4 coordinate
x1 = [5.2,2.3,3.2,1.1]
# Invocchiamo la funzione di previsione passando il dataset noto (X,Y)
# e il nuovo vettore incognito; piazziamo la risposta della funzione in y1
y1 = NearestNeighbor(X, y, x1)
# Stampiamo la previsione
print('Class predicted by our function: ' + y1)

