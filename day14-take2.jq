import "./jq-modules/windows" as WINDOWS;

def step: 
	.pair_rules as $pair_rules |
	.polymer_pairs as $pairs |
	(reduce $pair_rules[] as $rule(
		{ "polymer_pairs": {}, "char_counts": .char_counts }
		;
		if $pairs[$rule.match] then
			.char_counts[$rule.insert] |= . + $pairs[$rule.match] |
			.polymer_pairs[$rule.match[0:1] + $rule.insert] |= . + $pairs[$rule.match] |
			.polymer_pairs[$rule.insert + $rule.match[1:]] |= . + $pairs[$rule.match]
		else .
		end
	)) as $new_state |
	.polymer_pairs |= $new_state.polymer_pairs |
	.char_counts |= $new_state.char_counts |
	.iteration |= . + 1;

reduce .[2:][] as $rule_line (
	{ 
		"polymer_pairs": (reduce (.[0] | split("") | WINDOWS::window(2)[]) as $pair (
			{}; .[$pair[0] + $pair[1]] |= . + 1)),
		"pair_rules": [],
		"char_counts": (reduce (.[0] | split("")[]) as $char ({}; .[$char] |= . + 1)),
		"iteration": 0
	}
	;
	.pair_rules |= . + [$rule_line | split(" -> ") | { "match": .[0], "insert": .[1] }]
) |
until(
	.iteration == 10
	;
	step
),
until(
	.iteration == 40
	;
	step
) 

| 
.char_counts | [.[]] | max - min
