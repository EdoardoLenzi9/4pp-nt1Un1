#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Layer2Simulator.py
#
# Simulazione object-oriented di una rete locale (livello 2):
#
# Uso:
#   python Layer2Simulator.py
#
# Codice realizzato nell'ambito della seconda esercitazione del corso
# Reti Avanzate / Sicurezza dei Dati. Ulteriori detttagli nella dispensa:
#   http://disi.unitn.it/~brunato/RetiAvanzate/dispensa.pdf
#
# Attenzione: codice puramente dimostrativo. Non rappresenta in alcun modo
# il comportamento reale di una rete locale.

######################################################################
#
# Importazione di moduli esterni

# generazione di numeri casuali: per noi il MAC address sarà un numero
# casuale associato a una porta
import random

######################################################################
#
# Definizione di un frame di livello 2.
#
# Per i nostri scopi, un frame è un oggetto che contiene:
# - l'indirizzo MAC del destinatario (dest_mac);
# - l'indirizzo MAC del mittente (source_mac);
# - il contenuto (payload).
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

################################################################
#
# Una porta Ethernet
#
# La porta è un dispositivo che va collegato a un'altra porta
# e riceve ed invia frame alla porta a cui è collegata.
# Ha i seguenti campi:
# - un nome (una stringa come "e0" per poterla identificare in dispositivi
#   come gli hub e gli switch che ne possiedono più d'una);
# - un riferimento al dispositivo a appartiene;
# - un riferimento alla porta a cui è connessa (inizialmente None)
# - opzionalmente, un MAC address (solo se è una porta destinataria finale
#   di frame)
#
class EthernetPort:

	# Costruttore: assegna il nome e il dispositivo di appartenenza.
	# Inizialmente, non è connessa a un'altra porta.
	# Se has_mac_address è vero, allora si attribuisce un MAC address casuale.
	def __init__(self, name, device, has_mac_address = False):
		self.name = name
		self.device = device
		self.connected_port = None
		if has_mac_address:
			self.mac_address = random.randint(0,1000000000000)
		else:
			self.mac_address = None

	# Per "spedire" un frame, il dispositivo a cui appartiene la porta
	# ne invoca il metodo send_frame(), che a sua volta invoca il metodo
	# receive_frame() della porta a cui è connessa.
	def send_frame(self, frame):
		if self.connected_port:
			self.connected_port.receive_frame(frame)

	# Quando la porta "riceve" un frame, controlla se il frame
	# è ricevibile (la porta non ha MAC address, o il destinatario del
	# frame è la porta stessa), poi invoca il metodo receive_frame() del
	# dispositivo a cui appartiene, passando anche il proprio nome.
	def receive_frame(self, frame):
		if (self.mac_address is None or frame.dest_mac == self.mac_address):
			self.device.receive_frame(frame, self.name)

#################################################################
#
# Definizione di un hub.
#
# Contiene i seguenti campi:
# - un nome, per distinguere i dispositivi tra loro;
# - un "dizionario" di porte che mappa i nomi delle porte alle porte stesse.
#
# Un hub non invia frame di propria iniziativa, ma diffonde i frame che riceve.
# Non possiede dunque un metodo send_frame(), ma solo receive_frame().
#
class Hub:

	# Il costruttore è invocato con il nome e il numero di porte.
	# Crea tutte le porte richieste con nome 'e0', 'e1'...
	# e le memorizza nel dizionario "ports" in corrispondenza del loro nome.
	def __init__(self, name, n_ports):
		self.name = name
		self.ports = {}
		for i in range(n_ports):
			port_name = 'e'+str(i)
			self.ports[port_name] = EthernetPort(port_name, self)

	# Alla ricezione di un frame "frame" dalla porta "receiver_port_name",
	# itera su tutte le porte e inoltra il frame, evitanto le porte
	# non collegate e quella su cui il frame è stato ricevuto.
	def receive_frame(self, frame, receiver_port_name):
		print('%s: received %s from %s' %
				(self.name, frame, receiver_port_name))
		for port_name in self.ports:
			if port_name != receiver_port_name:
				print('%s: forwarding to %s' % (self.name, port_name))
				self.ports[port_name].send_frame(frame)

