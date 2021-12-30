def binstr_to_num: reverse | to_entries | map(.value * pow(2; .key)) | add;

# $point = a point obj, 
# $lit = list of "lit" points
# out enhance index
def enhance_index($point; $lit):
	[ { "x": ($point.x - 1), "y": ($point.y - 1) },
	  { "x": ($point.x    ), "y": ($point.y - 1) },
	  { "x": ($point.x + 1), "y": ($point.y - 1) },
	  { "x": ($point.x - 1), "y": ($point.y    ) },
	  { "x": ($point.x    ), "y": ($point.y    ) },
	  { "x": ($point.x + 1), "y": ($point.y    ) },
	  { "x": ($point.x - 1), "y": ($point.y + 1) },
	  { "x": ($point.x    ), "y": ($point.y + 1) },
	  { "x": ($point.x + 1), "y": ($point.y + 1) }
	] | map([.] | inside($lit) | if . then 1 else 0 end) | binstr_to_num;

def step:
	(.step | debug) as $step |
	(.lit_points | map(.x) | min - if $step % 2 == 0 then 3 else -1 end) as $x_min |
	(.lit_points | map(.x) | max + if $step % 2 == 0 then 3 else -1 end) as $x_max |
	(.lit_points | map(.y) | min - if $step % 2 == 0 then 3 else -1 end) as $y_min |
	(.lit_points | map(.y) | max + if $step % 2 == 0 then 3 else -1 end) as $y_max |
	.new_lit_points = [] |
	.j = $y_min |
	until(.j > $y_max;
		.i = $x_min |
		until(.i > $x_max;
			if .enhance[enhance_index({ "x": .i, "y": .j }; .lit_points)] == "#" then
				.new_lit_points += [{ "x": .i, "y": .j }]
			else . end |
			.i += 1
		) |
		.j += 1
	) |
	.lit_points = .new_lit_points |
	del(.new_lit_points) |
	.step += 1;

{
	"enhance": (.[0] | split("")),
	"lit_points": (reduce .[2:][] as $line (
		{ "row": 0, "points": [] };
		.row as $row |
		.points += ($line | split("") | to_entries |
			map(select(.value == "#") | { "x": .key, "y": $row })) |
		.row += 1
	) | .points),
	"step": 0
} |
until(.step == 2; step), until(.step == 50; step) | .lit_points | length

