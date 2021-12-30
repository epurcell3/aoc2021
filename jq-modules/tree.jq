def find_leaf_nodes:
	. as $tree |
	[paths | select(. as $path | $tree | getpath($path) | scalars)];

def find_leaf_only_parents:
	. as $tree |
	[paths | select(. as $path | $tree | 
		(try getpath($path + [0]) catch null | type | . != "array" and . != "null")
		and (try getpath($path + [1]) catch null | type | . != "array" and . != "null"))];

def parent_path: .[0:(length - 1)];

def find_neighboring_leaves($path):
	find_leaf_nodes |
	[if indices([$path + [0]])[0] - 1 >= 0 then .[indices([$path + [0]])[0] - 1] else null end, # stop backward indexing
	 .[indices([$path + [1]])[0] + 1]
	];
