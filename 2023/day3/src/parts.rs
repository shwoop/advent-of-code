use regex::Regex;
use tracing::debug;

#[derive(Debug)]
pub struct PartNumber {
    id: usize,
    from: usize,
    to: usize,
}

#[derive(Debug)]
pub struct Part {
    icon: char,
    location: usize,
}

pub type ParsedRow = (Vec<PartNumber>, Vec<Part>);

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

pub fn parse_line(line: &str) -> ParsedRow {
    let mut part_numbers: Vec<PartNumber> = Vec::new();
    let mut parts: Vec<Part> = Vec::new();

    let re = Regex::new(r"\d+").unwrap();
    for mat in re.find_iter(&line) {
        part_numbers.push(PartNumber {
            id: mat.as_str().parse::<usize>().unwrap(),
            from: mat.start(),
            to: mat.end(),
        });
    }
    for (i, char) in line.char_indices() {
        if char == '.' || char.is_numeric() {
            continue;
        }
        parts.push(Part {
            icon: char,
            location: i,
        })
    }

    (part_numbers, parts)
}