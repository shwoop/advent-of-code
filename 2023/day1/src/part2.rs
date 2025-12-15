use regex::Regex;
use std::collections::HashMap;
use std::io::BufRead;

pub fn part2<R: BufRead>(reader: R) -> Result<i32, Box<dyn std::error::Error>> {
    let re =
        Regex::new(r"(\d|(three)|(seven)|(eight)|(four)|(five)|(nine)|(one)|(two)|(six))").unwrap();

    let mut string_to_digit: HashMap<&str, i32> = HashMap::new();
    string_to_digit.insert("1", 1);
    string_to_digit.insert("one", 1);

    string_to_digit.insert("2", 2);
    string_to_digit.insert("two", 2);

    string_to_digit.insert("3", 3);
    string_to_digit.insert("three", 3);

    string_to_digit.insert("4", 4);
    string_to_digit.insert("four", 4);

    string_to_digit.insert("5", 5);
    string_to_digit.insert("five", 5);

    string_to_digit.insert("6", 6);
    string_to_digit.insert("six", 6);

    string_to_digit.insert("7", 7);
    string_to_digit.insert("seven", 7);

    string_to_digit.insert("8", 8);
    string_to_digit.insert("eight", 8);

    string_to_digit.insert("9", 9);
    string_to_digit.insert("nine", 9);

    let mut acc = 0;

    for line in reader.lines() {
        let line = line?;
        let mut first: i32 = -1;
        let mut last: i32 = -1;

        let mut start = 0;
        while start < line.len() {
            if let Some(mat) = re.find(&line[start..]) {
                last = *string_to_digit
                    .get(&line[(start + mat.start())..(start + mat.end())])
                    .unwrap();
                if first == -1 {
                    first = last
                }
                start += 1;
            } else {
                break;
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

    fn run_test_part2(input: &str, expectected: i32) {
        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();
        assert_eq!(result, expectected);
    }

    #[test]
    fn part2_example() {
        let example = r#"two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen"#;

        run_test_part2(example, 281);
    }

    #[rstest]
    #[case("two1nine", 29)]
    #[case("eightwothree", 83)]
    #[case("abcone2threexyz", 13)]
    #[case("xtwone3four", 24)]
    #[case("4nineeightseven2", 42)]
    #[case("zoneight234", 14)]
    #[case("7pqrstsixteen", 76)]
    #[case("4two5two9xcpkkjqxcfivessqqvhbbt", 45)]
    #[case("ncnqg1sixt9ninedlfgsqhnxx6", 16)]
    #[case("xrlsktwodnbcbonefvxxqgbrsdthree3seven", 27)]
    #[case("nineninelnknxhbfk4xssrlsdmsixoneltjseightwofzf", 92)]
    fn part2_example_partial(#[case] input: &str, #[case] expected: i32) {
        run_test_part2(input, expected);
    }
}
