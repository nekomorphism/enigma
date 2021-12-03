using DataStructures

function build_trie(min_length :: Int64) :: Trie{Nothing}
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

	# https://www.asciitable.com/
	for substr in Iterators.partition(text, key_size)
		for (i, char) in enumerate(substr)
			dist = char - '.'
			occurences[dist + 1, i] += 1
		end
	end

	for (i, col) in enumerate(eachcol(occurences))
		results[i] += foldl((acc,x) -> x*(x-1) + acc, col; init = 0)
	end

	results |> sum |> (x -> 1/key_size * 37 * 1/textsize * 1/(textsize - 1) * x)
	results .* 37 .* 1/textsize .* 1/(textsize - 1)
end

function IC_rank(size :: Int64, occurences :: Vector{Int64}, text :: Vector{Int64}) :: Float64
	# occurences = zeros(Float64, 37)

	for char in text
		occurences[char] += 1
	end

	result = foldl((acc,x) -> x*(x-1) + acc, occurences; init = 0)

	result * 37 *  1/size * 1/(size - 1)
end

function rank(accumulator :: Vector{UInt16}, trie :: Trie{Nothing}, text :: String) :: Float64
	# accumulator :: Vector{Int8} = zeros(Int8, size)
	for start_index in 1:size
		for end_index in start_index:size
			substr = SubString(text, start_index, end_index)

			if haskey(trie, substr)
				accumulator[start_index : end_index] = ones(end_index - start_index + 1)
			end

			if subtrie(trie, substr) === nothing
				break
			end
		end
	end

	sum(accumulator) / size
end