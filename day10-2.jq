def open_to_close: if . == "(" then ")"
	elif . == "[" then "]"
	elif . == "{" then "}"
	else ">" end;
def score: 
	def _score_char: if . == ")" then 1
		elif . == "]" then 2
		elif . == "}" then 3
		else 4 end;
	reduce .[] as $char (0;
		. * 5 + ($char | _score_char));

map(split("") | . + [null] |
reduce .[] as $next (
	{"status": "IN PROGRESS", "stack": []}
	;
	if .status == "CORRUPTED" then .
	elif $next == null then
		(.stack | length == 0) as $is_empty |
		.status |= if $is_empty then "COMPLETE" else "INCOMPLETE" end
	elif ["(", "[", "{", "<"] | contains([$next]) then
		.stack |= . + [$next]
	else
		(.stack | last) as $pop |
		.stack |= .[0:(. | length - 1)] |
		if ($pop | open_to_close) != $next then
			.status |= "CORRUPTED" |
			.illegal_char |= $next
		else
			.
		end
	end
)) | map(select(.status == "INCOMPLETE") | .stack | reverse | map(open_to_close) | score) |
sort | .[. | length / 2 | floor]
