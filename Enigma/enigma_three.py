class Wheel:
    def __init__(self, map, topState):
        self.map = map
        self.length = len(map)
        self.reverseMap = { char : index for index, char in enumerate(self.map)}
        self.topState = self.reverseMap[topState]
        self.orientation = None

    def setOrientation(self, orientation):
        self.orientation = orientation
        
    def toIndex(self, char):
        return self.reverseMap[char]

    def toChar(self, index):
        return self.map[index % self.length]

    def getDistance(self, char):
        charIndex = self.toIndex(char)
        return (charIndex - self.topState) % self.length
        
    def lookupChar(self, n):
       char = self.map[(self.orientation * n + self.topState) % self.length] 
       return char


class SmallEnigma:
    def __init__(self, wheelList):
        self.wheelList = wheelList
        self.wheelCount = len(self.wheelList)
        self.readPosition = 0
        self.inputWheel = wheelList[-1]
        
        for index, wheel in enumerate(self.wheelList):
            wheel.setOrientation((-1)**(self.wheelCount - index - 1))
            
    
    def encode(self, msg): 
        encodedMsg = ""

        for char in msg:
            distance = self.inputWheel.getDistance(char)
            nextChar = self.wheelList[self.readPosition].lookupChar(distance)
            self.readPosition = (self.readPosition + 1) % (self.wheelCount - 1)
            encodedMsg += nextChar

        self.readPosition = 0
        return encodedMsg


    def decode(self,msg):
        outputMsg = ""

        for char in msg:
            distance = self.wheelList[self.readPosition]
        


W50 = Wheel("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "Z")
W60 = Wheel("ACEDFHGIKJLNMOQPRTSUWVXZYB", "X")
W70 = Wheel("AZYXWVUTSRQPONMLKJIHGFEDCB", "P")

Machine = SmallEnigma([W70, W60, W50])

   
print(Machine.encode("SLACKY"))
#print(Machine.decode(Machine.encode("SLACKY")))
print()
print(Machine.encode("CAT"))
#print(Machine.decode(Machine.encode("CAT")))
print()
print(Machine.encode("ARROW"))
#print(Machine.decode(Machine.encode("ARROW")))