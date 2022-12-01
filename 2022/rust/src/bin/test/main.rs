use std::fs;

fn main() {
    let input = fs::read_to_string("./input/day6_b").unwrap();
    let data = input.split(",").map(|s| s.parse().unwrap()).collect::<Vec<usize>>(); // parse(&input);
    println!("{:?}", data.clone())

    // println!("{:?}", part1(data.clone()));
    // println!("{:?}", part2(data.clone()));
}

fn matched(c: char) -> char {
    match c {
        ')' => '(',
        ']' => '[',
        '}' => '{',
        '>' => '<',
        _ => ' '
    }
}

fn rev_match(c: char) -> char {
    match c {
        '(' => ')',
        '[' => ']',
        '{' => '}',
        '<' => '>',
        _ => ' '
    }
}

fn score(c: char) -> i32 {
    match c {
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137,
        _ => 0
    }
}

fn p2_score(c: char) -> i64 {
    match c {
        ')' => 1,
        ']' => 2,
        '}' => 3,
        '>' => 4,
        _ => 0
    }
}

fn do_work(s: &str) -> (Vec<char>, i32) {
    let mut vec: Vec<char> = Vec::new();

    for c in s.chars() {
        match c {
            ')' | ']' | '}' | '>' =>
                match vec.pop() {
                    Some(ob) => {
                        if ob != matched(c) {
                            return (vec, score(c))
                        }
                    },
                    _ => return (vec, score(c))
                },
            _ => vec.push(c)
        }
    }

    (vec, 0)
}

fn part1(data: Vec<&str>) -> i32 {
    data.iter().map(|s| do_work(s).1).sum()
}

fn part2(data: Vec<&str>) -> i64 {
    let mut scores = data.iter().map(|s| do_work(s)).filter(|(_, sc)| sc == &0).map(|(s, _)| s.iter().rev().fold(0, |acc, &c| (acc * 5) + p2_score(rev_match(c)))).collect::<Vec<i64>>();
    scores.sort();
    let midpoint = (scores.len() / 2) as usize;
    scores[midpoint]
}
