use std::path::Path;
use std::fs::File;
use std::io::{BufRead, BufReader};

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_part1() {
        let test_str =
"    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part1(&test_data), "CMZ");
    }

    #[test]
    fn test_part2() {
        let test_str =
"    [D]    
[N] [C]    
[Z] [M] [P]
 1   2   3 

move 1 from 2 to 1
move 3 from 1 to 3
move 2 from 2 to 1
move 1 from 1 to 2";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part2(&test_data), "MCD");
    }
}

fn init_stacks(crate_line: &String) -> Vec<Vec<String>> {
    let n_crates = crate_line.chars().collect::<Vec<char>>().iter().filter(|c| c != &&' ').collect::<Vec<&char>>().len();
    vec![vec![]; n_crates]
}

fn build_stacks(lines: Vec<&&String>, stacks: &mut Vec<Vec<String>>) {
    lines.iter().rev().for_each(|s| s.chars().collect::<Vec<char>>().chunks(4).enumerate().for_each(|(i, s)| {
        let st = s.into_iter().collect::<String>();
        let stt = st.trim();
        if stt != "" { stacks[i].push(stt.to_string()) }
    }))
}

fn do_work(lines: &Vec<String>, instr_func: &dyn Fn(&mut Vec<Vec<String>>, usize, usize, usize) -> ()) -> String {
    let mut crates = lines.iter().take_while(|l| l.trim() != "").collect::<Vec<_>>();
    let instrs = lines.iter().skip(crates.len() + 1).collect::<Vec<_>>();
    let num = crates.pop().expect("yeah");
    let mut stacks = init_stacks(num);
    let crates = crates.iter().take(crates.len()).collect::<Vec<&&String>>();
    build_stacks(crates, &mut stacks);
    instrs.iter().map(|i| i.split(" ").collect::<Vec<_>>())
                 .map(|v| (v[1].parse::<usize>().expect("Unable to parse"), v[3].parse::<usize>().expect("Unable to parse"), v[5].parse::<usize>().expect("Unable to parse")))
                 .for_each(|(n, src, dst)| instr_func(&mut stacks, n, src, dst));
    stacks.iter().fold("".to_string(), |acc, stack| acc + &stack[stack.len() - 1].to_string().replace("[", "").replace("]", ""))
}

fn part1(lines: &Vec<String>) -> String {
    do_work(lines, &|stacks: &mut Vec<Vec<String>>, n: usize, src: usize, dst: usize| {
        for _ in 0..n {
            let r = stacks[src - 1].pop().expect("Empty stack!");
            stacks[dst - 1].push(r);
        }
    })
}

fn part2(lines: &Vec<String>) -> String {
    do_work(lines, &|stacks: &mut Vec<Vec<String>>, n: usize, src: usize, dst: usize| {
        stacks.clone()[src - 1].iter().rev().take(n).rev().for_each(|c| stacks[dst - 1].push(c.to_string()));
        for _ in 0..n {
            stacks[src - 1].pop();
        }
    })
}

fn main() {
    let data = parse("./input/day5");
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
