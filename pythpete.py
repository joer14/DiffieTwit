#; CMPE12 - Winter 2012 Tracy Larrabee
#; Eric Cao
#; Rutherford Le
#; Joe Rowley 
#; Tyler Smith
#; Lab 8
#; Section 3 Jay
#; Section 4 Daniel
#; 3/14/12;
#; This script is part of Diffie Hellman encrpytion key exchange system implemented on the HC11.
#; This script is run on the computer that is not connected to the HC11. This script should be
#; executed before the alice.py script is uploaded. 

import twitter

def checkstatus(currentID):
	oldstatus =  str(client.GetUserTimeline(currentID)[0].text)
	while oldstatus == str(client.GetUserTimeline(currentID)[0].text):
		print "No new tweets found. Checking again in 30 seconds..."
		time.sleep(30)

	return str(client.GetUserTimeline(currentID)[0].text)

def encrypt (key, string):

	encryptchar = []
	for ch in string:
		encryptchar.append(ord(ch) ^ sharedsecret)
	
	encstring = ''
	for c in encryptchar:
		encstring = encstring + str(c) + ' '

	return encstring

def decrypt (key, string):
	decstring = ''
	for num in string.split():
		decstring = decstring + chr(int(num) ^ sharedsecret)
	return decstring

#does the power/modulus operation
#takes public int/other communicators computed value, random secret and public prime as parameters 
def modop(var, rs, pp):
	total = var
	while rs is not 1:
		#print total
		total = (total * var)# % 256
		#if total is 0 : total = 1
		rs -= 1
	return total % pp

#random secret.  In final implementation should be taken via stdin
rs = 10
joeapi = twitter.Api(consumer_key='*****',consumer_secret='***', 
    access_token_key='****', access_token_secret='****')

client = twitter.Api()
latest_posts = client.GetUserTimeline("thatguyty628")

firstkeys = latest_posts[0].text.split()

#public prime
pp = int(firstkeys[0])
#public int
pi = int(firstkeys[1])
#public computed (other user)
pc = int(firstkeys[2])

print 'public prime is ' + str(pp)
print 'public int is ' + str(pi)
print 'public computer by alice is ' +str(pc)
mypc = modop(pi, rs, pp)
#print mypc

#private shared
ps = modop(pc, rs, pp)

#print ps

status = joeapi.PostUpdate(str(mypc) + ' v')

ack = checkstatus('thatguyty628')

#msg = input('Message to be encrypted: ')
msg = 'encrypt me ln=16'
encrypted = encrypt(ps, msg)

joeapi.PostUpdate(encrypted)
	
#checkstatus(status.id)


#print firstkeys

#print [s.text for s in latest_posts]

#rtext = 'Encrypt me'

#publicprime = 13
#publicnum = 6
#secretnum = 3

#print 'received ' + str(publicprime) + ' and ' + str(publicnum)

#publicshared = pow(publicnum, secretnum) % publicprime

#receivedpublic = 4

#print 'publicly transmitted ' + str(publicshared)
#print 'received ' + str(receivedpublic)

#sharedsecret = pow(receivedpublic, secretnum) % publicprime

#encrypted = encrypt(sharedsecret, rtext)

#print 'encrpyted string is ' + encrypted 
#print 'decrypted string is "' + decrypt(sharedsecret, encrypted) + '"'

