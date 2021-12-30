const ROLL_CHANCES: [usize; 7] = [1, 3, 6, 7, 6, 3, 1];
const SCORES: [usize; 10] = [10, 1, 2, 3, 4, 5, 6, 7, 8, 9];

fn quantum_game(current_player_p: usize, other_player_p: usize, current_player_score: usize, other_player_score: usize) -> (usize, usize) {
    let mut wins = (0, 0);
    for (roll, roll_chance) in ROLL_CHANCES.iter().enumerate() {
        let current_player_p = (current_player_p + roll + 3) % 10;
        let current_player_score = current_player_score + SCORES[current_player_p];
        if current_player_score >= 21 {
            wins.0 += roll_chance;
        } else {
            let new_wins = quantum_game(other_player_p, current_player_p, other_player_score, current_player_score);
            wins.0 += new_wins.1 * roll_chance;
            wins.1 += new_wins.0 * roll_chance;
        }
    }

    wins
}

fn main() {
    let wins = quantum_game(4, 10, 0, 0);
    println!("{:?}", wins.0.max(wins.1));
}
