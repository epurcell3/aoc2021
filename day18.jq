def find_leaf_nodes:
	. as $tree |
	[paths | select(. as $path | $tree | getpath($path) | scalars)];

def find_leaf_only_parents:
	. as $tree |
	[paths | select(. as $path | $tree | 
		(try getpath($path + [0]) catch null | type | . != "array" and . != "null")
		and (try getpath($path + [1]) catch null | type | . != "array" and . != "null"))];

def parent_path: .[0:(length - 1)];

def find_first_action:
	. as $snailnum |
	find_leaf_nodes |
	map(. as $path | 
	{
		"action": (if . | length == 5 then "explode"
		          elif $snailnum | getpath($path) >= 10 then "split"
			  else "none" end),
		"path": (if . | length == 5 then parent_path else . end)
	} | select (.action != "none")) | sort_by(.action) | first;

def find_neighboring_leaves($path):
	find_leaf_nodes |
	[if indices([$path + [0]])[0] - 1 >= 0 then .[indices([$path + [0]])[0] - 1] else null end, # stop backward indexing
	 .[indices([$path + [1]])[0] + 1]
	];

def snail_add:
	reduce .[1:][] as $to_add (
		.[0]
		;
		{ "snailnum": [., $to_add] } |
		.action = (.snailnum | find_first_action) |
		until(.action == null
			;
			if .action.action == "explode" then
				.action.path as $path |
				.neighbors = (.snailnum | find_neighboring_leaves($path)) |
				if .neighbors[0] != null then
					.neighbors[0] as $neighbor |
					(.snailnum | getpath($path + [0])) as $left_num |
					.snailnum |= setpath($neighbor; getpath($neighbor) + $left_num) 
				else .
				end |
				if .neighbors[1] != null then
					.neighbors[1] as $neighbor |
					(.snailnum | getpath($path + [1])) as $right_num |
					.snailnum |= setpath($neighbor; getpath($neighbor) + $right_num) 
				else .
				end |
				.snailnum |= setpath($path; 0) |
				del(.neighbors)
			elif .action.action == "split" then
				.action.path as $path |
				.snailnum |= setpath($path; [
					(getpath($path) / 2 | floor),
					(getpath($path) / 2 | ceil)
				])
			else . end |
			.action = (.snailnum | find_first_action)
		)
		| .snailnum
	);

def snail_magnitude:
	until([paths] | length == 2;
		{ "snailnum": ., "parents": find_leaf_only_parents } |
		until(.parents | length == 0;
			(.parents | first) as $parent |
			.snailnum |= setpath($parent; getpath($parent + [0]) * 3 + getpath($parent + [1]) * 2) |
			.parents |= .[1:]
		) |
		.snailnum
	) | .[0] * 3 + .[1] * 2;

def snail_homework: snail_add | snail_magnitude;

def cross_link: . as $input | [range(0;length) as $path | map([., ($input | getpath([$path]))] | select(.[0] != .[1]))] | flatten(1);

snail_homework,
(cross_link | map(snail_homework | debug) | max)
