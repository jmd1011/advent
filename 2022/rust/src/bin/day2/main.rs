use std::path::Path;
use std::fs::File;
use std::io::{BufRead, BufReader};

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_part1() {
        let test_str =
"A Y
B X
C Z";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part1(test_data), 15);
    }

        #[test]
    fn test_part2() {
        let test_str =
"A Y
B X
C Z";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part2(test_data), 12);
    }
}

fn win_score(p: (&str, &str)) -> i32 {
    match p {
        (e, m) if m == get_win(e) => 6,
        (e, m) if m == get_tie(e) => 3,
        _ => 0
    }
}

fn get_win(e: &str) -> &str {
    match e {
        "A" => "Y",
        "B" => "Z",
        "C" => "X",
        &_ => unreachable!()
    }
}

fn get_tie(e: &str) -> &str {
    match e {
        "A" => "X",
        "B" => "Y",
        "C" => "Z",
        &_ => unreachable!()
    }
}

fn get_loss(e: &str) -> &str {
    match e {
        "A" => "Z",
        "B" => "X",
        "C" => "Y",
        &_ => unreachable!()
    }
}

fn score(p: (&str, &str)) -> i32 {
    (3 - ('Z' as i32 - p.1.chars().nth(0).expect("Couldn't") as i32)) + win_score(p)
}

fn part1(lines: Vec<String>) -> i32 {
    lines.iter()
         .map(|l| l.split(" ").collect::<Vec<&str>>())
         .map(|v| match &v[..] { &[a, b, ..] => (a, b), _ => unreachable!() })
         .map(|z| score(z))
         .sum()
}

fn part2(lines: Vec<String>) -> i32 {
    lines.iter()
         .map(|l| l.split(" ").collect::<Vec<&str>>())
         .map(|v| match &v[..] { &[a, b, ..] => (a, b), _ => unreachable!() })
         .map(|z| match z {
            (e, "X") => score((e, get_loss(e))),
            (e, "Y") => score((e, get_tie(e))),
            (e, "Z") => score((e, get_win(e))),
            _ => unreachable!()
            })
         .sum()
}

fn main() {
    let data = parse("./input/day2");
    println!("{:}", part1(data.clone()));
    println!("{:}", part2(data.clone()));
}

fn parse(filename: impl AsRef<Path>) -> Vec<String> {
    let file = File::open(filename).expect("no such file");
    let buf = BufReader::new(file);
    buf.lines()
        .map(|l| l.expect("Could not parse line"))
        .collect()
}
