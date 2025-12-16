use regex::Regex;

#[derive(Debug)]
pub struct PartNumber {
    pub id: usize,
    pub from: usize,
    pub to: usize,
}

#[derive(Debug)]
pub struct Part {
    pub icon: char,
    pub location: usize,
}

pub type ParsedRow = (Vec<PartNumber>, Vec<Part>);



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