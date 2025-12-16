use std::{collections::HashMap, io::BufRead};
//use tracing::debug;

use crate::parts::{ParsedRow,Part,PartNumber,parse_line};


pub fn part2<R: BufRead>(reader: R) -> Result<usize, Box<dyn std::error::Error>> {
    let mut acc = 0;
    let mut previous_row: Option<ParsedRow> = None;

    let mut cogs: Vec<(usize, usize)> = Vec::new();

    let mut lines: HashMap<usize, String> = HashMap::new();

    for (y, line) in reader.lines().enumerate() {
        let line = line.unwrap();
        lines.insert(y, line.clone());

        for (x, char) in line.char_indices() {
            if char == '*' {
                cogs.push((x, y))
            }
        }
    }
    println!("{:?}", cogs);
    println!("{:?}", lines);

    Ok(acc)
}

pub fn check_cogs(
    line_length: usize,
    previous_row: Option<ParsedRow>,
    part_numbers: &Vec<PartNumber>,
    parts: &Vec<Part>,
) -> usize {
    0
}


#[cfg(test)]
mod test_part_2 {
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
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[test]
    fn partial_id_before() {
        let input = r#"467..114..
...*......"#;
        let expected = 467;

        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[test]
    fn partial_id_after() {
        let input = r#"...*......
..35..633."#;
        let expected = 35;

        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[test]
    fn partial_same_line() {
        let input = r"617*......";
        let expected = 617;

        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[test]
    fn partial_nothing() {
        let input = r#"617*......
.....+.58."#;
        let expected = 0;

        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }
}