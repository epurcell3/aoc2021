def possible_edges($edges; $visited):
	if $visited | with_entries(select(.value == 2)) | length == 0 then
		$edges[.] - ["start"]
	else
		$edges[.] - ($visited | keys)
	end;

def paths($edges; $visited):
	if . == "end" or (possible_edges($edges; $visited) | length == 0) then
		[.]
	else
		. as $curr |
		($visited | if $curr | test("[a-z]+") then .[$curr] |= . + 1 else . end) as $new_visited |
		possible_edges($edges; $new_visited) |
		map([$curr] + paths(
			$edges;
			$new_visited
		))[]
	end;

map(split("-") | { "a": .[0], "b": .[1] }) |
reduce .[] as $edge (
	{}
	;
	.[$edge.a] |= . + [$edge.b] |
	.[$edge.b] |= . + [$edge.a]
) | . as $edges | "start" | [paths($edges; {}) | select(last == "end")] | length
