def union($to_add):
	. + $to_add | unique;

def intersection($other):
	map(select([.] | inside($other)));

def difference($other):
	. - $other;
