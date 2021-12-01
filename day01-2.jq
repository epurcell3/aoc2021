import "./jq-modules/windows" as WINDOWS;

#. as $input | 
#(length - 2) as $l |
# create windows
# original code
#[range(0;$l) | [$input[.], $input[.+1], $input[.+2]]] | map(add) | . as $windows |
#(length - 1) as $l |
#[range(0;$l) | [$windows[.], $windows[. + 1]]] |
# moduled code
WINDOWS::window(3) | map(add) | WINDOWS::window(2) |
map(select(.[0] < .[1])) |
length |
.
