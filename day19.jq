import "./jq-modules/cross" as CROSS;
import "./jq-modules/transform3d" as TRANSFORM;
import "./jq-modules/set" as SET;

# $base: edge map
# $features: list of 3d distance vectors
# output: edge_map of entries that match
def matching_features($base; $features):
	$base | with_entries(select([.key] | inside($features)));

def find_matching_orientation($pair):
	$pair[0].edge_map as $base |
	$pair[1].edge_map | keys | map(fromjson) | TRANSFORM::axes_rotations_list |
	to_entries | map({ "matching": matching_features($base; .value | map(tostring)), "rotation": .key } |
		select([.matching[]] | flatten(1) | unique | length >= 12));

def rotate_edge_map($rotation):
	with_entries(
		.key |= (fromjson | TRANSFORM::rotate($rotation) | tostring) |
		.value |= map(TRANSFORM::rotate($rotation)));

# Map list of relative to scanner beacon positions to edge distance map
# of beacons relative to each other
map({
	"beacons": .,
	"edge_map": (reduce CROSS::cross_link[] as $nodes (
		{};
		.[($nodes[1] | TRANSFORM::dist3d($nodes[0]) | tostring)] = [$nodes[0], $nodes[1]]
	))
	}
) |
{
	"known": {
		"scanners": [[0,0,0]],
		"beacons": .[0].beacons,
		"edge_map": .[0].edge_map
	},
	"to_do": .[1:],
	"i": 0,
} |
#matching_features(.known.edge_map; (.to_do[0].edge_map | keys | map(fromjson | TRANSFORM::rotate("-x+y")))) | [.[]] | flatten(1) | unique | length
#
#find_matching_orientation([.known, .to_do[0]])[] as $orientation |
#($orientation.matching | keys | first) as $key |
#.known as $known |
#	.to_do[0].edge_map |= rotate_edge_map($orientation.rotation) |
#	(.to_do[0].edge_map[$key][0] | TRANSFORM::dist3d($known.edge_map[$key][0])) as $dist_adjust |
#	.to_do[0].edge_map[$key][0] | TRANSFORM::sub($dist_adjust), $known.edge_map[$key][0]
#.to_do[0].edge_map | keys | map(fromjson) | TRANSFORM::axes_rotations_list | map(map(tostring))
#.known as $known |
#.to_do[0].edge_map | keys | map(fromjson | TRANSFORM::rotate("+z-y") | tostring) as $features |
#$known.edge_map | with_entries(select([.key] | inside($features)))
#.to_do[0].edge_map | keys | map(fromjson) | TRANSFORM::axes_rotations_list |
#to_entries | map((.value | map(tostring)) as $features | $known.edge_map | with_entries(select([.key] | inside($features))) | length )
#to_entries | map(.value as $features | $known.edge_map | with_entries(select([.key | fromjson] | inside($features))) | length )
#$known.edge_map | with_entries(select([.key] | inside($features)))
	#SET::intersection($known.edge_map | keys)

#.to_do[0] as $SCANNER |
#[[-81,-1,-163]] | inside(
#[[10,1285,-1658]] | inside(
#$SCANNER.edge_map | keys | map(fromjson | TRANSFORM::rotate("-x+y"))
#)

until(
	.to_do | length == 0
	;
	find_matching_orientation([.known, .to_do[.i | debug]])[0] as $orientation |
	if $orientation then
		($orientation.matching | keys | first) as $key |
		.known.edge_map[$key][0] as $known_beacon |
		.to_do[.i].edge_map |= rotate_edge_map($orientation.rotation) |
		(.to_do[.i].edge_map[$key][0] | TRANSFORM::dist3d($known_beacon) | TRANSFORM::invert) as $dist_adjust |
		.known.scanners += [$dist_adjust] |
		.to_do[.i].edge_map |= map_values(map(TRANSFORM::add($dist_adjust))) |
		.to_do[.i].edge_map as $new_edges |
		(.to_do[.i].beacons | map(
			TRANSFORM::rotate($orientation.rotation) |
			TRANSFORM::add($dist_adjust))) as $adjusted_beacons |
		.known.beacons |= SET::union($adjusted_beacons) |
		.known.edge_map += $new_edges |
		.to_do = .to_do[0:.i] + .to_do[.i + 1:] |
		(.to_do | length) as $remaining |
		.i |= if . >= $remaining then 0 else . end
	else .i = (.i + 1) % (.to_do | length) end
) |
(.known.beacons | length),
(.known.scanners | CROSS::cross_link |
	map(
		.[1] as $other |
		.[0] |
		TRANSFORM::sub($other) |
		(.[0] | fabs) + (.[1] | fabs) + (.[2] | fabs)
	) | max)
