import "./jq-modules/windows" as WINDOWS;

#. as $input | 
#(length - 1) as $l |
# create windows
# original code
#[range(0;$l) | [$input[.], $input[.+1]]] |
# moduled code
WINDOWS::window(2) |
map(select(.[0] < .[1])) |
length |
.
