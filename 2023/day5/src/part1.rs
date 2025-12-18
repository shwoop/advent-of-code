use std::io::BufRead;
use std::iter::once;

struct IdMapping {
    source_from: usize,
    source_to: usize,
    target: usize,
}

struct Accumulator {
    ids: Vec<usize>,
    mapping: Vec<IdMapping>,
}

impl Accumulator {
    fn new() -> Self {
        Self {
            ids: vec![],
            mapping: Vec::new(),
        }
    }
}

pub fn part1<R: BufRead>(reader: R) -> Result<usize, Box<dyn std::error::Error>> {
    let Accumulator { ids, mapping: _ } = reader
        .lines()
        .chain(once(Ok(String::new()))) // chain on an extra blank line to trigger processing of the final mapping
        .map(|line: Result<String, std::io::Error>| -> String { line.unwrap() })
        .fold(Accumulator::new(), |mut acc, line: String| -> Accumulator {
            if line.starts_with("seeds:") {
                if let Some((_, seeds)) = line.split_once(":") {
                    return Accumulator {
                        ids: seeds
                            .split_whitespace()
                            .map(|x| -> usize { x.parse::<usize>().unwrap() })
                            .collect(),
                        mapping: Vec::new(),
                    };
                } else {
                    panic!("found seeds twice!");
                }
            }

            if line.contains(":") {
                // ignore lines naming mapping
                return acc;
            }

            if line.is_empty() {
                // apply map on newline following definition

                return Accumulator {
                    ids: acc
                        .ids
                        .iter()
                        .map(|x| -> usize {
                            for mapping in acc.mapping.iter() {
                                if *x >= mapping.source_from && *x < mapping.source_to {
                                    let y = mapping.target + *x - mapping.source_from;

                                    // println!("{x} => {y}");
                                    return y;
                                }
                            }

                            // println!("{x} => {x}");
                            *x
                        })
                        .collect(),
                    mapping: Vec::new(),
                };
            }

            let encoded_mapping: Vec<usize> = line
                .split_whitespace()
                .map(|x| -> usize { x.parse::<usize>().unwrap() })
                .collect();
            let [target_root, source_root, range] = encoded_mapping.as_slice() else {
                panic!("invalid mapping");
            };

            acc.mapping.push(IdMapping {
                source_from: *source_root,
                source_to: source_root + range,
                target: *target_root,
            });

            acc
        });
    let min = ids.iter().min().unwrap();

    Ok(*min)
}

#[cfg(test)]
mod test_part_1 {
    use super::*;
    use rstest::rstest;
    use std::io::Cursor;

    #[test]
    fn example() {
        let input = r#"seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"#;
        let expected = 35;

        let cur = Cursor::new(input.as_bytes());
        let result = part1(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[rstest]
    #[case("seeds: 79", 82)]
    #[case("seeds: 14", 43)]
    #[case("seeds: 55", 86)]
    #[case("seeds: 13", 35)]
    fn example_split_numbers(#[case] input: &str, #[case] expected: usize) {
        let common = r#"
seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"#;

        let joined = format!("{input}\n{common}");
        let cur = Cursor::new(joined.as_bytes());
        let result = part1(cur).unwrap();

        assert_eq!(result, expected);
    }
}
