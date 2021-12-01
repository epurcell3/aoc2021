BEGIN {
	DO_END = 1
	if (!TYPE || TYPE == "string") {
		wrapper = "\""
	} else if (TYPE == "number") {
		wrapper = ""
	} else {
		print "Invalid TYPE: only 'string' and 'number' are supported"
		DO_END = 0
		exit 1
	}
	printf("[\n")
}

NR == 1 {
	printf("%s%s%s", wrapper, $0, wrapper)
}

NR > 1 {
	printf(",\n%s%s%s", wrapper, $0, wrapper)
}

END {
	if (DO_END) printf("\n]")
}
