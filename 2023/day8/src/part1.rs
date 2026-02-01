use regex::Regex;
use std::collections::HashMap;
use std::io::BufRead;

pub fn part1<R: BufRead>(reader: R) -> Result<usize, Box<dyn std::error::Error>> {
    let (sequence, map) = parse_input(reader);

    let mut i = 0;
    let mut current_id = &String::from("AAA");

    loop {
        match sequence[i % sequence.len()] {
            'L' => {
                current_id = &map.get(current_id).expect("missing").left;
            }
            'R' => current_id = &map.get(current_id).expect("missing").right,
            _ => panic!("bad sequence"),
        }

        if current_id == "ZZZ" {
            break;
        }

        i += 1;
    }

    Ok(i + 1)
}

fn parse_input<R: BufRead>(reader: R) -> (Vec<char>, HashMap<String, Box<Node>>) {
    let mut lines = reader.lines();
    let sequence = lines.next().unwrap().expect("could not parse sequence");
    let _blank = lines.next().unwrap().expect("could not parse sequence");

    let re = Regex::new(r"(\w+) = \((\w+), (\w+)\)").unwrap();

    // let nodeMapping: HashMap<String, Box<Node>> = HashMap::new();
    let node_mapping: HashMap<String, Box<Node>> =
        lines
            .into_iter()
            .map(|x| x.unwrap())
            .fold(HashMap::new(), |mut acc, line| {
                let caps = re.captures(&line).expect("ffs");
                let id = &caps[1];
                let left = &caps[2];
                let right = &caps[3];

                acc.insert(
                    id.to_string(),
                    Box::new(Node {
                        left: left.to_string(),
                        right: right.to_string(),
                    }),
                );
                acc
            });

    let seq = sequence.chars().collect();

    return (seq, node_mapping);
}

struct Node {
    left: String,
    right: String,
}

#[cfg(test)]
mod test_part_1 {
    use super::*;
    use std::io::Cursor;

    #[test]
    fn example_1() {
        let input = r#"RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)"#;
        let expected = 2;

        let cur = Cursor::new(input.as_bytes());
        let result = part1(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[test]
    fn example_2() {
        let input = r#"LLR

AAA = (BBB, BBB)
BBB = (AAA, ZZZ)
ZZZ = (ZZZ, ZZZ)"#;
        let expected = 6;

        let cur = Cursor::new(input.as_bytes());
        let result = part1(cur).unwrap();

        assert_eq!(result, expected);
    }
}
