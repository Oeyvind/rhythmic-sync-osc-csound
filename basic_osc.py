#!/usr/bin/python
# -*- coding: latin-1 -*-

"""
Serial melody generator in Python, communicating via OSC to play notes in Csound

@author: Øyvind Brandtsegg
@contact: obrandts@gmail.com
@license: GPL
"""

import osc_io # osc server and client 

# basic settings for the melody generator
notes = [0,2,4,5,7,9,11,12] # the notes that we will use for our melody

def osc_handler(unused_addr, *osc_data):
    '''Message handler. This is called when we receive an OSC message'''
    index, basenote = osc_data # unpack the OSC data, must have the same number of variables as we have items in the data
    notenum = basenote + notes[index%len(notes)] # get note number for next event
    returnmsg = [notenum] #pack the values that we want to send back to Csound via OSC
    print('note num: {}'.format(returnmsg))
    osc_io.sendOSC("csound_receive", returnmsg) # send OSC back to Csound

if __name__ == "__main__": # if we run this module as main we will start the server
    osc_io.dispatcher.map("/csound_send", osc_handler) # here we assign the function to be called when we receive OSC on this address
    osc_io.asyncio.run(osc_io.run_osc_server()) # run the OSC server and client

