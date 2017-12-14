#!/usr/bin/env python2
# -*- coding: utf-8 -*-
#
# adult.py
#
# Esperimenti con gli alberi di decisione offerti da Scikit-learn
#
# Richiede la presenza dei file "adult.data", "adult.test" e "adult.names" (dal repository UCI)
# nella stessa directory. Produce un grafico e un file in formato dot.
#
# Esecuzione:
#    python2 adult.py
# oppure
#    chmod 755 adult.py   <--- una tantum
#    ./adult.py
#
# Attenzione: il codice serve esclusivamente a scopi didattici
# e non è adatto a un utilizzo "serio": mancano molti accorgimenti e ottimizzazioni
# che lo renderebbero molto più complesso e difficile da capire.

############################################
#
# Moduli

# Lettura del file CSV
import pandas as pd

# Modulo degli alberi di decisione
from sklearn import tree

# Tracciamento dei grafici
import matplotlib.pyplot as plt

# Espressioni regolari
import re


############################################
#
# Lettura dei dati

# Il file dati "adult.data" non contiene una riga di intestazione. Per conoscere i nomi delle colonne,
# li leggiamo dal file "adult.names", selezionando le righe che non iniziano per "|" e contengono ":"
column_names = []
with open('adult.names','r') as f:
	for line in f:
		line = line.strip()
		if len(line) == 0 or line[0] == '|':
			continue
		p = line.find(':')
		if p < 0:
			continue
		column_names.append(line[:p])
# La variabile dipendente non è citata nel file, ne inseriamo a mano il nome
column_names.append('income')

# Leggiamo il file di addestramento con i nomi delle colonne appena letti
training = pd.read_csv(
	'adult.data',
	names=column_names,
	skipinitialspace=True)
# Estraiamo in X_t le colonne di input (tutte tranne l'ultima),
# espandendo le colonne categoriche in notazione unaria con la
# funzione get_dummies()
X_t = pd.get_dummies(training[training.columns[:-1]])
# Estraiamo in y_t l'ultima colonna
y_t = training[training.columns[-1]]

# Leggiamo anche il file di test
validation = pd.read_csv(
	'adult.test',
	names=column_names,
	skipinitialspace=True,
	skiprows=1)
# Come sopra, però utilizziamo anche la funzione reindex per assicurarci che le colonne espanse in notazione unaria
# abbiano lo stesso ordine di quelle dell'insieme di addestramento
X_v = pd.get_dummies(validation[validation.columns[:-1]]).reindex(columns=X_t.columns,fill_value=0)
y_v = validation[validation.columns[-1]]
# Un ulteriore problema è che i valori delle y nell'insieme di test hanno un punto finale che non appare nella tabella di addestramento.
# Creiamo dunque una lista di traduzioni che levano l'ultimo carattere da tutti i valori della y e applichiamo la lista
# all'intera colonna
translations = {v:v[:-1] for v in y_v.unique()}
y_v = y_v.replace(translations)

#######################################################
#
# Addestramento e test dell'albero di decisione
#
# Vogliamo ora verificare l'accuratezza dell'albero di decisione
# al variare del parametro max_depth che fissa la profondità massima dell'albero.

# Lista delle profondità, da 1 a 30 (esclusa)
depths = range(1,30)
# lista delle corrispondenti accuratezza, inizialmente vuota
accuracies = []

# Iteriamo sulle profondità
for depth in depths:
	# Costruiamo il classificatore con la profondità massima appena definita
	classifier = tree.DecisionTreeClassifier(max_depth=depth)
	# Addestriamo il classificatore sull'insieme di addestramento
	classifier.fit(X_t, y_t)

	# Se la profondità è 3, salviamo una descrizione dell'albero in formato dot (per la libreria graphviz)
	if depth == 3:
		# Memorizziamo la descrizione dell'albero come stringa
		description = tree.export_graphviz(
					classifier,
					out_file=None)
		# Sostituiamo tutte le occorrenze della stringa "X[n]" (n numerico) con
		# il vero nome dell'n-esima colonna del nostro dataset
		description = re.sub(r'X\[([0-9]+)\]',
			lambda match: X_t.columns[int(match.group(1))],
			description)
		# Salviamo la descrizione così modificata nel file "adult.dot"
		with open('adult.dot','w') as f:
			f.write(description)

	# Utilizziamo l'albero appena addestrato per calcolare la predizione sul dataset di validazione
	y_p = classifier.predict(X_v)

	# Calcoliamo l'accuratezza della previsione in termini di risposte corrette sul totale degli esempi di validazione
	accuracy = sum(y_v==y_p) / float(len(y_v))
	# Aggiungiamo l'accuratezza alla lista
	accuracies.append(accuracy)
	print depth, accuracy

# Alla fine del ciclo, tracciamo l'andamento dell'accuratezza sulla base della profondità massima dell'albero
plt.plot(depths, accuracies)
plt.xlabel('Maximum depth')
plt.ylabel('Accurracy')
plt.grid()
plt.show()
