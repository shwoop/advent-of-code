use crate::parts::parse_line;
use std::collections::{HashMap, HashSet};
use std::io::BufRead;
use std::vec;

struct Cog {
    x: usize,
    y: usize,
}

pub fn part2<R: BufRead>(reader: R) -> Result<usize, Box<dyn std::error::Error>> {
    let mut acc = 0;
    let mut cogs = Vec::new();
    let mut numbers_lookup: HashMap<(usize, usize), usize> = HashMap::new();

    for (y, line) in reader.lines().enumerate() {
        let line = line.unwrap();

        let (part_numbers, parts) = parse_line(line.as_str());
        for part_number in part_numbers.iter() {
            for x in part_number.from..part_number.to {
                numbers_lookup.insert((x, y), part_number.id);
            }
        }

        cogs.extend(
            parts.iter()
            .filter(| part | -> bool { part.icon == '*' })
            .map(| part | -> Cog {
                Cog { x: part.location, y: y }
            })
        );
    }

    acc += cogs.iter()
    .map(| cog | -> Vec<usize> {
        positions_around(cog.x, cog.y).iter()
        .map(|pos| -> usize {
            if let Some(n) = numbers_lookup.get(pos) {
                return *n;
            }
            0
        })
        .filter(|n| -> bool { *n != 0 })
        .collect::<HashSet<_>>()
        .into_iter()
        .collect::<Vec<usize>>()
    })
    .filter(| v | -> bool { v.len() == 2 })
    .fold(0, | acc, v | -> usize {
        acc + v[0] * v[1]
    });

    Ok(acc)
}

fn positions_around(x: usize, y: usize) -> Vec<(usize, usize)> {
    vec![
        (x.saturating_sub(1), y.saturating_sub(1)),
        (x, y.saturating_sub(1)),
        (x + 1, y.saturating_sub(1)),
        (x.saturating_sub(1), y),
        // x,y
        (x + 1, y),
        (x.saturating_sub(1), y + 1),
        (x, y + 1),
        (x + 1, y + 1),
    ]
}

#[cfg(test)]
mod test_part_2 {
    use super::*;
    use rstest::rstest;
    use std::io::Cursor;

    #[test]
    fn example() {
        let input = r#"467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."#;
        let expected = 467835;

        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[test]
    fn partial_multiline_1() {
        let input = r#"467..114..
...*......
..35..633."#;
        let expected = 467 * 35;

        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[test]
    fn partial_multiline_2() {
        let input = r#"......755.
...$.*....
.664.598.."#;
        let expected = 755 * 598;

        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[test]
    fn partial_multiline_nothing() {
        let input = r#"......#...
617*......
.....+.58."#;
        let expected = 0;

        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[rstest]
    #[case(r"617*......")]
    #[case(r"617*.1....")]
    #[case(r"617&11....")]
    fn partial_nothing(#[case] input: &str) {
        let expected = 0;

        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[rstest]
    #[case(r".17*2.....", 34)]
    #[case(r".17*2..3*2", 40)]
    fn partial_same_line(#[case] input: &str, #[case] expected: usize) {
        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }
}
