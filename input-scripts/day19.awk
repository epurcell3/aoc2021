BEGIN {
	FS=","
	printf("[")
	scannerSep=""
}

/--- scanner [0-9]+ ---/ {
	printf("%s\n\t[", scannerSep)
	scannerSep=","
	entrySep=""
}

/-?[0-9]+,-?[0-9]+,-?[0-9]+/ {
	printf("%s\n\t\t[%s, %s, %s]", entrySep, $1, $2, $3)
	entrySep=","
}

/^$/ {
	printf("\n\t]")
}

END {
	printf("\n\t]\n]")
}
