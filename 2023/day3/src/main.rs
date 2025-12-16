use std::env;
use std::fs::File;
use std::io::BufReader;
use tracing_subscriber::{EnvFilter, fmt, prelude::*};


mod part1;
// mod part2;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let file = File::open("input.txt")?;
    let reader = BufReader::new(file);

    tracing_subscriber::registry()
        .with(fmt::layer())
        .with(EnvFilter::from_default_env())
        .init();

    if let Ok(s) = env::var("PART")
        && s == "2"
    {
        //let result = part2::part2(reader)?;
        let result = 0;
        println!("result 2 is {}", result);
    } else {
        let result = part1::part1(reader)?;
        println!("result 1 is {}", result);
    }

    Ok(())
}
