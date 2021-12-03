from enigma_five import EnigmaFive
from random import randint

alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789."
wheels = ["V0","V1","V2","V3","V4","V5","V6","V7","V8","V9"]

# Makes a word with characters from our alphabet of a given length
def makeRandomWord(length = 5):
	word = ""
	for i in range(length):
		word += alphabet[randint(0,36)]
	return word

def makeInitialString():
	return makeRandomWord(5)

# Makes a random list of wheels for the Enigma configuration, in accordance with cert exclusion rules.
# In particular no wheel should appear twice, and the reverse side of each wheel VN is the wheel V(N+5 mod 10) which we must also
# exclude when N is present.
# For instance if we have V5, we cannot allow V5 to appear again. Also the back side of V5 is V0, so we must also exclude V0 when V5 is present.
def makeRandomWheelConfig():
	list = []
	excluded = []
	while len(list) < 5:
		n = randint(0,9)
		if n in excluded: 
			continue # skip because Vn is present
		elif (n+5) % 10 in excluded:
			continue # skip because Vn's reverse side is present
		else:
			# Here we add n, and then exluce it and its reverse side
			excluded += [n, (n+5) % 10] 
			list.append(wheels[n])

	return list

# Make a word list of a given length, with given max and min word sizes present
def makeWordList(wordCount = 10, maxWordSize = 10, minWordSize = 0):
	list = []
	for i in range(wordCount):
		word = makeRandomWord(randint(minWordSize,maxWordSize))
		list.append(word)
	return list

# Putting it all together now! We generate a list of random words of a certain length with the given size parameters.
# Then for each run in the count, we generate a machine with a random configuration of initial string and wheels. We 
# test an encode/decode loop for each word in the list. If any words fail we record them to a failure list which we
# return at the end.
def testEncodeDecode(runCount = 100, wordCount = 100, maxWordSize = 100):
	wordList = makeWordList(wordCount, maxWordSize = maxWordSize)
	for i in range(runCount):
		wheelList = makeRandomWheelConfig()
		initialString = makeInitialString()
		machine = EnigmaFive(wheelList, initialString)


		failures = []

		for word in wordList:
			encodedString = machine.encode(word)
			decodedString = machine.decode(encodedString)
			
			if word == decodedString:
				continue
			else:
				failures.append({"word": word,
				"initialString": initialString,
				"wheelList": wheelList,
				"encodedString": encodedString,
				"decodedString": decodedString
				})

	return (failures)

# Takes a minute to run but I havent found a failure yet!
#print(testEncodeDecode(1000, 100, 100))