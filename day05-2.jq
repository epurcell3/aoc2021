def is_horizontal: if .[0][1] == .[1][1] then true else false end;
def is_vertical: if .[0][0] == .[1][0] then true else false end;
def is_top_left_diagonal: if .[0][0] < .[1][0] and .[0][1] < .[1][1] then true else false end;
def to_point: { "x": .[0], "y": .[1] };
def point_to_array: [.x, .y];

def __in_bounds_inclusive($bounds): . >= $bounds[0] and . <= $bounds[1];
def __is_range_overlap($b1; $b2): $b1 + $b2 | sort | (. != $b1 + $b2 and . != $b2 + $b1) or .[1] == .[2];

## Horizontal/Horizontal intersections
def __hor_hor_intersections($r1; $r2): if $r1.y == $r2.y and __is_range_overlap($r1.x_range; $r2.x_range) then [$r1.x_range[0], $r1.x_range[1], $r2.x_range[0], $r2.x_range[1]] | sort | [range(.[1]; .[2] + 1) | [., $r1.y]] else [] end;
## Vertical/Vertical intersections
def __ver_ver_intersections($r1; $r2): if $r1.x == $r2.x and __is_range_overlap($r1.y_range; $r2.y_range) then [$r1.y_range[0], $r1.y_range[1], $r2.y_range[0], $r2.y_range[1]] | sort | [range(.[1]; .[2] + 1) | [$r1.x, .]] else [] end;
## Horizontal/Vertical intersections
def __hor_ver_intersections($r1; $r2): if ($r2.x | __in_bounds_inclusive($r1.x_range)) and ($r1.y | __in_bounds_inclusive($r2.y_range)) then [[$r2.x, $r1.y]] else [] end;

## Top Left Diag helpers
def __y_point_in_tld($tld): if __in_bounds_inclusive([$tld.top_left.y, $tld.bottom_right.y]) then
	[$tld.top_left.x + (. - $tld.top_left.y), .] | to_point
	else null end;

def __x_point_in_tld($tld): if __in_bounds_inclusive([$tld.top_left.x, $tld.bottom_right.x]) then
	[., $tld.top_left.y + (. - $tld.top_left.x)] | to_point
	else null end;

def __tld_points_between($a1; $a2): { "p": $a1, points: [] }  |
	until(.p == [$a2[0] + 1, $a2[1] + 1];
	.p as $p |
	.points |= . + [$p] |
	.p |= [.[0] + 1, .[1] + 1]) |
	.points;

## Top Left Diag/Horizontal intersections
def __tld_hor_intersections($r1; $r2): $r2.y | __y_point_in_tld($r1) | if . and (.x | __in_bounds_inclusive($r2.x_range)) then [. | point_to_array] else [] end;
## Top Left Diag/Vertical intersections
def __tld_ver_intersections($r1; $r2): $r2.x | __x_point_in_tld($r1) | if . and (.y | __in_bounds_inclusive($r2.y_range)) then [. | point_to_array] else [] end;
## Top Left Diag/Top Left Diag intersections
def __tld_tld_intersections($r1; $r2):
	if ($r2.top_left.x | __x_point_in_tld($r1) == $r2.top_left) or ($r1.top_left.x | __x_point_in_tld($r2) == $r1.top_left) then 
		[$r1.top_left, $r1.bottom_right, $r2.top_left, $r2.bottom_right] |
		map(point_to_array) | sort | __tld_points_between(.[1]; .[2])
	else [] end;

## Botom Left Diag helpers
def __y_point_in_bld($bld): if __in_bounds_inclusive([$bld.top_right.y, $bld.bottom_left.y]) then
	[$bld.bottom_left.x + ($bld.bottom_left.y - .), .] | to_point
	else null end;

def __x_point_in_bld($bld): if __in_bounds_inclusive([$bld.bottom_left.x, $bld.top_right.x]) then
	[., $bld.top_right.y + ($bld.top_right.x - .)] | to_point
	else null end;

def __bld_points_between($a1; $a2): { "p": $a1, points: [] }  |
	until(.p == [$a2[0] + 1, $a2[1] - 1];
	.p as $p |
	.points |= . + [$p] |
	.p |= [.[0] + 1, .[1] - 1]) |
	.points;
