def window(size): . as $input | 
	[range(0; (length - (size - 1))) | [range(.; . + size) | $input[.]]];

