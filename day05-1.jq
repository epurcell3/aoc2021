# Failed attempt... reduce isn't very performant for 100k entries in a list.
#map(
#	split(" -> ") |
#	map(split(",") | map(tonumber)) |
#	if .[0][0] == .[1][0] then
#		.[0][0] as $x |
#		[range(.[0][1]; .[1][1]; if .[0][1] < .[1][1] then 1 else -1 end)] + [.[1][1]] | map([$x, .] | tostring)
#	elif .[0][1] == .[1][1] then
#		.[0][1] as $y |
#		[range(.[0][0]; .[1][0]; if .[0][0] < .[1][0] then 1 else -1 end)] + [.[1][0]] | map([., $y] | tostring)
#	else []
#	end
#) | flatten(1) | reduce .[] as $point ({}; .[$point] |= if . then . + 1 else 1 end) | with_entries(select(.value >= 2)) | length

def is_horizontal: if .[0][1] == .[1][1] then true else false end;
def is_vertical: if .[0][0] == .[1][0] then true else false end;

def __in_bounds_inclusive($bounds): . >= $bounds[0] and . <= $bounds[1];
def __is_range_overlap($b1; $b2): $b1 + $b2 | sort | (. != $b1 + $b2 and . != $b2 + $b1) or .[1] == .[2];

def __hor_hor_intersections($r1; $r2): if $r1.y == $r2.y and __is_range_overlap($r1.x_range; $r2.x_range) then [$r1.x_range[0], $r1.x_range[1], $r2.x_range[0], $r2.x_range[1]] | sort | [range(.[1]; .[2] + 1) | [., $r1.y]] else [] end;
def __ver_ver_intersections($r1; $r2): if $r1.x == $r2.x and __is_range_overlap($r1.y_range; $r2.y_range) then [$r1.y_range[0], $r1.y_range[1], $r2.y_range[0], $r2.y_range[1]] | sort | [range(.[1]; .[2] + 1) | [$r1.x, .]] else [] end;
def __hor_ver_intersections($r1; $r2): if ($r2.x | __in_bounds_inclusive($r1.x_range)) and ($r1.y | __in_bounds_inclusive($r2.y_range)) then [[$r2.x, $r1.y]] else [] end;

def intersections($r1; $r2):
	if $r1.x and $r2.x then __ver_ver_intersections($r1; $r2)
	elif $r1.y and $r2.y then __hor_hor_intersections($r1; $r2)
	elif $r1.x and $r2.y then __hor_ver_intersections($r2; $r1)
	elif $r1.y and $r2.x then __hor_ver_intersections($r1; $r2)
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
	else
		{ "x_range": [.[0][0], .[1][0]], "y_range": [.[0][1], .[1][1]] }
	end |
	select(.x or .y)
) |
debug |
length as $n_points |
{
	"i": 0,
	"j": 1,
	"ranges": .,
	"intersections": []
} |
until(
	.i > $n_points - 1;
	.i as $i |
	.ranges[.i] as $r1 |
	.j |= $i + 1 |
	until(
		.j > $n_points;
		.ranges[.j] as $r2 |
		.intersections |= . + intersections($r1; $r2) |
		.j |= . + 1
	) | .i |= . + 1
) | .intersections #| unique | length
