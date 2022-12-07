use std::collections::VecDeque;
use std::path::Path;
use std::fs::File;
use std::io::{BufRead, BufReader};
use itertools::Itertools;

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_part1() {
        let test_str ="mjqjpqmgbljsphdztnvjfqwrcgsmlb";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part1(&test_data), 7);
    }

    #[test]
    fn test_part2() {
        let test_str ="mjqjpqmgbljsphdztnvjfqwrcgsmlb";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part2(&test_data), 19);
    }
}

fn do_work(line: &String, n: usize) -> usize {
    let mut queue: std::collections::VecDeque<char> = VecDeque::new();
    line.chars().enumerate().fold(0, |acc, (i, c)| {
        if acc == 0 {
            if queue.len() >= n {
                queue.pop_front();
            }
            queue.push_back(c);
            if queue.clone().into_iter().unique().collect::<Vec<_>>().len() == n {
                i + 1
            } else {
                acc
            }
        } else {
            acc
        }
    })
}

fn part1(line: &String) -> usize {
    do_work(line, 4)
}

fn part2(line: &String) -> usize {
    do_work(line, 14)
}

fn main() {
    let data = parse("./input/day6");
    println!("{:}", part1(&data));
    println!("{:}", part2(&data));
}

fn parse(filename: impl AsRef<Path>) -> String {
    let file = File::open(filename).expect("no such file");
    let buf = BufReader::new(file);
    buf.lines()
        .map(|l| l.expect("Could not parse line")).nth(0).expect("No worky")
}
