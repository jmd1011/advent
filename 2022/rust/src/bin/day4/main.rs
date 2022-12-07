use std::path::Path;
use std::fs::File;
use std::io::{BufRead, BufReader};

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_part1() {
        let test_str =
"2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part1(&test_data), 2);
    }

    #[test]
    fn test_part2() {
        let test_str =
"2-4,6-8
2-3,4-5
5-7,7-9
2-8,3-7
6-6,4-6
2-6,4-8";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part2(&test_data), 4);
    }
}

fn make_pairs(s: &str) -> (i32, i32) {
    let ss = s.split("-").collect::<Vec<&str>>();
    (ss[0].parse().expect("No"), ss[1].parse().expect("No"))
}

fn do_work(lines: &Vec<String>, cmp_fn: &dyn Fn(((i32, i32), (i32, i32))) -> i32) -> i32 {
    lines.iter().fold(0, |acc, l|  {
        let pairs = l.split(",").take(2).map(make_pairs).collect::<Vec<_>>();
        let p_pairs = (pairs[0], pairs[1]);
        acc + cmp_fn(p_pairs)
    })
}

fn part1(lines: &Vec<String>) -> i32 {
    do_work(lines, &|(first1, second): ((i32, i32), (i32, i32))|
        (first1.0 <= second.0 && first1.1 >= second.1 || second.0 <= first1.0 && second.1 >= first1.1) as i32)
}

fn part2(lines: &Vec<String>) -> i32 {
    do_work(lines, &|(first, second): ((i32, i32), (i32, i32))|
        (std::cmp::max(first.0, second.0) <= std::cmp::min(first.1, second.1)) as i32)
}

fn main() {
    let data = parse("./input/day4");
    println!("{:}", part1(&data));
    println!("{:}", part2(&data));
}

fn parse(filename: impl AsRef<Path>) -> Vec<String> {
    let file = File::open(filename).expect("no such file");
    let buf = BufReader::new(file);
    buf.lines()
        .map(|l| l.expect("Could not parse line"))
        .collect()
}
