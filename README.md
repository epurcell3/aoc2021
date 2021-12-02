# Day 1
awk -v TYPE=number -f input-scripts/list.awk inputs/day01.txt | jq -f day01-1.jq

awk -v TYPE=number -f input-scripts/list.awk inputs/day01.txt | jq -f day01-2.jq

# Day 2
awk -f input-scripts/list.awk inputs/day02.txt | jq -f day02-1.jq

awk -f input-scripts/list.awk inputs/day02.txt | jq -f day02-2.jq
