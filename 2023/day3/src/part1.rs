use std::io::BufRead;
use tracing::debug;

use crate::parts::{ParsedRow,Part,PartNumber,parse_line};

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

pub fn check_collisions(
    line_length: usize,
    previous_row: Option<ParsedRow>,
    part_numbers: &mut Vec<PartNumber>,
    parts: &Vec<Part>,
) -> usize {
    let mut acc: usize = 0;
    let mut parts_to_remove: Vec<usize> = Vec::new();

    // check current row
    for (i, part_number) in part_numbers.iter().enumerate() {
        for part in parts.iter() {
            if (part_number.from != 0 && part_number.from - 1 == part.location)
                || (part_number.to != line_length && part_number.to == part.location)
            {
                // matched
                acc += part_number.id;
                parts_to_remove.push(i);

                debug!("{} - {}", part_number.id, part.icon);
            }
        }
    }

    // delete matched part numbers from current row before checking against other rows
    parts_to_remove.reverse();
    for i in parts_to_remove {
        part_numbers.remove(i);
    }

    if let Some((previous_part_numbers, previous_parts)) = previous_row {
        // check previous row ids
        for part_number in previous_part_numbers.iter() {
            let mut from = part_number.from;
            let to = part_number.to;
            if from != 0 {
                from -= 1
            }
            for part in parts.iter() {
                if part.location >= from && part.location <= to {
                    acc += part_number.id;
                    debug!("{} - {}", part_number.id, part.icon);
                }
            }
        }

        // check previous row
        for part_number in part_numbers {
            let mut from = part_number.from;
            let to = part_number.to;
            if from != 0 {
                from -= 1
            }
            for previous_part in previous_parts.iter() {
                if previous_part.location >= from && previous_part.location <= to {
                    debug!("{} - {}", part_number.id, previous_part.icon);
                    acc += part_number.id;
                }
            }
        }
    }

    acc
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
