
use std::env;
use std::fs::File;
use std::io::BufReader;

mod part1;
mod part2;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let file = File::open("input.txt")?;
    let reader = BufReader::new(file);

    if env::var("PART").unwrap() == "2" {
        let result = part2::part2(reader)?;
        println!("result 2 is {}", result);
    } else {
        let result = part1::part1(reader)?;
        println!("result 1 is {}", result);
    }

    Ok(())
}
