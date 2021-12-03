import pygtrie
# https://pygtrie.readthedocs.io/en/latest/index.html

import io
# https://docs.python.org/3/library/io.html

class WordTrie:
	def __init__(self, path = "./1-1000.txt", min_length = 3):
		self.trie = pygtrie.CharTrie()

		with open(path) as file:
			for line in file:
				cleaned_line = WordTrie.sanitize(line)

				if len(cleaned_line) >= min_length:
					self.trie[cleaned_line] = True


		with open("./keywords.txt") as file:
			for line in file:
				cleaned_line = WordTrie.sanitize(line)

				if len(cleaned_line) >= min_length:
					self.trie[cleaned_line] = True

	@classmethod
	def sanitize(cls, word):
		return word.strip().upper()

	def has_subtrie(self, word):
		cleaned_word = WordTrie.sanitize(word)
		return self.trie.has_subtrie(cleaned_word)

	def has_key(self, word):
		cleaned_word = WordTrie.sanitize(word)
		return self.trie.has_key(cleaned_word)

def main():
	t = WordTrie()
	print(t.has_key("col"), t.has_key("ARROW"))

	pass

if __name__ == "__main__":
	main()
