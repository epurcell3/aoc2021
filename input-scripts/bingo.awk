BEGIN {
	printf("{\n")
	FS = ","
}

NR == 1 {
	printf("  \"called_numbers\": [%s", $1)
	for (i = 2; i <= NF; i++) printf(", %s", $i)
	printf("],\n  \"boards\": [\n")
	FS = " "
	BOARD_START = ""
}

NR > 1 && NF == 0 {
	printf("%s    [\n", BOARD_START)
	BOARD_START = "\n    ],\n"
	LINE_START = ""
	BOARD_SEP = ","
}

NR > 1 && NF != 0{
	printf("%s      [%s", LINE_START, $1)
	for (i = 2; i <= NF; i++) printf(", %s", $i)
	printf("]")
	LINE_START = ",\n"
}

END {
	printf("\n    ]\n  ]\n}")
}
