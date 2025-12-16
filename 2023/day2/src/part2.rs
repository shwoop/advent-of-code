use std::io::BufRead;

use crate::gameinfo::{BallDraw, GameInfo};

pub fn part2<R: BufRead>(reader: R) -> Result<i32, Box<dyn std::error::Error>> {
    let mut acc = 0;

    for line in reader.lines() {
        let line = line.unwrap();
        let game = GameInfo::parse_game(line);
        let BallDraw { red, blue, green } = game.required_balls();
        acc += red * blue * green;
    }

    Ok(acc)
}

#[cfg(test)]
mod test_part_2 {
    use super::*;
    use rstest::rstest;
    use std::io::Cursor;

    #[test]
    fn example() {
        let input = r#"Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"#;
        let expected = 2286;

        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[rstest]
    #[case("Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green", 48)]
    #[case("Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue", 12)]
    #[case(
        "Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red",
        1560
    )]
    #[case(
        "Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red",
        630
    )]
    #[case("Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green", 36)]
    fn example_partial(#[case] input: &str, #[case] expected: i32) {
        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }
}
