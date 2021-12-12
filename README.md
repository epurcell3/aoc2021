# Day 1
awk -v TYPE=number -f input-scripts/list.awk inputs/day01.txt | jq -f day01-1.jq

awk -v TYPE=number -f input-scripts/list.awk inputs/day01.txt | jq -f day01-2.jq

# Day 2
awk -f input-scripts/list.awk inputs/day02.txt | jq -f day02-1.jq

awk -f input-scripts/list.awk inputs/day02.txt | jq -f day02-2.jq

# Day 3
awk -f input-scripts/list.awk inputs/day03.txt | jq -f day03-1.jq

awk -f input-scripts/list.awk inputs/day03.txt | jq -f day03-2.jq

# Day 4
awk -f input-scripts/bingo.awk inputs/day04.txt | jq -f day04-1.jq

awk -f input-scripts/bingo.awk inputs/day04.txt | jq -f day04-2.jq

# Day 5
awk -f input-scripts/list.awk inputs/day05.txt | jq -f day05-1.jq

awk -f input-scripts/list.awk inputs/day05.txt | jq -f day05-2.jq

# Day 6
awk -v RS="," -v TYPE="number" -f input-scripts/list.awk inputs/day06.txt | jq -f day06-1.jq

awk -v RS="," -v TYPE="number" -f input-scripts/list.awk inputs/day06.txt | jq -f day06-2.jq

# Day 7
awk -v RS="," -v TYPE="number" -f input-scripts/list.awk inputs/day07.txt | jq -f day07-1.jq

awk -v RS="," -v TYPE="number" -f input-scripts/list.awk inputs/day07.txt | jq -f day07-2.jq

# Day 8
awk -f input-scripts/list.awk inputs/day08.txt | jq -f day08-1.jq

awk -f input-scripts/list.awk inputs/day08.txt | jq -f day08-2.jq

# Day 9
awk -f input-scripts/list.awk inputs/day09.txt | jq -f day09-1.jq

awk -f input-scripts/list.awk inputs/day09.txt | jq -f day09-2.jq

# Day 10
awk -f input-scripts/list.awk inputs/day10.txt | jq -f day10-1.jq

awk -f input-scripts/list.awk inputs/day10.txt | jq -f day10-2.jq

# Day 11
awk -f input-scripts/list.awk inputs/day11.txt | jq -f day11-1.jq

awk -f input-scripts/list.awk inputs/day11.txt | jq -f day11-2.jq

# Day 12
awk -f input-scripts/list.awk inputs/day12.txt | jq -f day12-1.jq

awk -f input-scripts/list.awk inputs/day12.txt | jq -f day12-2.jq
