# Represents the wheels on the machine. It takes a "map" which is just the sequence of characters around it, starting from A and moving 
# counterclockwise. Next it takes its "topChar" which is whatever the top arrow is pointing at. This part of the initial string config.
# Next it takes an indicator distance. This is the ditance between the two arrows pointing to the wheel. The only reason this parameter exists
# is because the distance is different on the input wheel than all the others. The indicator distance is used to compute what the lower arrow
# is pointing at, given the topChar.
#
# The relevance of the indicators is in the algorithm we use to read and write with the engima. We have to cycle along the top row and down across
# the bottom. The wheel's methods will need to know which indicator arrow you are asking about or relative to
#
# You will notice a lot of %'s (modulo) flying around. These are just meant to model how the wheel loops back around when we calculate distances.
class Wheel:
	def __init__(self, map, topChar, indicatorDistance):
		self.map = map
		
		# This is always 37, the length of the alphabet. Can probably be refactored out.
		self.length = len(map) 
		
		# Internally the wheel just uses the index numbers of characters; their literal position in the "map". Eg A->0, B->5 or something.
		# This reversemap just makes a dictionary keyed by characters, that tells the wheel their index number.
		self.reverseMap = { char : index for index, char in enumerate(self.map)}

		# Convert the most important characters to their numbers.
		self.topNumber = self.reverseMap[topChar]
		self.bottomNumber = (self.topNumber + indicatorDistance) % self.length

		self.topChar = topChar
		self.bottomChar = self.map[self.bottomNumber]

	# Gets the index on this wheel of an arbitrary character.
	# In practive you will ask this wheel the index of a character to compute its relative distance to another character.
	def toIndex(self, char):
		return self.reverseMap[char]

	# For a given index, returns the character.
	def toChar(self, index):
		return self.map[index % self.length]

	# One of the most important methods.
	# Given a character, and which indicator you are currently on in the cycle, it will tell you how far you must turn this wheel to reach
	# that character from the topChar or bottomChar.
	def getDistance(self, char, indicator):
		if indicator == 0:
			charIndex = self.toIndex(char)
			return (charIndex - self.topNumber) % self.length
		elif indicator == 1:
			charIndex = self.toIndex(char)
			return (charIndex - self.bottomNumber) % self.length
		else:
			raise ValueError("Enter top (0) or bottom (1) into the indicator parameter")
		
	# The other important method. Given a rotation distance n, and which indicator you are looking at, this method
	# will tell you what you find when you rotate the gear clockwise by n steps.
	def getChar(self, n, indicator):
		if indicator == 0:
			char = self.map[(n + self.topNumber) % self.length] 
			return char
		elif indicator == 1:
			char = self.map[(n + self.bottomNumber) % self.length] 
			return char
		else:
			raise ValueError("Enter top (0) or bottom (1) into the indicator parameter")


