def bit_counts(ind): map(.[ind]) | reduce .[] as $bit (
	{"0": 0, "1": 0};
	if $bit == 0 then .["0"] |= . + 1 else .["1"] |= . + 1 end);
def most_common_bit(ind; tie_breaker): bit_counts(ind) | 
	if .["0"] == .["1"] then tie_breaker elif .["0"] > .["1"] then 0 else 1 end;
def least_common_bit(ind; tie_breaker): bit_counts(ind) | 
	if .["0"] == .["1"] then tie_breaker elif .["0"] < .["1"] then 0 else 1 end;
def binstr_to_num: to_entries | map(.value * pow(2; .key)) | add;

# Need to know how many bits there are for the loops
(.[0] | length) as $n_bits |

# Create an intermediary data structure to keep track of the current index
# `{ "ind": 0, "data": [ [ 1, 0, 1, 0], ... ] }`
. | map(split("") | map(tonumber)) | { "ind": 0, "data": . } |

# Essetially a bi, loop through the same data twice with slightly different
# loops. Can't seem to make this a function without duplicating other code.
[
(until(
	# Loop condition
	.ind == $n_bits or (.data | length) <= 2;
	# Loop update
	.ind as $ind |
	(.data | most_common_bit($ind; 1)) as $mcb |
	.data |= map(select(.[$ind] == $mcb)) | .ind |= . + 1
) |
# Get the result from what's left
if (.data | length) == 1 then 
	.data[0] 
elif (.data | length) == 2 then
	if .data[0][.ind] == 1 then .data[0] else .data[1] end
else halt_error(5)
end),
# The second "filter" to run on the data
(until(
	.ind == $n_bits or (.data | length) <= 2;
	.ind as $ind |
	(.data | least_common_bit($ind; 0)) as $lcb |
	.data |= map(select(.[$ind] == $lcb)) | .ind |= . + 1) |
if (.data | length) == 1 then 
	.data[0] 
elif (.data | length) == 2 then
	if .data[0][.ind] == 0 then .data[0] else .data[1] end
else halt_error(5)
end)

# Reverse the results, get the number, and multiply
] | map(reverse | binstr_to_num) | .[0] * .[1]

