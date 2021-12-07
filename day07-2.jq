sort | (add / length | floor) as $mean |
map(. - $mean | fabs | [range(0; . + 1)] | add) | add