# The main engima machine. This will take a list of wheel names, eg ["V5", "V7", "V1","V9","V3"], and an initial string, which is what
# the top row of indicator arrows are pointing at (ie the codeword).
# Given these it will assemble the wheels for you, and execute the algorithm for encoding and decoding.
class EnigmaFive:
	def __init__(self, wheelNameList, key):
		# The list of wheels. The order here reflects the order they are on the machine, and is important.
		# Ie if we have ["V5", "V7", "V1","V9","V3"] then V5 is the leftmost wheel, V7 immediately to its right, etc.
		self.wheelList = self.build_wheels(wheelNameList, key)
		self.inputWheel = self.wheelList[0]


	def build_wheels(self, wheel_name_list, key):
		wheel_list = []

		# This is an ugly implementation detail. The indicator arrows are a different distance 
		# on the first wheel than all the others. This is just so that the enigma machine can tell the wheels their distance when
		# constructing them.
		indicatorPositions = [33] + [27 for i in range(4)]

		# # The wheels are hardcoded here based on my by hand reading of them. As of Oct 14th I have not double checked them.
		# # Essentially this just sets the wheels up and passes their config info to them.
		for index, name in enumerate(wheel_name_list):
			if name == "V0":
				wheel_list.append(Wheel("A1YZD8BX2VLF7IOK0TW3EUMC9SRP4GJN6H5Q.", key[index], indicatorPositions[index]))
			elif name == "V1":
				wheel_list.append(Wheel("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.", key[index], indicatorPositions[index]))
			elif name == "V2":
				wheel_list.append(Wheel("ACB1ED2GF3IH4KJ5ML6ON7QP8SR9UT0WV.YXZ", key[index], indicatorPositions[index]))
			elif name == "V3":
				wheel_list.append(Wheel("AZY.XWVU09TSRQ87PONM65LKJI43HGFE21DCB", key[index], indicatorPositions[index]))
			elif name == "V4":
				wheel_list.append(Wheel("AZYXW.VU0TS1RQ2PO3NM4LK5JI6HG7FE8DC9B", key[index], indicatorPositions[index]))
			elif name == "V5":
				wheel_list.append(Wheel("ADCB12EHGF34ILKJ56MPNO78QTSR90UXWV.ZY", key[index], indicatorPositions[index]))
			elif name == "V6":
				wheel_list.append(Wheel("ABG6IP1VK3H0RD.4MY7NZE2OC9TJLXU5FWS8Q", key[index], indicatorPositions[index]))
			elif name == "V7":
				wheel_list.append(Wheel("AIT3DNF6MHS5GQK7PVWY8Z.1RX0B2LCO9JUE4", key[index], indicatorPositions[index]))
			elif name == "V8":
				wheel_list.append(Wheel("A3QN4U.T5LX7CSBRH8ZJO6VP2YEWG9IK1MD0F", key[index], indicatorPositions[index]))
			elif name == "V9":
				wheel_list.append(Wheel("AH.BGQ12PLFTMJ34UESDVW56KCZ78YNO90RIX", key[index], indicatorPositions[index]))
			else:
				raise ValueError("Enter a valid wheel name. \"n\" where n = 0,...9")
			
		return wheel_list


	# The "parity" is just whether we are on the top or bottom set of indicators at this stage of the algorithm.
	# At step n we check if the result of integer division by 4 is 0 or 1 mod 2. Eg at step n=3, n//4 = 0 and 0 mod 2 is 0.
	# But at n=5, n//4 = 1, and 1 mod 2 is 1.
	# A parity of 0 means top row, and of 1 means bottom row.
	def getParity(self, n):
		return (n // 4) % 2

	# the read index just tells us which wheel we are reading off of at step n in the algorithm.
	def getReadIndex(self, n):
		return (n % 4) + 1

	
	def encode(self, msg):
		encodedMsg = ""

		# For each character in the message we wish to encode, we ask the input wheel (leftmost) for its distance
		# from its indicated character. The indicated charactor depends on our current place in the algo.
		# Given that distance, we then ask the wheel at our current read index position to rotate that distance, 
		# with the corrent orientation, and ask what character will be there. We then add this character to the
		# encoded message sting.
		#
		# This one has a long going on and basically everything depends on which step we are in of the algorithm.
		# But the idea is just to asnwer what the nth wheel will read when we rotate the input wheel to some other character.
		for index, char in enumerate(msg):
			orientation = (-1)**(index + 1)
			distance = self.inputWheel.getDistance(char, self.getParity(index))
			nextChar = self.wheelList[self.getReadIndex(index)].getChar(orientation*distance, self.getParity(index))
			encodedMsg += nextChar

		return encodedMsg
	
	# This is very similar to encoding, except that we must now input along the "output" wheels, and read off of the "input wheel".
	# The only thing that changes in the code is that we compute distances of of wheel n, and then ask the "input wheel" what it finds 
	# on its indicator after rotating by that distance (all in the correct rotation direction and indicator).
	def decode(self, msg):
		decodedMsg = ""

		for index, char in enumerate(msg):
			orientation = (-1)**(index + 1)
			distance = self.wheelList[self.getReadIndex(index)].getDistance(char, self.getParity(index))
			nextChar = self.inputWheel.getChar(orientation*distance, self.getParity(index))
			decodedMsg += nextChar

		return decodedMsg

# machine = EnigmaFive(["V5","V1","V2","V3","V4"], "MN.9A")
# print(machine.encode("HOWNOWBROWNCOW"))
# print(machine.decode(machine.encode("HOWNOWBROWNCOW")))