#1,2,3, 4,5,6, 7,8,9, 10,11,12, 13,14Since player 1 has at least 1000 points, player 1 wins and the game ends. At this point, the losing player had 745 points and the die had been rolled ,15
#  6     15     24	33        42
#3*2    3*5    3*8      3*11      3*14
#16,17,18, 19,20,21, 22,23,24, 25,26,27,
#  3*17      3*20       3*23      
#28,29,30, 31,32,33, 34,35,36, 37,38,39,
#
#40,41,42, 43,44,45, 46,47,48, 49,50,51,
#52,53,54, 55,56,57, 58,59,60, 61,62,63,
#64,65,66, 67,68,69, 70,71,72, 73,74,75,
#76,77,78, 79,80,81, 82,83,84, 85,86,87,
#88,89,90, 91,92,93, 94,95,96, 97,98,99, (32nd roll)
#
#100,1,2, (102, 33rd roll)
#
#3,4,5, 6,7,8, 9,10,11,
# 12      21     30
# 3*4     3*7     3*10
#12,13,14, 15,16,17, 18,19,20, 21,22,23,
#  3*13       3*16     3*19      3*22
#...
#96,97,98, 99,100,1 2,3,4, 5,6,7, 8,9,20, 
# 3*97
#95,96,97, 98,99,100
#            297

def roll:
	. % 100 |
	if . != 0 and . == 99 then 297
	elif . != 0 and . == 66 then 200
	elif . != 0 and . == 33 then 103
	elif . < 33 then (. * 3 + 2) * 3
	elif . < 66 then ((. % 33) * 3 + 1) * 3
	else . % 33 * 3 * 3 end;

def turn(r):
	[10, 1, 2, 3, 4, 5, 6, 7, 8, 9] as $scores |
	.turn as $turn |
	r as $roll |
	.position |= (. + $roll) % 10 |
	($scores[.position]) as $score_add |
	.score += $score_add |
	.turn += 2;

def steps_to_win:
	until(.score >= 1000;
		turn(.turn | roll)
	);

def n_steps($n):
	[10, 1, 2, 3, 4, 5, 6, 7, 8, 9] as $scores |
	until(.turn >= $n;
		turn(.turn | roll)
	);

def quantum_wins(roll): 
	def _cache(key): .cache += { (key): .wins };

	def _quantum_wins:
	[10, 1, 2, 3, 4, 5, 6, 7, 8, 9] as $scores |
	.cache as $cache |
	if .state | tostring | in($cache) then $cache[.state | tostring]
	else
		.state as $state |
		reduce (roll)[] as $roll_chance
		(.;
			.state = $state |
			.state.players[.state.curr_player].position |= (. + $roll_chance.key) % 10 |
			($scores[.state.players[.state.curr_player].position]) as $score_add |
			.state.players[.state.curr_player].score += $score_add |
			if .state.players[.state.curr_player].score >= 21 then
				.wins[.state.curr_player] += $roll_chance.value |
				_cache(.state | tostring)
			else
				.state.curr_player |= 1 - . |
				_quantum_wins |
				.wins |= map(. | debug * $roll_chance.value) |
				_cache(.state | tostring)
			end
		)
	end;

	{ "state": ., "wins": [0,0], "cache": {}} | _quantum_wins
;
	
	
	
map(split(": ")[1] | tonumber) | [
	{ "initial_position": .[0], "position": .[0], "score": 0, "turn": 0 },
	{ "initial_position": .[1], "position": .[1], "score": 0, "turn": 1 }
] | (map(steps_to_win) |
sort_by(.turn) | 
.[0].turn as $turns |
(($turns - 1) * 3) as $dice_rolls |
.[1].position = .[1].initial_position |
.[1].score = 0 |
.[1].turn %= 2 |
.[1] | debug | n_steps($turns - 2) | $dice_rolls * .score),
( map({position, score}) | { "players": ., "curr_player": 0 } |
quantum_wins([0,0,0,1,3,6,7,6,3,1] | to_entries | map(select(.key >= 3))))
