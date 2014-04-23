#!/usr/bin/python
#
# Copyright 2014 by Idiap Research Institute, http://www.idiap.ch
#
# See the file COPYING for the licence associated with this software.
#
# Author(s):
#   Mathew Doss,  April 2014
#   Milos Cernak, April 2014
#


import sys, getopt

(opts, args) = getopt.getopt(sys.argv[1:], "")

if not len(args) == 2:
	print "USAGE: %s model_list htk_hmm_definition" % sys.argv[0]
	sys.exit(-1)

output = open("hmmdefs/%s.hmmdef" % args[1], "wt")
phones = open(args[0], "rt").read().split()[1:]

dimension = open("%s/%s.model" % (args[1], phones[1]), "rt").read().split("\n")[0].split(' ')[1]

print "Don't forget the 'sp' model"
print "Number of models:", len(phones)

print >> output, "~o"
print >> output, "<STREAMINFO> 1", dimension
print >> output, "<VECSIZE>", dimension, "<NULLD><USER><DIAGC>"
for phone in phones:
	if phone == "":
		break
	def_phone = open("%s/%s.model" % (args[1], phone), "rt").read().split("\n")
	(n_states, dimension) = def_phone[0].split(" ")
	n_states = int(n_states)
	dimension = int(dimension)
	states_parameters = def_phone[1:n_states+1]
	transition_parameters = def_phone[n_states+1:n_states+1+n_states]
	print >> output, "~h \"%s\"" % phone
	print >> output, "<BEGINHMM>"
	print >> output, "<NUMSTATES>", (n_states + 2)
	for i_state in range(n_states):
		print >> output, "<STATE>", i_state+2
		print >> output, "<MEAN>", dimension
		print >> output, "".join(states_parameters[i_state])
		print >> output, "<VARIANCE>", dimension
		print >> output, "1.0 "*dimension
	print >> output, "<TRANSP>", (n_states + 2)
	print >> output, "0.0 1.0", "0.0 "*n_states
	for i_state in range(n_states-1):
		print >> output, "0.0", "".join(transition_parameters[i_state]), "0.0"
	value = float(transition_parameters[n_states-1].split(' ')[-1])
	print >> output, "0.0", "".join(transition_parameters[n_states-1]), str(1-value)
	print >> output, "0.0 "*(n_states + 2)
	print >> output, "<ENDHMM>"
	

