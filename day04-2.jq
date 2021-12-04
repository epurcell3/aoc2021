def __col(ind): map(.[ind]);
def pivot: { "ind": 0, "matrix": ., "new_matrix": []} | until(
	.ind == (.matrix[0] | length)
	;
	.ind as $ind | 
	.matrix as $matrix |
	.new_matrix |= . + [($matrix | __col($ind))] |
	.ind |= . + 1
) | .new_matrix;

# Get all possible bingo states
[foreach .called_numbers[] as $num (
	{ "boards": .boards | map(map(map({ "value": ., "called": false}))) }
	;
	.called_number |= $num |
	.boards |= map(map(map({ "value": .value, "called": (.called or (.value == $num)) })))
	;
	.
)] | 

# Find the first state where all boards are winners
limit(1; .[] | select(
	.boards | map(
		(map(all(.called)) | any) 
		or
		(pivot | map(all(.called)) | any)
		)
	| all
	)
) |

# Set the called number to uncalled to...
.called_number as $called_number | 
.boards |= map(map(map({
  "value": .value,
  "called": (if .value == $called_number then false else .called end)
}))) | 

# Find the only board that isn't a winner
{
  "called_number": .called_number,
  "winner": (.boards[] | select([
    (map(all(.called)) | any),
    (pivot | map(all(.called)) | any)
  ] | all(not)))
} |

# And get the answer (being sure to remove the called number from the add list)
.called_number * (.winner | flatten | map(select(.called | not) | .value) | . - [$called_number] | add)
