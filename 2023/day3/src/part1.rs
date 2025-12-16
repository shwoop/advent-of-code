use std::io::BufRead;

use crate::parts::{ParsedRow,check_collisions,parse_line};

pub fn part1<R: BufRead>(reader: R) -> Result<usize, Box<dyn std::error::Error>> {
    let mut acc = 0;
    let mut previous_row: Option<ParsedRow> = None;

    for line in reader.lines() {
        let line = line.unwrap();
        let (mut part_numbers, parts) = parse_line(line.as_str());

        acc += check_collisions(line.len(), previous_row, &mut part_numbers, &parts);

        previous_row = Some((part_numbers, parts));
    }

    Ok(acc)
}


#[cfg(test)]
mod test_part_1 {
    use super::*;
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
        let expected = 4361;

        let cur = Cursor::new(input.as_bytes());
        let result = part1(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[test]
    fn partial_id_before() {
        let input = r#"467..114..
...*......"#;
        let expected = 467;

        let cur = Cursor::new(input.as_bytes());
        let result = part1(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[test]
    fn partial_id_after() {
        let input = r#"...*......
..35..633."#;
        let expected = 35;

        let cur = Cursor::new(input.as_bytes());
        let result = part1(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[test]
    fn partial_same_line() {
        let input = r"617*......";
        let expected = 617;

        let cur = Cursor::new(input.as_bytes());
        let result = part1(cur).unwrap();

        assert_eq!(result, expected);
    }
}
