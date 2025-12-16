use std::{collections::HashMap, io::BufRead};
//use tracing::debug;

use crate::parts::{ParsedRow, Part, PartNumber, parse_line};

struct FirstNumber {
    pub id: usize,
    pub from: usize,
    pub to: usize,
}

struct Cog {
    location: usize,
}

struct NumberWithCog {
    first_number_id:  usize,
    cog_location: usize,
}

impl FirstNumber {
    fn touches(&self, cog_location: usize) -> Option<NumberWithCog> {
        let mut from = self.from;
        if from != 0 {
            from -= 1;
        }

        if cog_location >= from && cog_location <= self.to {
            return Some(NumberWithCog {
                first_number_id: self.id,
                cog_location: cog_location
            });
        }

        None
    }
}

impl NumberWithCog {
    fn touches(&self, pn: &PartNumber) -> usize {
        let mut from = pn.from;
        if from != 0 {
            from -= 1;
        }

        if self.cog_location >= from && self.cog_location <= pn.to {
            return self.first_number_id * pn.id;
        }

        0
    }
}

pub fn part2<R: BufRead>(reader: R) -> Result<usize, Box<dyn std::error::Error>> {
    let mut acc = 0;
    let mut previous_first_numbers: Vec<FirstNumber> = Vec::new();
    let mut previous_number_with_cogs: Vec<NumberWithCog> = Vec::new();

    for (y, line) in reader.lines().enumerate() {
        let line = line.unwrap();
        let (part_numbers, parts) = parse_line(line.as_str());

        let cogs: Vec<&Part> = parts.iter().filter(|p| -> bool { p.icon == '*' }).collect();

        for previous_number_with_cog in previous_number_with_cogs.iter() {
            for part_number in part_numbers.iter() {
                acc += previous_number_with_cog.touches(part_number);
            }
        }

        previous_number_with_cogs = Vec::new();
        for previous_first_number in previous_first_numbers.iter() {
            for cog in cogs.iter() {
                match previous_first_number.touches(cog.location) {
                    Some(pnwc)=> previous_number_with_cogs.push(pnwc),
                    None => (),
                }
            }
        }
    }

    Ok(acc)
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
