reduce (.[] | split(" ")) as $move (
	[0, 0];
	if $move[0] == "forward" then
		[.[0] + ($move[1] | tonumber), .[1]]
	elif $move[0] == "up" then
		[.[0], .[1] - ($move[1] | tonumber)]
	elif $move[0] == "down" then
		[.[0], .[1] + ($move[1] | tonumber)]
	else
		.
	end
) | .[0] * .[1]
