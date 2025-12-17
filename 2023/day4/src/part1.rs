use std::collections::HashSet;
use std::io::BufRead;

pub fn part1<R: BufRead>(reader: R) -> Result<usize, Box<dyn std::error::Error>> {
    let acc = reader
        .lines()
        .map(|line| -> String { line.unwrap() })
        .map(|line| -> (usize, String) {
            // parse game ID

            let (head, tail) = line.split_once(":").unwrap();

            let (_, game_number) = head.split_once(" ").unwrap();
            let gn = game_number.trim().parse::<usize>().unwrap();

            (gn, String::from(tail))
        })
        .map(|(gn, line)| -> (usize, HashSet<usize>, HashSet<usize>) {
            // parse game numbers
            let (our_numbers, winning_numbers) = line.split_once("|").unwrap();

            let on = our_numbers
                .split_whitespace()
                .map(|x| -> usize { x.parse::<usize>().unwrap() })
                .collect();

            let wn = winning_numbers
                .split_whitespace()
                .map(|x| -> usize { x.parse::<usize>().unwrap() })
                .collect();

            (gn, on, wn)
        })
        .map(|(_gn, on, wn)| -> usize {
            // score
            let winners: HashSet<usize> = on.intersection(&wn).copied().collect();

            match winners.len() {
                0 => 0,
                i => 1 << (i - 1),
            }
        })
        .sum();

    Ok(acc)
}

#[cfg(test)]
mod test_part_1 {
    use super::*;
    use rstest::rstest;
    use std::io::Cursor;

    #[test]
    fn example() {
        let input = r#"Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"#;
        let expected = 13;

        let cur = Cursor::new(input.as_bytes());
        let result = part1(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[rstest]
    #[case("Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53", 8)]
    #[case("Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19", 2)]
    #[case("Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1", 2)]
    #[case("Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83", 1)]
    #[case("Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36", 0)]
    #[case("Card  6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11", 0)]
    fn example_partial(#[case] input: &str, #[case] expected: usize) {
        let cur = Cursor::new(input.as_bytes());
        let result = part1(cur).unwrap();

        assert_eq!(result, expected);
    }
}