## Bottom Left Diag/Horizontal intersections
def __bld_hor_intersections($r1; $r2): $r2.y | __y_point_in_bld($r1) | if . and (.x | __in_bounds_inclusive($r2.x_range)) then [. | point_to_array] else [] end;
## Bottom Left Diag/Vertical intersections
def __bld_ver_intersections($r1; $r2): $r2.x | __x_point_in_bld($r1) | if . and (.y | __in_bounds_inclusive($r2.y_range)) then [. | point_to_array] else [] end;
## Bttom Left Diag/Botto Left Diag intersections
def __bld_bld_intersections($r1; $r2):
	if ($r2.bottom_left.x | __x_point_in_bld($r1) == $r2.bottom_left) or ($r1.bottom_left.x | __x_point_in_bld($r2) == $r1.bottom_left) then 
		[$r1.bottom_left, $r1.top_right, $r2.bottom_left, $r2.top_right] |
		map(point_to_array) | sort | __bld_points_between(.[1]; .[2])
	else [] end;

## Bottom Left Diag/Top Left Diag intersections
def __bld_b($x; $y): $y + $x;
def __tld_b($x; $y): $y - $x;
def __bld_tld_intersections($r1; $r2): ($r1.b - $r2.b) | if . % 2 == 0 then . / 2 else -1 end |
	if (. | __x_point_in_bld($r1)) and (. | __x_point_in_tld($r2)) then [[., $r2.b + .]]
	else []
	end;
	

def intersections($r1; $r2):
	if $r1.x and $r2.x then __ver_ver_intersections($r1; $r2)
	elif $r1.y and $r2.y then __hor_hor_intersections($r1; $r2)
	elif $r1.x and $r2.y then __hor_ver_intersections($r2; $r1)
	elif $r1.y and $r2.x then __hor_ver_intersections($r1; $r2)

	elif $r1.top_left and $r2.y then __tld_hor_intersections($r1; $r2)
	elif $r2.top_left and $r1.y then __tld_hor_intersections($r2; $r1)
	elif $r1.top_left and $r2.x then __tld_ver_intersections($r1; $r2)
	elif $r2.top_left and $r1.x then __tld_ver_intersections($r2; $r1)
	elif $r1.top_left and $r2.top_left then __tld_tld_intersections($r1; $r2)

	elif $r1.bottom_left and $r2.y then __bld_hor_intersections($r1; $r2)
	elif $r2.bottom_left and $r1.y then __bld_hor_intersections($r2; $r1)
	elif $r1.bottom_left and $r2.x then __bld_ver_intersections($r1; $r2)
	elif $r2.bottom_left and $r1.x then __bld_ver_intersections($r2; $r1)
	elif $r1.bottom_left and $r2.bottom_left then __bld_bld_intersections($r1; $r2)

	elif $r1.bottom_left and $r2.top_left then __bld_tld_intersections($r1; $r2)
	elif $r2.bottom_left and $r1.top_left then __bld_tld_intersections($r2; $r1)
	else []
	end;

map(
	split(" -> ") |
	map(split(",") | map(tonumber)) |
	sort |
	if is_vertical then
		{ "x": .[0][0], "y_range": [.[0][1], .[1][1]] }
	elif is_horizontal then
		{ "y": .[0][1], "x_range": [.[0][0], .[1][0]] }
	elif is_top_left_diagonal then
		{ "top_left": .[0] | to_point, "bottom_right": .[1] | to_point, "b": __tld_b(.[0][0]; .[0][1])}
	else
		{ "bottom_left": .[0] | to_point, "top_right": .[1] | to_point, "b": __bld_b(.[0][0]; .[0][1])}
	end
) |
length as $n_points |
{
	"i": 0,
	"j": 1,
	"ranges": .,
	"intersections": []
} |
until(
	.i == $n_points - 1;
	.i as $i |
	.ranges[.i] as $r1 |
	.j |= $i + 1 |
	until(
		.j == $n_points;
		.ranges[.j] as $r2 |
		.intersections |= . + intersections($r1; $r2) |
		.j |= . + 1
	) | .i |= . + 1
) | .intersections | unique | length
