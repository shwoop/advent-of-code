use std::collections::LinkedList;
use std::io::BufRead;

struct IdMappingRange {
    source_gte: usize,
    source_lt: usize,
    target: usize,
}

struct IdMapping {
    #[allow(dead_code)]
    name: String,
    ranges: Vec<IdMappingRange>,
}

impl IdMapping {
    fn apply(&self, x: usize) -> usize {
        // println!("applying {}", self.name);

        for range in self.ranges.iter() {
            if x >= range.source_gte && x < range.source_lt {
                let to = range.target + (x - range.source_gte);
                // println!("appled {} -> {}", x, to);
                return to;
            }
        }
        // println!("appled {} -> {}", x, x);
        x
    }
}

pub fn part2<R: BufRead>(reader: R) -> Result<usize, Box<dyn std::error::Error>> {
    let mut lines: std::io::Lines<R> = reader.lines();

    let first_line = lines.next().unwrap()?;

    let Some((_, seeds)) = first_line.split_once(":") else {
        panic!("cannot parse seeds");
    };

    let seed_ranges: Vec<(usize, usize)> = seeds
        .split_whitespace()
        .map(|x| -> usize { x.parse::<usize>().unwrap() })
        .collect::<Vec<usize>>()
        .chunks_exact(2)
        .map(|c| -> (usize, usize) { (c[0], c[0] + c[1]) })
        .inspect(|(lower, upper)| {
            println!("parsed range: ({}, {}) {}", lower, upper, upper - lower)
        })
        .collect();

    let mappings: Vec<IdMapping> = lines
        .map(|line: Result<String, std::io::Error>| line.unwrap())
        .filter(|line| !line.is_empty())
        .fold(LinkedList::<IdMapping>::new(), |mut acc, line| {
            if line.contains(":") {
                let (name, _) = line.split_once(":").unwrap();
                acc.push_front(IdMapping {
                    name: String::from(name),
                    ranges: Vec::new(),
                });
                return acc;
            }

            let encoded_mapping: Vec<usize> = line
                .split_whitespace()
                .map(|x| -> usize { x.parse::<usize>().unwrap() })
                .collect();
            let [target_root, source_root, range] = encoded_mapping.as_slice() else {
                panic!("invalid mapping");
            };

            let Some(mapping) = acc.front_mut() else {
                panic!("ffs");
            };

            mapping.ranges.push(IdMappingRange {
                source_gte: *source_root,
                source_lt: source_root + range,
                target: *target_root,
            });

            acc
        })
        .into_iter()
        .rev()
        .collect();

    let mut min: usize = usize::MAX;

    for seed_id in seed_ranges
        .iter()
        .inspect(|a| println!("range: {:?}", a))
        .flat_map(|(lower, upper)| *lower..*upper)
    // .inspect(|a| println!("n: {:?}", a))
    {
        let modified_seed_id = mappings
            .iter()
            .fold(seed_id, |id, mapping| mapping.apply(id));
        if modified_seed_id < min {
            min = modified_seed_id
        }
    }

    Ok(min)
}

#[cfg(test)]
mod test_part_2 {
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
        let expected = 46;

        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }

    #[rstest]
    #[case("seeds: 79 1", 82)]
    #[case("seeds: 14 1", 43)]
    #[case("seeds: 55 1", 86)]
    #[case("seeds: 13 1", 35)]
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
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }
}
