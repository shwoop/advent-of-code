use std::io::BufRead;

pub fn part1<R: BufRead>(reader: R) -> Result<i32, Box<dyn std::error::Error>> {
    let mut acc = 0;

    for line in reader.lines() {
        let line = line?;
        let mut first: i32 = -1;
        let mut last: i32 = -1;

        for char in line.chars() {
            // original: if char >= '0' && char <= '9' {
            // first clippy refactor: if ('0'..='9').contains(&char) {   
            if char.is_ascii_digit() {  
                last = char.to_digit(10).unwrap() as i32;
                if first < 0 {
                    first = last;
                }
            }
        }

        let chars = format!("{}{}", first, last);
        let n: i32 = chars.parse().unwrap();
        acc += n;
    }

    Ok(acc)
}

#[cfg(test)]
mod tests {
    use super::*;
    use rstest::rstest;
    use std::io::Cursor;

    fn run_test_part1(input: &str, expectected: i32) {
        let cur = Cursor::new(input.as_bytes());
        let result = part1(cur).unwrap();
        assert_eq!(result, expectected);
    }

    #[test]
    fn part1_example() {
        let example = r#"1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet"#;
        run_test_part1(example, 142);
    }

    #[rstest]
    #[case("1abc2", 12)]
    #[case("pqr3stu8vwx", 38)]
    #[case("a1b2c3d4e5f", 15)]
    #[case("treb7uchet", 77)]
    fn part1_example_partial(#[case] input: &str, #[case] expected: i32) {
        run_test_part1(input, expected);
    }
}
