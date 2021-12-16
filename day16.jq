def hex_to_bin:
	if . == "0" then [0,0,0,0]
	elif . == "1" then [0,0,0,1]
	elif . == "2" then [0,0,1,0]
	elif . == "3" then [0,0,1,1]
	elif . == "4" then [0,1,0,0]
	elif . == "5" then [0,1,0,1]
	elif . == "6" then [0,1,1,0]
	elif . == "7" then [0,1,1,1]
	elif . == "8" then [1,0,0,0]
	elif . == "9" then [1,0,0,1]
	elif . == "A" then [1,0,1,0]
	elif . == "B" then [1,0,1,1]
	elif . == "C" then [1,1,0,0]
	elif . == "D" then [1,1,0,1]
	elif . == "E" then [1,1,1,0]
	elif . == "F" then [1,1,1,1]
	else halt
	end;
def bin_to_num: reverse | to_entries | map(.value * pow(2; .key)) | add;

def parse_packets($path):
	def _parse_version: setpath($path + ["version"]; .data[.index:.index + 3] | bin_to_num) |
		.index += 3;
	def _parse_type: setpath($path + ["type"]; .data[.index:.index + 3] | bin_to_num) |
		.index += 3;
	def _parse_header: _parse_version | _parse_type;
	def _parse_literal: setpath($path + ["parsing"]; true )|
		until(getpath($path + ["parsing"]) | not;
			setpath($path + ["parsing"]; .data[.index] == 1) |
			setpath($path + ["value"]; getpath($path + ["value"]) + .data[.index + 1:.index + 5]) |
			.index += 5
		) | setpath($path + ["value"]; getpath($path + ["value"]) | bin_to_num) |
		delpaths([$path + ["parsing"]]);
	def _parse_op_length: setpath($path + ["length_type"]; if .data[.index] == 0 then "bits" else "packets" end) |
	# 16 and 12 due to exclusive upper bounds
		setpath($path + ["length"]; .data[.index + 1:.index + if getpath($path + ["length_type"]) == "bits" then 16 else 12 end] | bin_to_num) |
		setpath($path + ["remaining"]; getpath($path + ["length"])) |
		.index += if getpath($path + ["length_type"]) == "bits" then 16 else 12 end;

	_parse_header |
	if getpath($path + ["type"]) == 4 then _parse_literal
	else _parse_op_length | setpath($path + ["children"]; []) |
	until(
		getpath($path + ["remaining"]) == 0
		;
		.index as $index |
		parse_packets($path + ["children", (getpath($path + ["children"]) | length)]) |
		setpath(
			$path + ["remaining"];
			getpath($path + ["remaining"]) - (
				if getpath($path + ["length_type"]) == "bits" then .index - $index
				else 1
				end
			)
		)
	) | delpaths(["length", "length_type", "remaining"] | map($path + [.]))
	end;

		
def parse: 
	{ "data": ., "index": 0, "parsed_packets": {}} | parse_packets(["parsed_packets"]) | .parsed_packets;

def eval:
	def _eval:
		.type as $type |
		if $type == 0 then
			.children | to_entries |
			map(.key as $key | .value | _eval) |
			add
		elif $type == 1 then
			.children | to_entries |
			map(.key as $key | .value | _eval) |
			reduce .[] as $value (1; . * $value)
		elif $type == 2 then
			.children | to_entries |
			map(.key as $key | .value | _eval) |
			min
		elif $type == 3 then
			.children | to_entries |
			map(.key as $key | .value | _eval) |
			max
		elif $type == 4 then
			.value
		elif $type == 5 then
			.children | to_entries |
			map(.key as $key | .value | _eval) |
			if .[0] > .[1] then 1 else 0 end
		elif $type == 6 then
			.children | to_entries |
			map(.key as $key | .value | _eval) |
			if .[0] < .[1] then 1 else 0 end
		elif $type == 7 then
			.children | to_entries |
			map(.key as $key | .value | _eval) |
			if .[0] == .[1] then 1 else 0 end
		else -1 | halt_error
		end;
	_eval;

split("") | map(hex_to_bin) | flatten(1) | parse |
([recurse(if .children != null then .children[] else empty end) | .version] | add),
eval
