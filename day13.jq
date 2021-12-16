def str_to_point: split(",") | { "x": .[0] | tonumber, "y": .[1] | tonumber };
def fold($fold):
	def _fold_point_x($point): if .x <= $point then . else .x |= . - 2*(. - $point) end;
	def _fold_point_y($point): if .y <= $point then . else .y |= . - 2*(. - $point) end;
	if $fold.axis == "x" then
		map(_fold_point_x($fold.point))
	else
		map(_fold_point_y($fold.point))
	end;
def print_grid:
	def _bounds: reduce .[] as $point (
		{"tl": .[0], "br": .[0]}
		;
		if $point.x < .tl.x then .tl.x |= $point.x
		elif $point.x > .br.x then .br.x |= $point.x
		else .
		end |
		if $point.y < .tl.y then .tl.y |= $point.y
		elif $point.y > .br.y then .br.y |= $point.y
		else .
		end
	);
	. as $points |
	{ "bounds": _bounds, "string": ""} |
	.point = .bounds.tl |
	until(
		.point.y > .bounds.br.y
		;
		.point.x = .bounds.tl.x |
		until(
			.point.x > .bounds.br.x
			;
			.point as $point |
			.string |= . + if [$point] | inside($points) then "#" else "." end |
			.point.x |= . + 1
		) |
		.string |= . + "\n" |
		.point.y |= . + 1
	) | .string;

reduce .[] as $line (
	{ "points": [], "folds": [] }
	;
	if $line | startswith("fold") then
		.folds |= . + [$line[11:] | split("=") | { "axis": .[0], "point": .[1] | tonumber }]
	elif $line != "" then
		.points |= . + [$line | str_to_point]
	else
		.
	end
) | [foreach .folds[] as $fold (
	.points
	;
	fold($fold) | unique
)] | (first | length), (last | print_grid)
