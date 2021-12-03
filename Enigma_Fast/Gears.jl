struct Gear
	index_to_char :: Dict{Int, Char}
	char_to_index :: Dict{Char, Int}
end

function Gear(data)
	index_to_char = Dict(enumerate(data))
	char_to_index = begin
		Dict([char => i for (i, char) in enumerate(data)])
	end

	Gear(index_to_char, char_to_index)
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

function name_to_gear(name)
	if name == 0
		V0 
	elseif name == 1
		V1
	elseif name == 2
		V2
	elseif name == 3
		V3
	elseif name == 4
		V4
	elseif name == 5
		V5
	elseif name == 6
		V6
	elseif name == 7
		V7
	elseif name == 8
		V8
	elseif name == 9
		V9
	else
		error("Invalid gear name $name")
	end
end

function distance(gear :: Gear, c1 :: Char, c2 :: Char, offset :: Int64)
	c1_loc = mod(gear.char_to_index[c1] - 1, 37)
	c2_loc = mod(gear.char_to_index[c2] - 1 + offset, 37)

	mod(c1_loc - c2_loc, 37)
end

function apply_rotation(gear :: Gear, char :: Char, n :: Int64, offset :: Int64)
	loc = mod(gear.char_to_index[char] - 1 + offset, 37)
	new_loc = mod(loc + n, 37)

	gear.index_to_char[new_loc + 1]
end
