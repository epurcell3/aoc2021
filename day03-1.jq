def binstr_not: map(if . == 0 then 1 else 0 end);
def binstr_to_num: to_entries | map(.value * pow(2; .key)) | add;

# Create bit count array `[ {"0": 0, "1": 0}, ... ]`
reduce (.[] | split("")) as $binary (
	[range(0; .[0] | length)] | map({"0": 0, "1": 0});
	to_entries | map((.value[$binary[.key]]) |= . + 1) | map(.value)
) | 
# Select the most common bits to be an array
map(if .["0"] > .["1"] then 0 else 1 end) | 

# Reverse the bit array for later processing, then create an array
# of the least common bits (a NOT on the bit string)
reverse | [., (. | binstr_not)] |

# Map the array of 0s and 1s to an int and return the answer
map(binstr_to_num) | .[0] * .[1]
