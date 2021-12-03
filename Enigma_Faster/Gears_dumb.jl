using Profile
const ALPHABET_CHARS = Tuple("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.")
const ALPHABET_INDICES = [(c => i) for (i, c) in enumerate(ALPHABET_CHARS)] |> Dict

struct Gear
	sequence :: NTuple{37, Char}
	distances :: NTuple{37, NTuple{37, Int64}}
	gear_map :: NTuple{37, Int64}
	inverse_map :: NTuple{37, Int64}

	function Gear(seq)
		sequence :: NTuple{37, Char} = seq |> Tuple
		gear_map :: NTuple{37, Int64} = [findfirst(x -> x == c, sequence) for c in ALPHABET_CHARS] |> Tuple
		inverse_map :: NTuple{37, Int64} = [findfirst(x -> x == c, ALPHABET_CHARS) for c in sequence] |> Tuple
		dists = zeros(Int64, 37, 37)
		for i in 1:37
			for j in 1:37
				dists[i, j] = mod(gear_map[i] - gear_map[j], 1:37)
			end
		end

		new(
			sequence,
			dists |> eachcol |> Tuple |> x -> Tuple.(x),
			gear_map,
			inverse_map
		)
	end
end

const V0 = Gear("A1YZD8BX2VLF7IOK0TW3EUMC9SRP4GJN6H5Q.")
const V1 = Gear("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.")
const V2 = Gear("ACB1ED2GF3IH4KJ5ML6ON7QP8SR9UT0WV.YXZ")
const V3 = Gear("AZY.XWVU09TSRQ87PONM65LKJI43HGFE21DCB")
const V4 = Gear("AZYXW.VU0TS1RQ2PO3NM4LK5JI6HG7FE8DC9B")
const V5 = Gear("ADCB12EHGF34ILKJ56MPNO78QTSR90UXWV.ZY")
const V6 = Gear("ABG6IP1VK3H0RD.4MY7NZE2OC9TJLXU5FWS8Q")
const V7 = Gear("AIT3DNF6MHS5GQK7PVWY8Z.1RX0B2LCO9JUE4")
const V8 = Gear("A3QN4U.T5LX7CSBRH8ZJO6VP2YEWG9IK1MD0F")
const V9 = Gear("AH.BGQ12PLFTMJ34UESDVW56KCZ78YNO90RIX")

const GEARS = (V0,V1,V2,V3,V4,V5,V6,V7,V8,V9)

function distance(gear :: Gear, a :: Char, b :: Char) :: Int64
	(gear.distances[ALPHABET_INDICES[a]][ALPHABET_INDICES[b]])
end

function name_to_gear(name)
	GEARS[name]
end

function decode_char(
	char :: Int64,
	read_key :: Int64,
	write_key :: Int64,
	read_gear :: Gear,
	write_gear :: Gear,
	direction :: Int64
) :: Int64
	write_gear.distances[write_key][char] |> dist -> read_gear.inverse_map[mod(read_key + direction * dist, 1:37)]
end

function decode_msg(buffer, msg, key :: NTuple{5, Int64}, gears :: NTuple{5, Gear}) :: Vector{Int64}
	decoded_msg :: Vector{Int64} = zeros(Int64, 12)
	# decoded_msg = buffer
	read_key :: Int64 = 0
	write_key :: Int64 = 0
	for (i, char) in enumerate(msg)
		counter = mod(i, 1:4)

		if mod(i, 1:8) <= 4
			read_key = key[1]
			write_key = key[counter + 1]
		else
			read_key = gears[1].inverse_map[mod(gears[1].gear_map[key[1]] - (-1)^(i) * 27, 1:37)]
			write_key = gears[counter + 1].inverse_map[mod(gears[counter + 1].gear_map[key[counter + 1]] - (-1)^(i) * 33, 1:37)]
		end

		dchar = decode_char(
			char,
			read_key,
			write_key,
			gears[1],
			gears[counter + 1],
			(-1)^counter
		)

		decoded_msg[i] = dchar
	end

	decoded_msg
end

# function decode(msg, key, gears)
# 	for (i,char) in msg
# 		dist = gears[mod(i - 1, 4) + 1].distance[key[mod(i-1, 4) + 1], i]
# 	end
# end

const msg = "IYL7YUQ7WY2U" |> Tuple |> xs -> map(x -> ALPHABET_INDICES[x], xs)
const key = "MAPLE" |> Tuple |> xs -> map(x -> ALPHABET_INDICES[x], xs)

@timev begin
	@GC.preserve buff = zeros(Int64, 12)
	for i in 1:500_000
		decode_msg(buff,
			msg,
			key,
			(V1, V2, V8, V9, V0)
		) 
	end	
end
# @timev for i in 1:1_000_000 m = decode_msg(zeros(Int64, 12),
# 	msg,
# 	key,
# 	(V1, V2, V8, V9, V0)
# ) 
# end
# map.(x -> ALPHABET_CHARS[x], m) |> println