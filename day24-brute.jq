def as_digits: tostring | split("") | map(tonumber);
def as_number: join("") | tonumber;
def possible_model_nums: range(99999999999999; 11111111111111; -1) |
	as_digits | select(any(. == 0) | not);

map(split(" ") | { "opcode": .[0], "reg_a": .[1], "b": .[2] } |
	.b as $b |
	if .opcode != "inp" and (.b | test("[0-9]+")) then .const_b = (.b | tonumber) else .reg_b = $b end |
	del(.b)) |
. as $program |
limit(1;
	foreach (39494195799979 | as_digits | debug) as $model_digits (.;
		reduce $program[] as $instruction (
			{ "w": 0, "x": 0, "y": 0, "z": 0, "inp_index": 0 };
			if $instruction.opcode == "inp" then
				.[$instruction.reg_a] = $model_digits[.inp_index] |
				.inp_index += 1
			elif $instruction.opcode == "add" then
				if $instruction | has("const_b") then
					.[$instruction.reg_a] += $instruction.const_b
				else
					.[$instruction.reg_a] = .[$instruction.reg_a] + .[$instruction.reg_b]
				end
			elif $instruction.opcode == "mul" then
				if $instruction | has("const_b") then
					.[$instruction.reg_a] *= $instruction.const_b
				else
					.[$instruction.reg_a] = .[$instruction.reg_a] * .[$instruction.reg_b]
				end
			elif $instruction.opcode == "div" then
				if $instruction | has("const_b") then
					.[$instruction.reg_a] /= $instruction.const_b
				else
					.[$instruction.reg_a] = .[$instruction.reg_a] / .[$instruction.reg_b]
				end |
				.[$instruction.reg_a] |= floor
			elif $instruction.opcode == "mod" then
				if $instruction | has("const_b") then
					.[$instruction.reg_a] %= $instruction.const_b
				else
					.[$instruction.reg_a] = .[$instruction.reg_a] % .[$instruction.reg_b]
				end
			elif $instruction.opcode == "eql" then
				if $instruction | has("const_b") then
					.[$instruction.reg_a] =
					if .[$instruction.reg_a] == $instruction.const_b then 1
					else 0 end
				else
					.[$instruction.reg_a] = 
					if .[$instruction.reg_a] == .[$instruction.reg_b] then 1
					else 0 end
				end
			else error("Unknown opcode!") end
		) |
		if .z  == 0 then $model_digits | as_number else empty end
	)
)
