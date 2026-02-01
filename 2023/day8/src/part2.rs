use regex::Regex;
use std::collections::HashMap;
use std::io::BufRead;

pub fn part2<R: BufRead>(reader: R) -> Result<usize, Box<dyn std::error::Error>> {
    let (sequence, nodes) = parse_input(reader);

    let mut current_ids: Vec<usize> = nodes
        .iter()
        .enumerate()
        .filter(|(_, node)| node.id.chars().last().unwrap() == 'A')
        .map(|(i, _)| i)
        .collect();

    let mut cycles = Vec::new();

    for start_node in current_ids {
        let mut curr = start_node;
        let mut steps = 0;
        while !nodes[curr].is_terminus {
            let instruction = sequence[steps % sequence.len()];
            curr = match instruction {
                'L' => nodes[curr].left,
                'R' => nodes[curr].right,
                _ => panic!("bad sequence"),
            };
            steps += 1;
        }
        cycles.push(steps);
    }

    let result = cycles.into_iter().fold(1, lcm);
    Ok(result)
}

fn parse_input<R: BufRead>(reader: R) -> (Vec<char>, Vec<Node>) {
    let mut lines = reader.lines();
    let sequence = lines.next().unwrap().expect("could not parse sequence");
    let _blank = lines.next().unwrap().expect("could not parse sequence");

    let re = Regex::new(r"(\w+) = \((\w+), (\w+)\)").unwrap();

    let mut nodes: Vec<Node> = vec![];
    let mut node_mapping: HashMap<String, (usize, String, String)> = HashMap::new();
    for (i, line) in lines.into_iter().map(|x| x.unwrap()).enumerate() {
        let caps = re.captures(&line).expect("ffs");
        let id = &caps[1];
        let left = &caps[2];
        let right = &caps[3];

        nodes.push(Node {
            id: id.to_string(),
            is_terminus: id.chars().last().unwrap() == 'Z',
            left: 0,
            right: 0,
        });

        node_mapping.insert(id.to_string(), (i, left.to_string(), right.to_string()));
    }

    // set left/right indices
    for n in nodes.iter_mut() {
        let (_, left, right) = node_mapping.get(&n.id).expect("boo");

        let (left_id, _, _) = node_mapping.get(left).expect("boo");
        n.left = *left_id;

        let (right_id, _, _) = node_mapping.get(right).expect("boo");
        n.right = *right_id;
    }

    let seq = sequence.chars().collect();

    return (seq, nodes);
}

fn gcd(mut a: usize, mut b: usize) -> usize {
    while b != 0 {
        let temp = b;
        b = a % b;
        a = temp;
    }
    a
}

fn lcm(a: usize, b: usize) -> usize {
    a * (b / gcd(a, b))
}

#[derive(Debug)]
struct Node {
    id: String,
    is_terminus: bool,
    left: usize,
    right: usize,
}

#[cfg(test)]
mod test_part_2 {
    use super::*;
    use std::io::Cursor;

    #[test]
    fn example_1() {
        let input = r#"LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)"#;
        let expected = 6;

        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }
}
