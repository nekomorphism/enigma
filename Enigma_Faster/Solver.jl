import Combinatorics
# https://juliamath.github.io/Combinatorics.jl/dev/api/#Combinatorics.permutations-Tuple{Any,%20Integer}

using Base.Threads
using DataStructures
using Dates
using Profile
using Base.GC
using FLoops

include("./Analyzer.jl")
include("./Gears.jl")

const GEAR_ORDERS = Combinatorics.permutations((0,1,2,3,4)) |> collect
const GEAR_FLIPS = Iterators.product((0,5), (0,5), (0,5), (0,5), (0,5)) |> x -> collect.(x)
const CONFIGURATIONS = Iterators.product(GEAR_ORDERS, GEAR_FLIPS) |> collect
const KEY_SPACE = Iterators.product(1:37, 1:37, 1:37, 1:37, 1:37)

const TRIE = build_trie(3)
const CIPHERTEXT = 
	read("./ciphertext_top_2_lines.txt", String) |>
	split |> 
	join |>
	collect |>
	xs -> map(x->ALPHABET_INDICES[x], xs)
const size = length(CIPHERTEXT)


function run()
	c = Threads.Condition()
	busy = false
	for keys in Iterators.partition(Iterators.take(KEY_SPACE, 12_000), 1_000)
		@threads for key in keys
			# Permanent
			candidate_list :: Vector{String} = []

			# Reused
			gear_name_list :: Vector{Int64} = Array{Int64, 1}(undef, 5)
			gear_list :: Vector{Gear} = Array{Gear, 1}(undef, 5)
			rank_buffer = Array{UInt16, 1}(undef, size)
			IC_rank_buffer = Array{Int64, 1}(undef, 37)
			decode_buffer = Array{Int64, 1}(undef, size)
			candidate = Array{Int64, 1}(undef, size)
			IC :: Float64 = 0.0

			for (order, flips) in CONFIGURATIONS
				gear_name_list = order.+ flips |> collect
				gear_list = map(name_to_gear, gear_name_list) |> collect

				decode_buffer = zeros(Int64, size)
				IC_rank_buffer = zeros(Int64, 37)

				candidate = decode(decode_buffer, CIPHERTEXT, key, gear_list) 
				IC = IC_rank(size, IC_rank_buffer, candidate)

				if 1.5 < IC < 2.4
					candidate_str = candidate |> x -> map(y -> ALPHABET_CHARS[y], x) |> join

					rank_buffer = zeros(UInt16, size)
					word_rank = rank(rank_buffer, TRIE, candidate_str)

					if word_rank > 0.4
						fwr = word_rank |> x -> round(x, digits = 5) |> x -> rpad(x, 7, "0")
						fic = IC |> x -> round(x, digits = 5) |> x -> rpad(x, 7, "0")
						fg = gear_name_list |> join
						fk = map.(x->ALPHABET_CHARS[x], key) |> join
						entry = (fwr, fic, fk, fg, candidate_str) |> x -> join(x, '\t')
						push!(
							candidate_list,
							entry
						)
					end
				end
			end
			if !isempty(candidate_list)
				results :: String = join(candidate_list, '\n')

				lock(c)
				try
					while(busy)
						wait(c)
					end

					busy = true
					println(results)
					flush(stdout)
				finally
					busy = false
					unlock(c)
				end
			end
		end
	end
end

@timev run()