import "./jq-modules/set" as SET;

#on x=-32..18,y=-49..-2,z=-43
def parse_range: split("=")[1] | split("..") | map(tonumber);

def bounds_to_points:
	.y as $by |
	.x as $bx |
	reduce range(.z[0]; .z[1] + 1) as $z (
		[];
		. + (reduce range($by[0]; $by[1] + 1) as $y (
			[];
			. + (reduce range($bx[0]; $bx[1] + 1) as $x (
				[];
				. + [[$x, $y, $z]]
			))
		))
	);

# Parse input
map(split(" ") | { "action": .[0], "ranges": (.[1] | split(",")) } |
	.bounds.x = (.ranges[0] | parse_range) |
	.bounds.y = (.ranges[1] | parse_range) |
	.bounds.z = (.ranges[2] | parse_range) |
	del(.ranges)
) |

# Part 1 only cares about ranges in the -50..50 range
map(select(
	.bounds.x[0] >= -50 and .bounds.x[1] <= 50 and
	.bounds.y[0] >= -50 and .bounds.y[1] <= 50 and
	.bounds.z[0] >= -50 and .bounds.z[1] <= 50)),
. |
# Create set of points
reduce .[] as $action (
	[];
	if $action | debug | .action == "on" then
		SET::union($action.bounds | bounds_to_points)
	else
		SET::difference($action.bounds | bounds_to_points)
	end
) | length
