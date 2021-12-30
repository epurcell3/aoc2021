def cross_link: . as $input | [range(0;length) as $path | map([., ($input | getpath([$path]))] | select(.[0] != .[1]))] | flatten(1);
