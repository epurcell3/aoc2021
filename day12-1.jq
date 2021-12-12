def paths($edges; $visited):
	if . == "end" or ($edges[.] - $visited | length == 0) then
		[.]
	else
		. as $curr |
		$edges[.] - $visited |
		map([$curr] + paths(
			$edges;
			$visited + [if $curr | test("[a-z]+") then $curr else empty end]))[]
	end;

map(split("-") | { "a": .[0], "b": .[1] }) |
reduce .[] as $edge (
	{}
	;
	.[$edge.a] |= . + [$edge.b] |
	.[$edge.b] |= . + [$edge.a]
) | . as $edges | "start" | [paths($edges; []) | select(last == "end")] | length
