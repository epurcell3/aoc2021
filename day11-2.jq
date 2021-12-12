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
	[.[0] - 1, .[1] - 1],
	[.[0]    , .[1] - 1],
	[.[0] + 1, .[1] - 1],
	[.[0] - 1, .[1]    ],
	[.[0] + 1, .[1]    ],
	[.[0] - 1, .[1] + 1],
	[.[0]    , .[1] + 1],
	[.[0] + 1, .[1] + 1]
	] | map(xy_to_str(.[0]; .[1]));

map(split("") | map(tonumber)) | grid_to_point_map |
# Hoping it isn't too many iterations (it wasn't for me)
[foreach range(1; 1000) as $iter (
	{ "grid": ., "flashes": 0, "flashing": [] }
	;
	.step = $iter |
	.grid as $old_grid | 
	.updates = ($old_grid | with_entries(.value |= 1)) |
	.new_flashing = (.updates | to_entries | map(select($old_grid[.key] + .value == 10) | .key)) |
	.flashing = [] |
	until(
		.new_flashing | length == 0
		;
		.new_flashing as $new_flashing |
		.flashing |= . + $new_flashing |
		.updates[.new_flashing | map(neighbor_points) | flatten | map(select($old_grid[.]))[]] |= . + 1 |
		.new_flashing = ((.updates | to_entries | map(select($old_grid[.key] + .value >= 10) | .key)) - .flashing)

	) |
	.flashing as $flashing |
	.flashes |= . + ($flashing | length) |
	.updates as $updates |
	.grid |= with_entries(.prospective_value = .value + $updates[.key] | if .prospective_value >= 10 then .value = 0 else .value = .prospective_value end)
)] | map(select(.flashing | length == 100)) | first | .step
