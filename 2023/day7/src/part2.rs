use std::cmp::Ordering;
use std::collections::{BTreeSet, HashMap};
use std::io::BufRead;

pub fn part2<R: BufRead>(reader: R) -> Result<usize, Box<dyn std::error::Error>> {
    let result = reader
        .lines()
        .map(|x| x.unwrap())
        .map(Bid::parse)
        // .inspect(|x| {
        //     dbg!(x);
        // })
        .collect::<BTreeSet<Bid>>()
        .iter()
        .enumerate()
        .fold(0, |acc, (i, bid)| acc + (i + 1) * bid.amount);

    Ok(result)
}

#[derive(Debug, PartialEq, Eq, PartialOrd, Ord)]
enum HandType {
    HighCard = 0,
    OnePair = 1,
    TwoPair = 2,
    ThreeOfAKind = 3,
    FullHouse = 4,
    FourOfAKind = 5,
    FiveOfAKind = 6,
}

#[derive(Debug, PartialEq, Eq)]
struct Bid {
    hand_type: HandType,
    cards: String,
    amount: usize,
}

impl Bid {
    fn parse(line: String) -> Self {
        let Some((cards, amount)) = line.split_once(" ") else {
            panic!("cannot parse numbers")
        };

        // count cards
        let mut map: HashMap<char, usize> = cards.chars().fold(HashMap::new(), |mut acc, n| {
            match acc.get(&n) {
                Some(x) => {
                    acc.insert(n, x + 1);
                }
                _ => {
                    acc.insert(n, 1);
                }
            }
            acc
        });

        let mut jokers = map.remove(&'J').unwrap_or_default();

        // sort counts
        let mut counts: Vec<&usize> = map.values().collect();
        counts.sort();

        let highest: usize;
        let mut second_highest = 0;

        match counts.len() {
            0 => {
                highest = jokers;
                jokers = 0
            }
            1 => highest = *counts[counts.len() - 1],
            _ => {
                highest = *counts[counts.len() - 1];
                second_highest = *counts[counts.len() - 2];
            }
        }

        // identify hand
        let hand_type = match (highest, second_highest, jokers) {
            (f, _, j) if f + j >= 5 => HandType::FiveOfAKind,
            (f, _, j) if f + j >= 4 => HandType::FourOfAKind,
            (3, 2, _) | (2, 2, 1) => HandType::FullHouse,
            (3, _, 0) | (2, _, 1) | (1, _, 2) => HandType::ThreeOfAKind,
            (2, 2, 0) => HandType::TwoPair,
            (2, _, _) | (1, _, 1) => HandType::OnePair,
            (1, _, _) => HandType::HighCard,
            _ => panic!("wtf"),
        };

        Self {
            hand_type,
            cards: String::from(cards),
            amount: amount.parse().unwrap(),
        }
    }
}

impl Ord for Bid {
    fn cmp(&self, other: &Self) -> Ordering {
        match self.hand_type.cmp(&other.hand_type) {
            Ordering::Equal => {
                let other_characters: Vec<char> = other.cards.chars().collect();
                for (i, c) in self.cards.char_indices() {
                    match CamelCard(c).cmp(&CamelCard(other_characters[i])) {
                        Ordering::Equal => continue,
                        x => return x,
                    }
                }
                panic!("arse");
            }
            x => x,
        }
    }
}

impl PartialOrd for Bid {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

#[derive(Debug, PartialEq, Eq)]
struct CamelCard(char);

impl Ord for CamelCard {
    fn cmp(&self, other: &Self) -> Ordering {
        let priority = HashMap::from([
            ('J', 1),
            ('2', 2),
            ('3', 3),
            ('4', 4),
            ('5', 5),
            ('6', 6),
            ('7', 7),
            ('8', 8),
            ('9', 9),
            ('T', 10),
            ('Q', 12),
            ('K', 13),
            ('A', 14),
        ]);
        priority.get(&self.0).cmp(&priority.get(&other.0))
    }
}

impl PartialOrd for CamelCard {
    fn partial_cmp(&self, other: &Self) -> Option<Ordering> {
        Some(self.cmp(other))
    }
}

#[cfg(test)]
mod test_part_2 {
    use super::*;
    // use rstest::rstest;
    use std::io::Cursor;

    #[test]
    fn example() {
        let input = r#"32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483"#;
        let expected = 5905;

        let cur = Cursor::new(input.as_bytes());
        let result = part2(cur).unwrap();

        assert_eq!(result, expected);
    }
}

#[cfg(test)]
mod test_bid {
    use super::*;
    use rstest::rstest;

    #[rstest]
    #[case("32T3K 765", Bid{hand_type: HandType::OnePair, cards: String::from("32T3K"), amount: 765})]
    #[case("KK677 28", Bid{hand_type: HandType::TwoPair, cards: String::from("KK677"), amount: 28})]
    #[case("T55J5 684", Bid{hand_type: HandType::FourOfAKind, cards: String::from("T55J5"), amount: 684})]
    #[case("KTJJT 220", Bid{hand_type: HandType::FourOfAKind, cards: String::from("KTJJT"), amount: 220})]
    #[case("QQQJA 483", Bid{hand_type: HandType::FourOfAKind, cards: String::from("QQQJA"), amount: 483})]
    fn parse(#[case] line: String, #[case] expected: Bid) {
        let result = Bid::parse(line);

        assert_eq!(result, expected);
    }
}
