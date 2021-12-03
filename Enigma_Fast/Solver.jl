import Combinatorics
# https://juliamath.github.io/Combinatorics.jl/dev/api/#Combinatorics.permutations-Tuple{Any,%20Integer}

using Base.Threads
using DataStructures

include("./Enigma.jl")
include("./Analyzer.jl")

ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789."
WHEELS = ["V0","V1","V2","V3","V4","V5","V6","V7","V8","V9"]
GEAR_ORDERS = map(Tuple, Combinatorics.permutations((0,1,2,3,4))) # 5!
# KEY_SPACE = Iterators.product(ALPHABET, ALPHABET, ALPHABET, ALPHABET, "BCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.") # 37^5
KEY_SPACE = Iterators.product(ALPHABET, ALPHABET, ALPHABET, ALPHABET, ALPHABET) # 37^5
GEAR_FLIPS = Iterators.product((0,5), (0,5), (0,5), (0,5), (0,5)) # 2^5
CONFIGURATIONS = Iterators.product(GEAR_ORDERS, GEAR_FLIPS, KEY_SPACE)

TRIE = build_trie(2)
CIPHERTEXT = read("./ciphertext.txt", String) |> split |> join

function run()
	c = Threads.Condition()
	busy = false
	for xs in Iterators.partition(CONFIGURATIONS, 1_000_000)
		@threads for (order, flips, key) in collect(xs)
			gear_name_list = order .+ flips
			gear_list = map(name_to_gear, gear_name_list)
			machine = EnigmaMachine(key, gear_list)
			candidate = decode(machine, CIPHERTEXT)

			IC = IC_rank(candidate)

			if 2 < IC < 3.6
				formatted_gear_name_list = foldl((x,xs) -> string(x)*string(xs), gear_name_list)
				formatted_key = foldl((x,xs) -> x*xs, key)
				lock(c)
				try
					while(busy)
						wait(c)
					end

					busy = true
					println("$IC\t$formatted_key\t$formatted_gear_name_list\t$candidate")
				finally
					busy = false
					unlock(c)
				end
			end	


				# word_rank = rank(TRIE, candidate)

				# if word_rank > 0.1
				# 	formatted_gear_name_list = foldl((x,xs) -> string(x)*string(xs), gear_name_list)
				# 	formatted_key = foldl((x,xs) -> x*xs, key)
				# 	lock(c)
				# 	try
				# 		while(busy)
				# 			wait(c)
				# 		end

				# 		busy = true
				# 		println("$word_rank\t$IC\t$formatted_key\t$formatted_gear_name_list\t$candidate")
				# 	finally
				# 		busy = false
				# 		unlock(c)
				# 	end
				# end
		end

		lock(c)
		try
			while(busy)
				wait(c)
			end
			busy = true
			flush(stdout)
		finally
			busy = false
			unlock(c)
		end
	end
end

run()