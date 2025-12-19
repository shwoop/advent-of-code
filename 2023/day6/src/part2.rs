use std::io::BufRead;

pub fn part2<R: BufRead>(reader: R) -> Result<usize, Box<dyn std::error::Error>> {
    let mut lines = reader.lines();
    let Ok(time_line) = lines.next().unwrap() else {
        panic!("no input")
    };
    let Ok(distance_line) = lines.next().unwrap() else {
        panic!("no input")
    };

    let time = parse_line(time_line);
    let distance = parse_line(distance_line);

    let acc = check_game(time, distance);

    Ok(acc)
}

fn check_game(t: usize, d: usize) -> usize {
    (1..t)
        .map(|n| {
            let dist = n * (t - n);
            if dist > d {
                // println!("{}ps * {} = {} +1", n, t-n, dist);
                return 1;
            }
            // println!("{}ps * {} = {} 0", n, t-n, dist);
            0
        })
        .sum()
}

fn parse_line(line: String) -> usize {
    let Some((_, number_string)) = line.split_once(":") else {
        panic!("cannot parse numbers")
    };

    let n: String = number_string
        .chars()
        .filter(|x| !x.is_whitespace())
        .collect();

    n.parse().unwrap()
}

#[cfg(test)]
mod test_part_2 {
    use super::*;
    use rstest::rstest;
    use std::io::Cursor;

    #[test]
    fn example() {
        let input = r#"Time:      7  15   30
Distance:  9  40  200"#;
        let expected = 71503;

        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[rstest]
    #[case(("7","9"), 4)]
    #[case(("15","40"), 8)]
    #[case(("30","200"), 9)]
    #[case(("1 5","4 0"), 8)]
    fn partial(#[case] (time, dist): (&str, &str), #[case] expected: usize) {
        let joined = format!("Time: {}\nDistance: {}\n", time, dist);
        let cur = Cursor::new(joined.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }
}
