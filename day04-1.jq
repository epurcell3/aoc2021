def __col(ind): map(.[ind]);
def pivot: { "ind": 0, "matrix": ., "new_matrix": []} | until(
	.ind == (.matrix[0] | length)
	;
	.ind as $ind | 
	.matrix as $matrix |
	.new_matrix |= . + [($matrix | __col($ind))] |
	.ind |= . + 1
) | .new_matrix;

# Create a all the bingo rounds
[foreach .called_numbers[] as $num (
	{ "boards": .boards | map(map(map({ "value": ., "called": false}))) }
	;
	.called_number |= $num |
	.boards |= map(map(map({ "value": .value, "called": (.called or (.value == $num)) })))
	;
	.
)] | 

# Find the first state with any winning board
limit(1; .[] | select(
	.boards | map(
		(map(all(.called)) | any) 
		or
		(pivot | map(all(.called)) | any)
		)
	| any)
) |

# Pick out the winning board
{
  "called_number": .called_number,
  "winner": (.boards[] | select([
    (map(all(.called)) | any),
    (pivot | map(all(.called)) | any)
  ] | any))
}

# Get the answer
| .called_number * (.winner | flatten | map(select(.called | not) | .value) | add)
