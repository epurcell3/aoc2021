def xy_to_str($x; $y): ($x | tostring) + "," + ($y | tostring);
def str_to_xy: split(",") | map(tonumber);

def grid_to_point_map: . as $grid | { "i": 0, "j": 0, "result": {} } |
	until(.i == ($grid | length)
	;
	.j |= 0 |
	.i as $i |
	until(.j == ($grid[$i] | length) ;
		.j as $j |
		.result[xy_to_str(.j; .i)] |= $grid[$i][$j] |
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
keys | map(. as $point | ($points[.]) as $data | neighbor_points |
	map($points[xy_to_str(.[0]; .[1])] | numbers | select(. <= $data)) |
	if length == 0 then $point else empty end) |
map({
	"basin": [.],
	"considered_points": . | neighbor_points | map(xy_to_str(.[0]; .[1]) | select($points[.] | numbers | . != 9))
} | until(
	.considered_points | length == 0
	;
	.basin = .basin + .considered_points |
	.basin as $basin |
	.new_points = (.considered_points |
		map(neighbor_points | map(xy_to_str(.[0]; .[1]) |
			select(($points[.] | numbers | . != 9) and ([.] | inside($basin) | not)))
		) | flatten | unique) |
	.considered_points = .new_points
) | .basin | length) |
sort | reverse | [limit(3; .[])] |
reduce .[] as $basin_size(1; . * $basin_size)
