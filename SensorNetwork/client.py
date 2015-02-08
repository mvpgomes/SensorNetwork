#!/usr/bin/env python

# ------------------------------------- #
# User interface for the Sensor Network #
# ------------------------------------- #

import sys;
from TOSSIM import *
from tinyos.tossim.TossimApp import *
from RadioCollarMsg import *

# number of options in the main menu
max_options = 6
max_nodes = 18
msg_id = 0

# message options TAG
AM_TYPE = 255
LOCATION = 0
ANIMAL_FOOD_AMOUNT = 1
SPOT_REMAINING_FOOD_AMOUNT = 2
DAILY_ANIMAL_CONSUMPTION = 3
DAILY_FEEDING_SPOT_DROP = 4

# load the system components
n = NescApp()
t = Tossim(n.variables.variables())
m = t.mac()
r = t.radio()

t.addChannel("CollarC", sys.stdout)

# add the nodes to the radio channel and boot them
for i in range(max_nodes):
	m = t.getNode(i)
	m.bootAtTime((31 + t.ticksPerSecond() / 10) * i +  1)

# create the sensor network topology 
f = open("topo.txt", "r")
for line in f:
  s = line.split()
  if s:
    if s[0] == "gain":
      r.add(int(s[1]), int(s[2]), int(s[3]))

# create the noise model for each node
noise = open("meyer-heavy.txt", "r")
for line in noise:
  s = line.strip()
  if s:
    val = int(s)
    for i in range(max_nodes):
      t.getNode(i).addNoiseTraceReading(val)

for i in range(max_nodes):
  t.getNode(i).createNoiseModel()

# Functions that are invoked by the user.
# TODO : change the nunber of events fired.
def sendMessage(msg_type):
	nodeid = int(raw_input("Enter the node identifier : "))
	msg = RadioCollarMsg()
	msg.set_msg_type(msg_type)
	global msg_id
	msg.set_msg_id(msg_id)
	msg_id += 1
	pkt = t.newPacket()
	pkt.setData(msg.data)
	pkt.setType(msg.get_amType())
	pkt.setDestination(nodeid)
	pkt.deliver(nodeid, t.time() + 3)
	t.runNextEvent();
	time = t.time()
	while time + 25000000000 > t.time():
  		t.runNextEvent()

def sendModifiedMessage(msg_type):
	nodeid = int(raw_input("Enter the node identifier : "))
	amount = int(raw_input("Enter the amount : "))
	msg = RadioCollarMsg()
	msg.set_msg_type(msg_type)
	msg.set_food_amount(amount)
	global msg_id
	msg.set_msg_id(msg_id)
	msg_id += 1
	pkt = t.newPacket()
	pkt.setData(msg.data)
	pkt.setType(msg.get_amType())
	pkt.setDestination(nodeid)
	pkt.deliver(nodeid, t.time() + 3)
	t.runNextEvent();
	time = t.time()
	while time + 25000000000 > t.time():
  		t.runNextEvent()

def trackNode():
	nodeid = int(raw_input("Enter the node identifier : "))
	m = t.getNode(nodeid)
	v1 = m.getVariable("CollarC.x_coordinate")
	v2 = m.getVariable("CollarC.y_coordinate")
	x = v1.getData()
	y = v2.getData()
	print "The previous know node location was X : %d Y : %d\n" %(x, y)

def locateAnimals():
	sendMessage(LOCATION)
	print "Locating Animals ...\n"

def locateUntrackedAnimals() :
	trackNode()
	print "Locating Untracked Animals ...\n"

def consumedFood():
	sendMessage(ANIMAL_FOOD_AMOUNT)
	print "The amount consumed was ...\n"

def remainingFood():
	sendMessage(SPOT_REMAINING_FOOD_AMOUNT)
	print "The remaining food at the feeding spots is ...\n"

def updateAnimalFoodAmount():
	sendModifiedMessage(DAILY_ANIMAL_CONSUMPTION)
	print "Changing the food amount per animal by %d\n" %(amount)

def updateFeedingSpotAmount():
	sendModifiedMessage(DAILY_FEEDING_SPOT_DROP)
	print "Changing the food amount per feeding spot by %d\n" %(amount)

# Dictionary used by identify the functions

options = {
	1 : locateAnimals,
	2 :	locateUntrackedAnimals,
	3 : consumedFood,
	4 : remainingFood,
	5 : updateAnimalFoodAmount,
	6 : updateFeedingSpotAmount, 
}	

print "Welcome to Sensor Network, the supported functionalities are :"

# Main loop

while True :

	print "1 - Locate all animals in the Network."
	print "2 - Previous location of the non tracked animals."
	print "3 - Amount of food consumed by each animal."
	print "4 - Amount of food remaining in the feeding spots."
	print "5 - Update the food amount per animal."
	print "6 - Update the food amount per feeding spot."

	try:
		num = int(raw_input("Please, choose an option : "))	
	except ValueError:
		print "Please insert a valid option.\n"
		continue
	
	if num > 0 and num <= max_options :
		options[num]()
	else : 
		print "Please choose a valid option.\n"

