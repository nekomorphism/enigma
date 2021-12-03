from word_trie import WordTrie

class TextAnalyzer:
	def __init__(self):
		self.trie = WordTrie()


	def rank(self, text):
		text_length = len(text)
		accumulator = [0] * text_length
		words_found = []

		for start_index in range(len(text)+1):
			for end_index in range(start_index+1, len(text)+1):
				substr = text[start_index : end_index]

				if self.trie.has_key(substr):
					accumulator[start_index : end_index] = [1] * (end_index-start_index)
					words_found.append(substr)

				if not self.trie.has_subtrie(substr):
					break


		score = sum(accumulator)/text_length
		return (score, words_found)



def main():
	ta = TextAnalyzer()
	ta.rank("XXWITHEZQOF")
	pass

if __name__ == "__main__":
	main()
	