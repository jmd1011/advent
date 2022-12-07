use std::collections::{HashMap, VecDeque};
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::path::Path;

use itertools::Itertools;

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_part1() {
        let test_str =
"$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part1(&test_data), 95437);
    }

    #[test]
    fn test_part2() {
        let test_str =
"$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part2(&test_data), 24933642);
    }
}

fn do_work(lines: &mut VecDeque<String>, dirs: &mut HashMap<String, u64>, mut parents: Vec<String>) {
    if lines.is_empty() {
        return ;
    }

    let cmd = lines.pop_front().expect("Popped an empty queue");

    if cmd == "$ ls" || cmd.starts_with("dir") {
        do_work(lines, dirs, parents)
    } else {
        let c = cmd.split(" ").collect::<Vec<_>>();
        match c[..] {
            ["$", "cd", ".."] => {
                parents.pop();
                do_work(lines, dirs, parents)
            }
            ["$", "cd", name] => {
                if name == "/" {
                    parents = vec![];
                }
                let fullname = parents.join("/") + name;
                parents.push(fullname.to_string());
                if !dirs.contains_key(&fullname) {
                    dirs.insert(fullname.to_string(), 0);
                }
                do_work(lines, dirs, parents)
            }
            [size, _] => {
                parents.iter().for_each(|p| {
                    let cur_size = dirs.get(p).expect("Unable to find");
                    dirs.insert(p.to_string(), size.parse::<u64>().expect("Can't parse") + *cur_size);
                });
                do_work(lines, dirs, parents)
            }
            _ => unreachable!("This shouldn't happen!")
        }
    }
}

fn solve(lines: &Vec<String>, f: &dyn Fn(HashMap<String, u64>) -> u64) -> u64 {
    let mut lines_deq = VecDeque::from(lines.clone());
    let mut dirs = HashMap::new();
    do_work(&mut lines_deq, &mut dirs, vec![]);
    f(dirs)
}

fn part1(lines: &Vec<String>) -> u64 {
    solve(lines, &|dirs: HashMap<String, u64>| dirs.into_values().fold(0, |acc, size| if size > 100000 { acc } else { acc + size }))
}

fn part2(lines: &Vec<String>) -> u64 {
    solve(lines, &|dirs: HashMap<String, u64>| {
        let used: u64 = *dirs.get("/").expect("wat");
        let total = 70000000 - used;
        dirs.into_values().sorted().find(|d| total + d >= 30000000).expect("Couldn't find one")
    })
}

fn main() {
    let data = parse("./input/day7");
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
