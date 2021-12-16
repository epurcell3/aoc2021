def str_to_xy: split(",") | { "x": .[0] | tonumber, "y": .[1] } | map_values(tonumber);
def xy_to_str: map_values(tostring) | .x + "," + .y;
def grid_to_point_map: . as $grid | { "i": 0, "j": 0, "result": {} } |
	until(.i == ($grid | length)
	;
	.j |= 0 |
	.i as $i |
	until(.j == ($grid[$i] | length) ;
		.j as $j |
		.result[{ "x": .j, "y": .i } | xy_to_str] |= $grid[$i][$j] |
		.j |= . + 1
		) |
	.i |= . + 1
	) | .result ;
def neighbors($bounds): str_to_xy | [
	{ "x": (.x - 1), "y": .y       },
	{ "x": .x      , "y": (.y + 1) },
	{ "x": (.x + 1), "y": .y       },
	{ "x": .x      , "y": (.y - 1) }
	] | map(select(.x >= 0 and .y >= 0 and .x <= $bounds and .y <= $bounds) | xy_to_str);

def d($weights): ($weights | length | sqrt) as $l | str_to_xy |
	.x_adjust = (.x / $l | floor) |
	.x |= . % $l |
	.y_adjust = (.y / $l | floor) |
	.y |= . % $l |
	$weights[xy_to_str] + .x_adjust + .y_adjust |
	if . > 9 then . % 9 else . end;
def g($g_score): if $g_score[.] != null then $g_score[.] else infinite end;
def f($f_score): if $f_score[.] != null then $f_score[.] else infinite end;


def a_star($start; $goal; h; $bounds):
	{
		"node_weights": .,
		"open_set": [$start],
		"came_from": {},
		"g_score": {},
		"f_score": {} 
	} |
	.g_score[$start] = 0 |
	.f_score[$start] = ($start | h) |
	.node_weights as $weights |
	until(
		.open_set | length == 0
		;
		.f_score as $f |
		.open_set |= (. | sort_by(f($f))) |
		if .open_set | first == $goal then
			.open_set |= [] |
			.current = $goal |
			.path = [.current] |
			until(
				.came_from[.current] | not
				;
				.current = .came_from[.current] |
				.path = [.current] + .path
			)
		else
			.g_score as $g |
			.current = (.open_set | first) |
			.open_set |= .[1:] |
			(.current | g($g)) as $curr_g |
			reduce (.current | neighbors($bounds) |
				map({ "xy": ., "g": ($curr_g + d($weights)) })[]) as $possible_g (
				.
				;
				if $possible_g.g < ($possible_g.xy | g($g)) then
					.came_from[$possible_g.xy] = .current |
					.g_score[$possible_g.xy] = $possible_g.g |
					.f_score[$possible_g.xy] = $possible_g.g + ($possible_g.xy | h) |
					if .open_set | contains([$possible_g.xy]) | not then
						.open_set += [$possible_g.xy]
					else .
					end
				else .
				end
			)
		end
	);

def dup_plus($n): map(. + $n | if . > 9 then . % 9 else . end);
def five_x:
	map(. + (. | dup_plus(1)) + (. | dup_plus(2)) + (. | dup_plus(3)) + (. | dup_plus(4))) |
	. + (. | map(dup_plus(1))) + (. | map(dup_plus(2))) + (. | map(dup_plus(3))) + (. | map(dup_plus(4)));

map(split("") | map(tonumber)) |
# Grid debug
#map(map(tostring) | join("")) | join("\n")
grid_to_point_map | . as $weights |
a_star("0,0"; (. | keys | max_by(str_to_xy | .x + 1000 * .y)); str_to_xy | 1000 - .x - .y; 99) ,
a_star("0,0"; "499,499"; str_to_xy | 2000 - 2*.x - 2*.y; 499) |
.path[1:] | debug | map(d($weights)) | add
