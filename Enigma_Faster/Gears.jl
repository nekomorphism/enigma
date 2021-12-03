using Profile
const ALPHABET_CHARS = collect("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890.")
const ALPHABET_INDICES = [(c => i) for (i, c) in enumerate(ALPHABET_CHARS)] |> Dict

struct Gear
	sequence :: Vector{Char}
	distances :: Matrix{Int64}
	gear_map :: Vector{Int64}
	inverse_map :: Vector{Int64}

	function Gear(seq)
		sequence :: Vector{Char} = collect(seq) |> Array
		gear_map :: Vector{Int64} = [findfirst(x -> x == c, sequence) for c in ALPHABET_CHARS]
		inverse_map :: Vector{Int64} = [findfirst(x -> x == c, ALPHABET_CHARS) for c in sequence]
		dists = zeros(Int64, 37, 37)
		for i in 1:37
			for j in 1:37
				dists[j, i] = mod(gear_map[i] - gear_map[j], 1:37)
			end
		end

		new(
			sequence,
			dists,
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

function name_to_gear(name :: Int64) :: Gear
	GEARS[name + 1]
end

function shiftchar(
	char :: Int64,
	read_key :: Int64,
	write_key :: Int64,
	read_gear :: Gear,
	write_gear :: Gear,
	direction :: Int64
) :: Int64
	write_gear.distances[write_key,char] |> dist -> read_gear.inverse_map[mod(read_gear.gear_map[read_key] + direction * dist, 1:37)]
end


function encode(size :: Int64, msg :: Vector{Int64}, key :: Vector{Int64}, gears :: Vector{Gear}) :: Vector{Int64}
	encoded_msg :: Vector{Int64} = zeros(Int64, size)
	read_key :: Int64 = 0
	write_key :: Int64 = 0
	for (i, char) in enumerate(msg)
		counter = mod(i, 1:4)

		if mod(i, 1:8) <= 4
			write_key = key[1]
			read_key = key[counter + 1]
		else
			write_key = gears[1].inverse_map[mod(gears[1].gear_map[key[1]] - (-1)^(i) * 27, 1:37)]
			read_key = gears[counter + 1].inverse_map[mod(gears[counter + 1].gear_map[key[counter + 1]] - (-1)^(i) * 33, 1:37)]
		end

		dchar = shiftchar(
			char,
			read_key,
			write_key,
			gears[counter + 1],
			gears[1],
			(-1)^counter
		)

		encoded_msg[i] = dchar
	end

	encoded_msg
end

function encode(msg :: String, key :: String, gears :: Vector{Gear}) :: String
	dstring = encode(
		length(msg),
		msg |> collect |> xs -> map(x -> ALPHABET_INDICES[x], xs),
		key |> collect |> xs -> map(x -> ALPHABET_INDICES[x], xs),
		gears :: Vector{Gear}
	)

	map.(x -> ALPHABET_CHARS[x], dstring) |> join
end

function decode(decoded_msg :: Vector{Int64}, msg :: Vector{Int64}, key :: NTuple{5, Int64}, gears :: Vector{Gear}) :: Vector{Int64}
	# decoded_msg :: Vector{Int64} = zeros(Int64, size)
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

		dchar = shiftchar(
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

function decode(msg :: String, key :: String, gears :: Vector{Gear}) :: String
	dstring = decode(
		length(msg),
		msg |> collect |> xs -> map(x -> ALPHABET_INDICES[x], xs),
		key |> collect |> xs -> map(x -> ALPHABET_INDICES[x], xs),
		gears :: Vector{Gear}
	)

	map.(x -> ALPHABET_CHARS[x], dstring) |> join
end


# m = decode(
# 	"IYL7YUQ7WY2U",
# 	"MAPLE",
# 	[V1, V2, V8, V9, V0]
# )

# m2 = encode(m, "MAPLE", [V1, V2, V8, V9, V0])

# println("$m\t$m2")