from more_itertools.more import circular_shifts
from enigma_five import EnigmaFive 
from text_analyzer import TextAnalyzer 
from itertools import permutations, product # https://docs.python.org/3/library/itertools.html#itertools.permutations
from more_itertools import consume # https://pypi.org/project/more-itertools
import io
import constants



class Solver:
	def __init__(self, ciphertext, key_prefix, sensitivity = 0.3):
		self.ciphertext = ''.join(ciphertext.split()) # split and join to remove whitespace between words
		self.sensitivity = sensitivity
		self.key_prefix = key_prefix
		self.key_prefix_length = len(key_prefix)

		# Generates all the combinations we need
		self.key_suffixes = product(constants.ALPHABET, repeat = (5 - self.key_prefix_length))
		self.wheel_orders = permutations(range(0,5), 5)
		self.wheel_flips = product([0,5], repeat = 5)
		self.configurations = product(self.key_suffixes, self.wheel_orders, self.wheel_flips)
		# consume(self.configurations, 1000000)

		self.text_analyzer = TextAnalyzer()

	def to_wheel_list(self, order, flips):
		wheel_list = []
		for i in range(0,5):
			wheel_list.append(
				constants.WHEELS[order[i] + flips[i]]
			)

		return wheel_list

	def run(self):
		for i, (key_suffix, wheel_order, wheel_flip) in enumerate(self.configurations):
			key = self.key_prefix + ''.join(key_suffix)
			wheel_list = self.to_wheel_list(wheel_order, wheel_flip)
			machine = EnigmaFive(wheel_list, key)

			decypted_text = machine.decode(self.ciphertext)
			text_rank, words_found = self.text_analyzer.rank(decypted_text)
			if text_rank > self.sensitivity:
				print(f'{i} \t Key: {key} \t Wheels: {wheel_list} \t Decrypted: {decypted_text} \t Rank: {text_rank}, \t {words_found} \n')

def main(ciphertext, key_prefix = "AAA"):
	solver = Solver(ciphertext, key_prefix)
	solver.run()

if __name__ == "__main__":
	main("0081 0061 0172 0165 0108 0174 0161")		