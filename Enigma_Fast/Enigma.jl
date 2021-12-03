include("./Gears.jl")

struct EnigmaMachine
	key :: NTuple{5, Char}
	gear_list :: NTuple{5, Gear}
	function EnigmaMachine(key, gear_list)
		new(key,gear_list)
	end
end

function encode(machine :: EnigmaMachine, msg :: String) :: String
	encoded_msg = ""
	reference_key = machine.key[begin]
	reference_gear = machine.gear_list[begin]

	for (i, char) in enumerate(msg)
		orientation = (-1)^i
		offset = mod(div(i-1,4), 2) == 1 ? true : false
		dist = distance(
			reference_gear, 
			char, 
			reference_key,
			offset ? 33 : 0
		)

		encoded_char = apply_rotation(machine.gear_list[mod(i-1,4) + 2],
			machine.key[mod(i-1,4) + 2],
			dist*orientation, 
			offset ? 27 : 0
		)

		encoded_msg = encoded_msg * encoded_char
	end
	encoded_msg
end


function decode(machine :: EnigmaMachine, msg :: String) :: String
	decoded_msg = ""
	reference_key = machine.key[begin]
	reference_gear = machine.gear_list[begin]

	for (i, char) in enumerate(msg)
		orientation = (-1)^i
		offset = mod(div(i-1,4), 2) == 1 ? true : false

		dist = distance(
			machine.gear_list[mod(i-1,4) + 2], 
			char, 
			machine.key[mod(i-1,4) + 2],
			offset ? 27 : 0
		)

		decoded_char = apply_rotation(
			reference_gear,
			reference_key,
			dist*orientation, 
			offset ? 33 : 0
		)

		decoded_msg = decoded_msg * decoded_char
	end
	decoded_msg
end



# machine = EnigmaMachine(('M','A','P','L','E'), (V1, V2, V8, V9, V0))

# println(encode(machine, "COMEBACKSOON"))
