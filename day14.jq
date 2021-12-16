import "./jq-modules/windows" as WINDOWS;

# Truncates $l if $l is longer than the array being filtered upon
def interleave($l): to_entries | map([.value, if $l[.key] then $l[.key] else empty end]) | flatten(1);

reduce .[2:][] as $rule_line (
	{ "polymer_chain": .[0] | split(""), "pair_rules": {}, "iteration": 0 }
	;
	.pair_rules[$rule_line | split(" -> ")[0]] |= ($rule_line | split(" -> ")[1])
) |
.pair_rules as $pair_rules |
until(
	.iteration == 2
	;
	.polymer_chain |= (
		. | interleave(. | WINDOWS::window(2) | map(.[0] + .[1] | $pair_rules[.]))
	) |
	.iteration |= . + 1
	| debug
),
until(
	.iteration == 40
	;
	.polymer_chain |= (
		. | interleave(. | WINDOWS::window(2) | map(.[0] + .[1] | $pair_rules[.]))
	) |
	.iteration |= (. + 1 | debug)
) 

| .polymer_chain | reduce .[] as $char ({}; .[$char] |= . + 1) | [.[]] |
max - min
