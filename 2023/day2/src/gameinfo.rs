pub struct BallDraw {
    pub red: i32,
    pub blue: i32,
    pub green: i32,
}

pub struct GameInfo {
    pub game_number: i32,
    ball_draws: Vec<BallDraw>,
}

impl GameInfo {
    pub fn can_draw_balls_with(&self, red: i32, blue: i32, green: i32) -> bool {
        self.ball_draws
            .iter()
            .enumerate()
            .all(|(_, d)| d.red <= red && d.blue <= blue && d.green <= green)
    }

    pub fn required_balls(&self) -> BallDraw {
        self.ball_draws.iter().enumerate().fold(
            BallDraw {
                red: 0,
                blue: 0,
                green: 0,
            },
            |mut bd, (_, d)| -> BallDraw {
                if d.red > bd.red {
                    bd.red = d.red
                }
                if d.blue > bd.blue {
                    bd.blue = d.blue
                }
                if d.green > bd.green {
                    bd.green = d.green
                }
                bd
            },
        )
    }

    pub fn parse_game(line: String) -> GameInfo {
        let colon_split = line.split(":");
        let parts: Vec<&str> = colon_split.collect();

        let game_number_string = parts[0].split(" ").nth(1).unwrap();
        let game_number = game_number_string.parse::<i32>().unwrap();

        let mut ball_draws = Vec::<BallDraw>::new();

        for game in parts[1].split(";") {
            let mut red = 0;
            let mut blue = 0;
            let mut green = 0;

            for specific_balls in game.split(",") {
                let ball_parts_it = specific_balls.trim().split_whitespace();
                // let (n, colour) = (ball_parts.nth(0), ball_parts.nth(1));
                let ball_parts: Vec<&str> = ball_parts_it.collect();
                match (ball_parts[0], ball_parts[1]) {
                    (n, "red") => red += n.parse::<i32>().unwrap(),
                    (n, "blue") => blue += n.parse::<i32>().unwrap(),
                    (n, "green") => green += n.parse::<i32>().unwrap(),
                    _ => (),
                }
            }
            ball_draws.push(BallDraw {
                red: red,
                blue: blue,
                green: green,
            });
        }

        GameInfo {
            game_number,
            ball_draws,
        }
    }
}
