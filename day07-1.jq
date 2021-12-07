sort | .[length / 2 | floor] as $median |
map(. - $median | fabs) | add
