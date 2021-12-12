def xy_to_str($x; $y): ($x | tostring) + "," + ($y | tostring);
def str_to_xy: split(",") | map(tonumber);

def grid_to_point_map: . as $grid | { "i": 0, "j": 0, "result": {} } |
	until(.i == ($grid | length)
	;
	.j |= 0 |
	.i as $i |
	until(.j == ($grid[$i] | length) ;
		.j as $j |
		.result[xy_to_str(.i; .j)] |= $grid[$i][$j] |
		.j |= . + 1
		) |
	.i |= . + 1
	) | .result ;
def neighbor_points: str_to_xy | [
	[.[0] - 1, .[1]],
	[.[0], .[1] - 1],
	[.[0] + 1, .[1]],
	[.[0], .[1] + 1]
	];

map(split("") | map(tonumber)) | grid_to_point_map | . as $points |
keys | map(($points[.]) as $data | neighbor_points |
	map($points[xy_to_str(.[0]; .[1])] | numbers | select(. <= $data)) |
	if length == 0 then $data else empty end) |
map(. + 1) | add
