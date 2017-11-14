#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# PC.py
#
# Simulazione object-oriented di una rete locale (livello 2):
#
# Uso:
#   python PC.py
#
# Codice realizzato nell'ambito della prima esercitazione del corso
# Reti Avanzate / Sicurezza dei Dati. Ulteriori detttagli nella dispensa:
#   http://disi.unitn.it/~brunato/RetiAvanzate/dispensa.pdf
#
# Attenzione: codice puramente dimostrativo. Non rappresenta in alcun modo
# il comportamento reale di una rete locale.

######################################################################
#
# Definizione di un frame di livello 2.
#
# Per i nostri scopi, un frame è un oggetto che contiene:
# - l'indirizzo MAC del destinatario;
# - l'indirizzo MAC del mittente
# - il contenuto
# Un indirizzo MAC è rappresentato da una stringa qualsiasi
# Altri campi non ci riguardano, oppure saranno aggiunti in seguito.
#
class EthernetFrame: # Definizione della classe

	# La funzione __init__() è il costruttore.
	# Ogni metodo non statico deve contenere "self" come primo argomento.
	def __init__(self, dest_mac, source_mac, payload):
		# memorizza in variabili i valori passati a parametro
		self.dest_mac = dest_mac
		self.source_mac = source_mac
		self.payload = payload

	# Metodo di comodo per convertire un oggetto in stringa a scopo
	# di rapresentazione umanamente leggibile.
	# Viene invocato automaticamente da funzioni come "print"
	def __str__(self):
		return '<To: %s; From: %s: Payload: %s>' % (
			self.dest_mac, self.source_mac, self.payload)

######################################################################
#
# Definizione di un PC (un "terminale").
#
# Ai nostri fini, un PC è un oggetto definito da:
# - un nome (stringa)
# - un'interfaccia di rete di livello 2, dotata di un indirizzo MAC
# - un riferimento a un altro dispositivo connesso
#   (un altro PC o un hub)
# L'oggetto espone i metodi:
# - connect(), chiamato dal codice principale per "connettere" il PC
#   a un altro dispositivo di rete;
# - send_ethernet_frame(), chiamato dal codice principale quando vuole simulare
#   l'invio di un frame da parte del PC;
# - receive_ethernet_frame(), chiamato ogni volta che il PC riceve un frame.
#
class PC:

	# Costruttore: originariamente, il PC ha un nome e un indirizzo MAC,
	# mentre non è connesso a nessun dispositivo
	def __init__(self, name, mac_address):
		self.name = name
		self.mac_address = mac_address
		self.connected_device = None # None è il null di C++ e Java

	# Connessione del PC a un altro dispositivo
	def connect(self, other):
		# La connessione avviene memorizzando il riferimanto di un dispositivo
		# nel membro "connected_device" dell'altro
		self.connected_device = other
		other.connected_device = self

	# Invio di un frame ethernet: richiede l'indirizzo MAC del destinatario e
	# il payload
	def send_ethernet_frame(self, dest_mac_address, payload):
		# Costruzione del frame utilizzando il proprio indirizzo MAC
		# come mittente
		frame = EthernetFrame(dest_mac_address,
					self.mac_address, payload)
		# Notifica l'invio
		print('%s: sending frame %s' % (self.name, frame))
		# L'invio consiste nell'invocazione del metodo
		# receive_ethernet_frame() del destinatario:
		self.connected_device.receive_ethernet_frame(frame)

	# Ricezione di un frame ethernet: invocata dall'oggetto
	# che spedisce il frame
	def receive_ethernet_frame(self, frame):
		# Notifica la ricezione del frame
		print('%s: received frame %s' % (self.name, frame))
		# Verifica se il frame è diretto al PC o no
		if frame.dest_mac == self.mac_address:
			# Se è diretto a noi, "usiamo" il frame
			print('\tUsing frame')
		else:
			# Altrimenti lo "scartiamo".
			print('\tDiscarding frame')


######################################################################
#
# Definizione di un hub.
#
# Un hub è un dispositivo LAN a cui sono connessi altri dispositivi, e che
# replica su tutte le porte ogni frame ricevuto,
# Per i nostri scopi, un hub è identificato da:
# - un nome
# - una lista di riferimenti ai dispositivi (per ora solo PC) ad esso collegati
# Espone solamente i metodi connect_pc() e receive_ethernet_frame();
# non può inviare frame di propria iniziativa.
class Hub:

	# Costruttore: riceve il nome dell'hub, inizializza la lista
	# dei dispositivi collegati
	def __init__(self, name):
		self.name = name
		self.connected_devices = []

	# Connessione dell'hub a un nuovo PC:
	def connect_pc(self, pc):
		# aggiunge il riferimento del PC
		# alla lista di dispositivi connessi
		self.connected_devices.append(pc)
		# Reciprocamente, inserisce il riferimento all'hub
		# come dispositivo collegato al PC.
		pc.connected_device = self

	# Invocata dal mittente quando "spedisce" un frame.
	def receive_ethernet_frame(self, frame):
		# Itera su tutti i dispositivi connessi
		for pc in self.connected_devices:
			# Invoca il metodo di ricezione del frame su tutti i
			# PC collegati. Si noti come il frame venga rispedito anche verso
			# il mittente: non dovrebbe accadere, ma vogliamo semplificare il
			# codice; correggeremo in seguito.
			pc.receive_ethernet_frame(frame)

#######################################################
#
# Programma principale

# Crea tre PC, ciascuno dotato di un proprio nome e indirizzo MAC
pc1 = PC('pc1', 'mac1')
pc2 = PC('pc2', 'mac2')
pc3 = PC('pc3', 'mac3')

# Crea un hub, con il proprio nome
hub1 = Hub('hub1')

# Connettiamo l'hub ai tre PC
hub1.connect_pc(pc1)
hub1.connect_pc(pc2)
hub1.connect_pc(pc3)

# Ordiniamo al PC 2 di spedire un frame con destinazione 'mac3'
pc2.send_ethernet_frame('mac3', 'Ciao!')