##############################################################
#
# Definizione di un PC (un dispositivo terminale).
#
# Un PC ha i seguenti campi:
# - un nome;
# - un dizionario di porte (per uniformità con l'hub, però conterrà una
#   sola porta di nome 'e0').
#
# Un PC può sia ricevere che spedire frame, quindi definirà sia il metodo
# send_frame() che il metodo receive_frame().
#
class PC:

	# Costruttore: memorizziamo il nome e creiamo la porta memorizzandola
	# sotto il nome 'e0' nel dizionario "ports". Osserviamo l'argomento "True"
	# nella costruzione della porta Ethernet, perché dev'essere dotata di
	# MAC address.
	def __init__ (self, name):
		self.name = name
		self.ports = {}
		self.ports['e0'] = EthernetPort('e0', self, True)

	# Ricezione di un frame: stampa a video il messaggio che il frame
	# è stato ricevuto.
	def receive_frame(self, frame, port_name):
		print('%s: received %s' % (self.name, frame))

	# Invio di un frame: dato il MAC address di destinazione e il payload,
	# costruisce il frame e lo passa alla porta 'e0' per la spedizione.
	def send_frame(self, dest_mac, payload):
		frame = EthernetFrame(dest_mac, self.ports['e0'].mac_address, payload)
		print('%s: sending %s' % (self.name, frame))
		self.ports['e0'].send_frame(frame)

####################################################################
#
# Connessione di due porte.
#
# Assegna ad ogni porta il riferimento all'altra, in modo che ciascuna
# possa invocare il metodo receive_frame() dell'altra quando
# deve simulare la spedizione di un pacchetto.
#
def connect_ports(p1, p2):
	p1.connected_port = p2
	p2.connected_port = p1

################################################################
#
# Primo esperimento: due hub connessi fra loro, ciascuno
# collegato a due PC. Invio di un frame.
#
################################################################

print('=== First test: network with hubs ===')

print('-- Creating four PCs')
pc1 = PC('pc1')
pc2 = PC('pc2')
pc3 = PC('pc3')
pc4 = PC('pc4')

print('-- Creating two hubs')
hub1 = Hub('hub1', 4)
hub2 = Hub('hub2', 4)

print('-- Connecting PCs to hubs')
connect_ports(pc1.ports['e0'], hub1.ports['e0'])
connect_ports(pc2.ports['e0'], hub1.ports['e1'])
connect_ports(pc3.ports['e0'], hub2.ports['e0'])
connect_ports(pc4.ports['e0'], hub2.ports['e1'])

print('-- Connecting hubs to each other')
connect_ports(hub1.ports['e2'], hub2.ports['e2'])

print('-- Sending frame from pc1 to pc4')
pc1.send_frame(pc4.ports['e0'].mac_address, 'Ciao!')

print('-- Sending frame from pc4 to pc1')
pc4.send_frame(pc1.ports['e0'].mac_address, 'Hi!')

################################################################
#
# Secondo esperimento: come sopra, ma con switch al posto
# degli hub.
#
################################################################

#######################################################
#
# Definizione dello Switch come classe derivata da Hub
#
# Lo switch ha soltanto un campo in più rispetto all'hub:
# - un dizionario "mac_table" che associa a ogni MAC address noto
#   la porta dalla quale quel MAC address è stato visto entrare
#   come campo sorgente di un frame.
#
class Switch (Hub):

	# Il costruttore invoca quello di Hub,
	# poi definisce la mac_table vuota.
	def __init__(self, name, n_ports):
		Hub.__init__(self, name, n_ports)
		self.mac_table = {}

	# Ridefinizione del metodo receive_frame()
	def receive_frame(self, frame, port_name):
		# Per prima cosa, lo switch "impara" la porta associata
		# al campo sorgente del frame ricevuto, memorizzando
		# l'associazione nella mac_table
		self.mac_table[frame.source_mac] = port_name
		# In seguito, inoltriamo il frame.
		# Se il destinatario appare nella mac_table, allora
		# il pacchetto viene inoltrato solamente alla porta
		# giusta.
		if frame.dest_mac in self.mac_table:
			port = self.mac_table[frame.dest_mac]
			print('%s: forwarding to %s' % (self.name, port))
			self.ports[port].send_frame(frame)
		# Altrimenti, lo switch si comporta esattamente come un hub,
		# invocando il metodo receive_frame della classe genitore
		else:
			Hub.receive_frame(self, frame, port_name)

print('\n=== Second test: network with switches ===')

print('-- Creating four PCs')
pc1 = PC('pc1')
pc2 = PC('pc2')
pc3 = PC('pc3')
pc4 = PC('pc4')

print('-- Creating two switches')
sw1 = Switch('sw1', 4)
sw2 = Switch('sw2', 4)

print('-- Connecting PCs to switches')
connect_ports(pc1.ports['e0'], sw1.ports['e0'])
connect_ports(pc2.ports['e0'], sw1.ports['e1'])
connect_ports(pc3.ports['e0'], sw2.ports['e0'])
connect_ports(pc4.ports['e0'], sw2.ports['e1'])

print('-- Connecting switches to each other')
connect_ports(sw1.ports['e2'], sw2.ports['e2'])


print('-- Sending frame from pc1 to pc4')
pc1.send_frame(pc4.ports['e0'].mac_address, 'Ciao!')

print('-- Sending frame from pc4 to pc1')
pc4.send_frame(pc1.ports['e0'].mac_address, 'Hi!')
