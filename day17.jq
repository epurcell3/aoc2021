# target area: x=70..125, y=-159..-121

def y_in_range($bounds): (. + 1) * -1 | # Invert and dec, we don't need to go up we'll just come back to 0
	{ "vy": ., "py": 0 } |
	until(.py <= $bounds[1]; .vy as $vy | .py += $vy | .vy -= 1) |
	.py >= $bounds[0];

def shot_hits($x_bounds; $y_bounds):
	{ "vx": .x, "px": 0, "vy": .y, "py": 0 } |
	until(((.px >= $x_bounds[0] or .vx == 0) and .py <= $y_bounds[1]) or .px > $x_bounds[1] or .py < $y_bounds[0];
		.vx as $vx | .px += $vx | .vx |= if . > 0 then . - 1 else . end |
		.vy as $vy | .py += $vy | .vy -= 1) |
	.px >= $x_bounds[0] and .px <= $x_bounds[1] and .py >= $y_bounds[0] and .py <= $y_bounds[1];



split(": ")[1] | split(", ") | 
[.[0] | split("..") | (.[0] | split("=")[1] | tonumber), (.[1] | tonumber)] as $x_bounds |
[.[1] | split("..") | (.[0] | split("=")[1] | tonumber), (.[1] | tonumber)] as $y_bounds |
([range($y_bounds[1] * -1; $y_bounds[0] * -1)] |
	map(select(y_in_range($y_bounds))) | last | . * (. + 1) / 2),
(
	[range($y_bounds[0]; $y_bounds[0] * -1)] | map(
		{ "x": range(2 * $x_bounds[0] | sqrt | floor; $x_bounds[1] + 1), "y": . } |
		select(shot_hits($x_bounds; $y_bounds))
		| debug
	) | length
)
