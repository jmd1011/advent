use std::fs::File;
use std::io::{BufRead, BufReader};
use std::path::Path;

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_part1() {
        let test_str = "1000
2000
3000

4000

5000
6000

7000
8000
9000

10000";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part1(test_data), 24000);
    }
}

fn do_work(lines: Vec<String>, take: usize) -> i32 {
    let mut d = lines
        .iter()
        .fold((vec![], 0), |(mut sums, sum), l| match l.as_str() {
            "" => {
                sums.push(sum);
                (sums, 0)
            }
            _ => (sums, sum + l.parse::<i32>().unwrap()),
        })
        .0;
    d.sort();
    d.iter().rev().take(take).sum()
}

fn part1(lines: Vec<String>) -> i32 {
    do_work(lines, 1)
    // lines.iter().fold((0, 0), |(max, sum), l| match l.as_str() {
    //     "" => (cmp::max(max, sum), 0),
    //     _ => (max, sum + l.parse::<i32>().unwrap())
    // }).0
}

fn part2(lines: Vec<String>) -> i32 {
    do_work(lines, 3)
    // let mut d = lines.iter().fold((vec![], 0), |(mut sums, sum), l| match l.as_str() {
    //     "" => {
    //         sums.push(sum);
    //         (sums, 0)
    //     },
    //     _ => (sums, sum + l.parse::<i32>().unwrap())
    // }).0;
    // d.sort();
    // d.iter().rev().take(3).sum()
}

fn main() {
    let data = parse("./input/day1_a");
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
