use array_tool::vec::Intersect;

use std::fs::File;
use std::io::{BufRead, BufReader};
use std::path::Path;

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_part1() {
        let test_str = "vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part1(test_data), 157);
    }

    #[test]
    fn test_part2() {
        let test_str = "vJrwpWtwJgWrhcsFMMfFFhFp
jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
PmmdzqPrVvPwwTWBwg
wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
ttgJtRGJQctTZtZT
CrZsJsPPZsGzwwsLwLmpwMDw";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part2(test_data), 70);
    }
}

fn letter_score(c: char) -> i32 {
    1 + if c.is_lowercase() {
        c as i32 - 'a' as i32
    } else {
        c as i32 - 'A' as i32 + 26
    }
}

fn part1a(line: &String) -> i32 {
    let l = line.len() / 2;
    let (r0, r1) = line.split_at(l);
    r0.chars()
        .collect::<Vec<char>>()
        .intersect(r1.chars().collect())
        .iter()
        .fold(0, |acc, &c| acc + letter_score(c))
}

fn part1(lines: Vec<String>) -> i32 {
    lines.iter().fold(0, |acc, l| acc + part1a(l))
}

fn to_chars(lines: &[String], idx: usize) -> Vec<char> {
    lines
        .iter()
        .nth(idx)
        .expect("Unable to find it!")
        .chars()
        .collect()
}

fn part2(lines: Vec<String>) -> i32 {
    lines.chunks(3).fold(0, |acc, rs| {
        acc + letter_score(
            *to_chars(rs, 0)
                .intersect(to_chars(rs, 1))
                .intersect(to_chars(rs, 2))
                .iter()
                .nth(0)
                .expect("No intersection found!"),
        )
    })
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
