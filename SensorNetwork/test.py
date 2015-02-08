#!/usr/bin/env python

# ------------------------------------- #
# User interface for the Sensor Network #
# ------------------------------------- #

import sys;
from TOSSIM import *

# number of options in the main menu
max_options = 6
max_nodes = 19

# load the system components
t = Tossim([])
m = t.mac()
r = t.radio()

t.addChannel("CollarC", sys.stdout)

print "Channel Added ..."

# add the nodes to the radio channel and boot them
for i in range(0, max_nodes):
  m = t.getNode(i)
  m.bootAtTime((31 + t.ticksPerSecond() / 10) * i +  1)

print "Nodes started and added to the radio channel ..."

# create the sensor network topology 
f = open("topo.txt", "r")
for line in f:
  s = line.split()
  if s:
    if s[0] == "gain":
      r.add(int(s[1]), int(s[2]), int(s[3]))

print "Network Topology created .... "

# create the noise model for each node
noise = open("meyer-heavy.txt", "r")
for line in noise:
  s = line.strip()
  if s:
    val = int(s)
    for i in range(0, max_nodes):
      t.getNode(i).addNoiseTraceReading(val)

print "Add the values relative to the NoiseModel for each node ...."

for i in range(0, max_nodes):
  t.getNode(i).createNoiseModel()

print "Create the NoiseModel for all nodes ..."  

for i in range(120):
  t.runNextEvent();
