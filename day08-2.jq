def get_signals(l): .signal | map(select(length == l));
def get_nth_signal(l; n): get_signals(l) | nth(n);

map(split(" | ") | {
	"signal": .[0] | split(" "),
	"result": .[1] | split(" "),
	"known": {
		(.[0] | split(" ")[] | select(length == 2) | split("") | sort | join("")): "1",
		(.[0] | split(" ")[] | select(length == 3) | split("") | sort | join("")): "7",
		(.[0] | split(" ")[] | select(length == 4) | split("") | sort | join("")): "4",
		(.[0] | split(" ")[] | select(length == 7) | split("") | sort | join("")): "8"
	}
} |

(get_nth_signal(2; 0) | split("")) as $find_three_zero_mask |
((get_nth_signal(4; 0) | split("")) - (get_nth_signal(2; 0) | split(""))) as $find_five_mask |
(get_nth_signal(4; 0) | split("")) as $find_nine_mask |

# Map out 2, 3, 5
.i = 0 |
until(
	.i == 3
	;
	.i as $i |
	if get_nth_signal(5; $i) | split("") | contains($find_three_zero_mask) then
		.known[get_nth_signal(5; $i) | split("") | sort | join("")] |= "3"
	elif get_nth_signal(5; $i) | split("") | contains($find_five_mask) then
		.known[get_nth_signal(5; $i) | split("") | sort | join("")] |= "5"
	else
		.known[get_nth_signal(5; $i) | split("") | sort | join("")] |= "2"
	end |
	.i |= . + 1
) |

# Map out 6, 9, 0
.i = 0 |
until(
	.i == 3
	;
	.i as $i |
	if get_nth_signal(6; $i) | split("") | contains($find_nine_mask) then
		.known[get_nth_signal(6; $i) | split("") | sort | join("")] |= "9"
	elif get_nth_signal(6; $i) | split("") | contains($find_three_zero_mask) then
		.known[get_nth_signal(6; $i) | split("") | sort | join("")] |= "0"
	else
		.known[get_nth_signal(6; $i) | split("") | sort | join("")] |= "6"
	end |
	.i |= . + 1
) |

# Build out result
.known as $known |
.result | map($known[. | split("") | sort | join("")]) | join("") | tonumber
) | add
