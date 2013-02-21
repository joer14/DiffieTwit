#; CMPE12 - Winter 2012 Tracy Larrabee
#; Eric Cao
#; Rutherford Le
#; Joe Rowley 
#; Tyler Smith
#; Lab 8
#; Section 3 Jay
#; Section 4 Daniel
#; 3/14/12;
#; This script is part of Diffie Hellman encrpytion key exchange system implemented on the HC11. The
#; HC11 is connected to computer running this script after the code has been uploaded to it.

import serial
import fileinput
import time
import os
import twitter
import datetime

def checkstatus(currentID):
	oldstatus =  str(client.GetUserTimeline(currentID)[0].text)
	while oldstatus == str(client.GetUserTimeline(currentID)[0].text):
		print "No new tweets found. Checking again in 30 seconds..."
		time.sleep(10)

	return str(client.GetUserTimeline(currentID)[0].text)

#petescomputed = str(client.GetUserTimeline('hc11baby')[0].text)

print 'waiting for serial input'

joekey = ********
ser = serial.Serial("/dev/tty.KeySerial1")  # open first serial port
#ser = serial.Serial("/dev/tty.usbserial-A9003ZlA")  # open first serial port
pp = ser.read(1)
pi = ser.read(1)
ps = ser.read(1)
print 'HC11 generated prime number  ' + str(ord(pp))
print 'HC11 generated int '+ str(ord(pi))
print 'HC11 computed value ' + str(ord(ps))

client = twitter.Api()
tylerapi = twitter.Api(consumer_key='**********',consumer_secret='**************', 
	access_token_key='********', access_token_secret='**********')

keys = str(ord(pp)) + ' ' + str(ord(pi)) + ' ' + str(ord(ps))

status = tylerapi.PostUpdate(keys + ' ' + str(datetime.datetime.now()))

petescomputed = checkstatus('hc11baby')

petescomputed = petescomputed.split()
print 'pete sent back ' + petescomputed[0]

pspete = chr(int(petescomputed[0]))

print 'writing key ' + pspete + ' to hc11'
print 'waiting for acknowledge from hc11'
ser.write(pspete)
ser.read(1)

print 'received acknowedge. Secret shared key generated.  Letting Pete know.'
tylerapi.PostUpdate('Acknowledged.  Your key has been computed and private shared has been generated.' + str(datetime.datetime.now()))

while(True):
	encrypted = checkstatus('hc11baby').split()
	print 'received encrypted transmission'
	print encrypted
	for num in encrypted:
		ser.write(chr(int(num)))
		time.sleep(.5)
	print 'sent message out over serial'
	break
	tylerapi.PostUpdate('Encrypted message received.  Another? ' + str(datetime.datetime.now()))
