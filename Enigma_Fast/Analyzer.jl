using DataStructures

function build_trie(min_length :: Int64)
	word_list :: Vector{String} = []

	# https://github.com/dolph/dictionary
	for word in eachline("./big_dictionary.txt")
		if length(word) < min_length
			continue
		else
			push!(word_list, String(Base.Unicode.uppercase(word)))
		end
	end	

	for word in eachline("./1-1000.txt")
		if length(word) < min_length
			continue
		else
			push!(word_list, String(Base.Unicode.uppercase(word)))
		end
	end

	for word in eachline("./keywords.txt")
		if length(word) < min_length
			continue
		else
			push!(word_list, String(Base.Unicode.uppercase(word)))
		end
	end

	Trie(word_list)
end

# https://en.wikipedia.org/wiki/Index_of_coincidence
# https://crypto.stackexchange.com/questions/333/how-does-the-index-of-coincidence-work-in-the-kasiki-test
function IC_analyze(text :: String, key_size)
	textsize = length(text)/key_size
	occurences = zeros(45,key_size)
	# results = zeros(0)
	results = zeros(key_size)

	# julia orders chars ./0123456789____something____ABCDEFGHIJKLMNOPQRSTUVWXYZ where '.'-'.' = 0 and 'z'-'.' = 44
	# for (i, char) in enumerate(text)
	# 	dist = char - 'A'
	# 	column = mod(i-1, 8)

	# 	occurences[dist + 1, mod(i-1, 8)] += 1
	# end
	# https://www.asciitable.com/
	for substr in Iterators.partition(text, key_size)
		for (i, char) in enumerate(substr)
			dist = char - '.'
			occurences[dist + 1, i] += 1
		end
	end
	# for (i, char) in enumerate(text)
	# 	dist = char - '.'
	# 	column = mod(i-1, 8) + 1
	# 	occurences[dist + 1, column] += 1
	# end

	for (i, col) in enumerate(eachcol(occurences))
		results[i] += foldl((acc,x) -> x*(x-1) + acc, col; init = 0)
	end
	# println(occurences)
	# println(results .* (1/7 * 1/6))

	# for (i, n) in enumerate(occurences)
	# 	# row = mod(i-1, 44) + 1
	# 	column = mod(div(i - 1, 45), 8) + 1

	# 	println(n)
	# 	results[column] += n*(n-1)
	# 	# for xs in 
	# 	# results[column] = 37 * 1/textsize * 1/(textsize - 1) * reduce((x,y) -> x*(x-1) + y*(y-1), xs)
	# end

	results |> sum |> (x -> 1/key_size * 37 * 1/textsize * 1/(textsize - 1) * x)
	results .* 37 .* 1/textsize .* 1/(textsize - 1)
end

function IC_rank(text :: String)
	textsize = length(text)
	occurences = zeros(45)
	result :: Float64 = 0.0

	for char in text
		dist = char - '.'
		occurences[dist + 1] += 1
	end

	result = foldl((acc,x) -> x*(x-1) + acc, occurences; init = 0)

	result * 37*  1/textsize * 1/(textsize - 1)
end

function rank(trie, text)
	accumulator = zeros(length(text))

	for start_index in 1:length(text)
		for end_index in start_index:length(text)

			substr = text[start_index : end_index]

			if haskey(trie, substr)
				accumulator[start_index : end_index] = ones(end_index - start_index + 1)
			end

			if subtrie(trie, substr) === nothing
				break
			end
			
		end
	end

	sum(accumulator) / length(text)
end


# println(IC_rank("IMACATANDTHENEXTKEYISFWE936WINWINXNEXTTOBLUEALPHAMEOW.983347.ZZZDHIU"))
# println(IC_rank("THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG"))


# "ALQQ NXEN Z4QD SBQP ZS4N ZNUV OXIL
# 56ID N7FX ALGD N44F PMUV ALQT Z7XX
# 8Z6J Z7ZV 8A8N AN4G AXJL BJFL 64QQ
# B9QJ 67XI 61FV 85VG FBQG OXZL 0NXL
# R0KE HWK1 R.B" |> split |> join |> IC_rank |> println


# CIPHERTEXT = read("./ciphertext.txt", String) |> split |> join
# CIPHERTEXT |> x-> IC_analyze(x, 5) |> println
# map(x -> IC_analyze(CIPHERTEXT, x), 1:10) |> println
# CIPHERTEXT |> split |> join |> IC_analyze |> println
# println(score)
