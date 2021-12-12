def open_to_close: if . == "(" then ")"
	elif . == "[" then "]"
	elif . == "{" then "}"
	else ">" end;
def score: if . == ")" then 3
	elif . == "]" then 57
	elif . == "}" then 1197
	else 25137 end;

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
)) | map(select(.status == "CORRUPTED") | .illegal_char | score) | add
