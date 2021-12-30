def as_digits: tostring | split("") | map(tonumber);
def as_number: map(tostring) | join("") | tonumber;
def possible_model_nums: range(99999999999999; 11111111111111; -1) |
	as_digits | select(any(. == 0) | not);

def z_one: .[0] + 6;
def z_two: z_one * 26 + .[1] + 7;
def z_three: z_two * 26 + .[2] + 10;
def z_four: z_three * 26 + .[3] + 2;
def z_five_good: z_four / 26 | floor;
def z_six: z_five_good * 26 + .[5] + 8;
def z_seven: z_six * 26 + .[6] + 1;
def z_eight_good: z_seven / 26 | floor;
def z_nine: z_eight_good * 26 + .[8] + 5;
def z_ten_good: z_nine / 26 | floor;
def z_eleven_good: z_ten_good / 26 | floor;
def z_twelve_good: z_eleven_good / 26 | floor;
def z_thirteen_good: z_twelve_good / 26 | floor;

def possible_first_five_digits: range(99999; 11110; -1) | as_digits | select(all(. != 0));
def possible_next_digit($prepend): range(9; 0; -1) | as_digits | $prepend + .;
def possible_next_two_digits($prepend): range(99; 10; -1) | as_digits | select(all(. != 0)) | $prepend + .;
def possible_next_three_digits($prepend): range(999; 110; -1) | as_digits | select(all(. != 0)) | $prepend + .;

[
# d5 = ((((d1 + 6) * 26 + d2 + 7) * 26 + d3 + 10) * 26 + d4 + 2) % 26 - 7
possible_first_five_digits | select(.[4] == (z_four % 26) - 7) |
possible_next_three_digits(.) | select(.[7] == (z_seven % 26) - 5) |
possible_next_two_digits(.) | select(.[9] == (z_nine % 26) - 3) |
possible_next_digit(.) | select(.[10] == z_ten_good % 26) |
possible_next_digit(.) | select(.[11] == (z_eleven_good % 26) - 5) |
possible_next_digit(.) | select(.[12] == (z_twelve_good % 26) - 9) |
possible_next_digit(.) | select(debug | .[13] == z_thirteen_good % 26) |
as_number] | first, last
