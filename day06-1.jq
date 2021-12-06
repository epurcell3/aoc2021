reduce .[] as $age (
	{};
	.[$age | tostring] |= if . then . + 1 else 1 end
) | { "day": 0, "state": . } |
until( .day == 80;
	.day |= . + 1 |
	.state |= reduce to_entries[] as $old_age_group (
		{};
		if $old_age_group.key == "0" then
			.["6"] |= . + $old_age_group.value |
			.["8"] |= $old_age_group.value
		else
			.[$old_age_group.key | tonumber | . - 1 | tostring] |= 
				if . then . + $old_age_group.value 
				else $old_age_group.value end
		end
	)
) | .state | to_entries | map(.value) | add
