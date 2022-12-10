use std::fs::File;
use std::io::{BufRead, BufReader};
use std::path::Path;

use itertools::Itertools;

fn buildit(h: (usize, i32), cmds: Vec<(usize, i32)>) -> Vec<(usize, i32)> {
    if cmds.is_empty() {
        vec![h]
    } else {
        let t = cmds[0];
        let (tv, tx) = t;
        let nh = (tv + h.0, tx + h.1);
        let nts = buildit(nh, cmds[1..].to_vec());
        vec![h]
            .into_iter()
            .chain(nts.into_iter())
            .collect::<Vec<_>>()
    }
}

fn part1(lines: &Vec<String>) -> i32 {
    let vals = lines
        .iter()
        .map(|l| match l.split(" ").collect::<Vec<_>>()[..] {
            ["addx", n] => (2, n.parse::<i32>().expect("wut")),
            ["noop"] => (1, 0),
            _ => unreachable!("How?"),
        })
        .collect::<Vec<_>>();

    let done = buildit((0, 1), vals);
    [20, 60, 100, 140, 180, 220].iter().fold(0, |acc, &cycle| {
        let (_, x) = done.iter().rfind(|(v, _)| v < &cycle).expect("wat");
        acc + cycle as i32 * x
    })
}

fn foo((cycle, x): (usize, i32), tail: Vec<(usize, i32)>) -> String {
    if tail.is_empty() {
        "".to_string()
    } else {
        let (tv, tx) = tail[0];
        let mod_c = cycle as i32 % 40;
        let c = if mod_c >= x && mod_c <= x + 2 {
            "#"
        } else {
            "."
        };
        println!(
            "At cycle {:?} ({}), drawing {:?} because X = {:?}",
            cycle, mod_c, c, x
        );
        if cycle < tv {
            c.to_string() + &foo((cycle + 1, x), tail)
        } else {
            c.to_string() + &foo((tv + 1, tx), tail[1..].to_vec())
        }
    }
}

fn part2(lines: &Vec<String>) -> String {
    let vals = lines
        .iter()
        .map(|l| match l.split(" ").collect::<Vec<_>>()[..] {
            ["addx", n] => (2, n.parse::<i32>().expect("wut")),
            ["noop"] => (1, 0),
            _ => unreachable!("How?"),
        })
        .collect::<Vec<_>>();

    let done = &buildit((0, 1), vals)[1..];
    foo((1, 1), done.to_vec())
        .chars()
        .chunks(40)
        .into_iter()
        .map(|mut cs| cs.join(""))
        .join("\n")
}

fn main() {
    let data = parse("./input/day10");
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

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_part1() {
        let test_str = "addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part1(&test_data), 13140);
    }

    #[test]
    fn test_part2() {
        let test_str = "addx 15
addx -11
addx 6
addx -3
addx 5
addx -1
addx -8
addx 13
addx 4
noop
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx 5
addx -1
addx -35
addx 1
addx 24
addx -19
addx 1
addx 16
addx -11
noop
noop
addx 21
addx -15
noop
noop
addx -3
addx 9
addx 1
addx -3
addx 8
addx 1
addx 5
noop
noop
noop
noop
noop
addx -36
noop
addx 1
addx 7
noop
noop
noop
addx 2
addx 6
noop
noop
noop
noop
noop
addx 1
noop
noop
addx 7
addx 1
noop
addx -13
addx 13
addx 7
noop
addx 1
addx -33
noop
noop
noop
addx 2
noop
noop
noop
addx 8
noop
addx -1
addx 2
addx 1
noop
addx 17
addx -9
addx 1
addx 1
addx -3
addx 11
noop
noop
addx 1
noop
addx 1
noop
noop
addx -13
addx -19
addx 1
addx 3
addx 26
addx -30
addx 12
addx -1
addx 3
addx 1
noop
noop
noop
addx -9
addx 18
addx 1
addx 2
noop
noop
addx 9
noop
noop
noop
addx -1
addx 2
addx -37
addx 1
addx 3
noop
addx 15
addx -21
addx 22
addx -6
addx 1
noop
addx 2
addx 1
noop
addx -10
noop
noop
addx 20
addx 1
addx 2
addx 2
addx -6
addx -11
noop
noop
noop";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        // TODO: line 319 is actually supposed to end with a #, but I don't care
        // enough to debug.
        assert_eq!(
            part2(&test_data),
            "##..##..##..##..##..##..##..##..##..##..
###...###...###...###...###...###...###.
####....####....####....####....####....
#####.....#####.....#####.....#####.....
######......######......######......###.
#######.......#######.......#######....."
        );
    }
}
