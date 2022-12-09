use itertools::Itertools;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::path::Path;

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_part1() {
        let test_str = "30373
25512
65332
33549
35390";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part1(&test_data), 21);
    }

    #[test]
    fn test_part2() {
        let test_str = "30373
25512
65332
33549
35390";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part2(&test_data), 8);
    }
}

fn do_work(
    visible: &mut Vec<Vec<usize>>,
    acc: (usize, char),
    cur: (usize, char),
    i: usize,
    max: usize,
) -> (usize, char) {
    let (j, t) = cur;
    if t > acc.1 {
        (j, t)
    } else {
        if cur.0 > 0 && cur.0 < max {
            visible[i][j] += 1;
        }
        acc
    }
}

fn do_work2(
    visible: &mut Vec<Vec<usize>>,
    acc: (usize, char),
    cur: (usize, char),
    i: usize,
    max: usize,
) -> (usize, char) {
    let (j, t) = cur;
    if t > acc.1 {
        (j, t)
    } else {
        if cur.0 > 0 && cur.0 < max {
            visible[j][i] += 1;
        }
        acc
    }
}

fn part1(lines: &Vec<String>) -> usize {
    let n_rows = lines.len() - 1;
    let n_cols = lines[0].len() - 1;
    let trees = lines
        .iter()
        .map(|l| l.chars().collect::<Vec<_>>())
        .collect::<Vec<_>>();
    let mut visible: Vec<Vec<usize>> = lines.iter().map(|l| vec![0; l.len()]).collect::<Vec<_>>();
    for (i, tree) in trees.iter().enumerate() {
        if i == 0 || i == trees.len() - 1 {
            continue;
        } else {
            let _ = tree.iter().enumerate().fold((0, '/'), |acc, (j, t)| {
                do_work(&mut visible, acc, (j, *t), i, n_cols)
            });
            let _ = tree.iter().enumerate().rfold((0, '/'), |acc, (j, t)| {
                do_work(&mut visible, acc, (j, *t), i, n_cols)
            });
        }
    }

    for j in 1..trees.len() - 1 {
        let col = trees.iter().map(|t| t[j]).collect::<Vec<_>>();
        col.iter().enumerate().fold((0, '/'), |acc, (i, t)| {
            do_work2(&mut visible, acc, (i, *t), j, n_rows)
        });
        col.iter().enumerate().rfold((0, '/'), |acc, (i, t)| {
            do_work2(&mut visible, acc, (i, *t), j, n_rows)
        });
    }

    visible.iter().fold(0, |acc, v| {
        acc + v.iter().filter(|t| **t < 4).collect::<Vec<_>>().len()
    })
}

fn part2(lines: &Vec<String>) -> usize {
    let n_rows = lines.len();
    let n_cols = lines[0].len();
    let trees = lines
        .iter()
        .map(|l| l.chars().collect::<Vec<_>>())
        .collect::<Vec<_>>();
    let mut visible: Vec<Vec<(usize, usize, usize, usize)>> = lines
        .iter()
        .map(|l| vec![(0, 0, 0, 0); l.len()])
        .collect::<Vec<_>>();

    for i in 0..n_rows {
        for j in 0..n_cols {
            let t_i = &trees[i];
            let r_count = t_i[j + 1..]
                .iter()
                .take_while(|&&x| x < trees[i][j])
                .count();
            let r_margin = (j + r_count < (n_cols - 1)) as usize;
            let l_count = t_i[..j]
                .iter()
                .rev()
                .take_while(|&&x| x < trees[i][j])
                .count();
            let l_margin = (j - l_count > 0) as usize;
            // let (_,_,u,d) = visible[i][j];
            visible[i][j] = (l_count + l_margin, r_count + r_margin, 0, 0);
        }
    }

    for j in 0..n_cols {
        for i in 0..n_rows {
            let col = trees.iter().map(|t| t[j]).collect::<Vec<_>>();
            let d_count = col[i + 1..]
                .iter()
                .take_while(|&x| x < &trees[i][j])
                .count();
            let d_margin = (i + d_count < (n_rows - 1)) as usize;
            let u_count = col[..i]
                .iter()
                .rev()
                .take_while(|&x| x < &trees[i][j])
                .count();
            let u_margin = (i - u_count > 0) as usize;
            if i == 2 && j == 1 {
                println!("{}, {}", u_count, u_margin);
            }
            let (l, r, _, _) = visible[i][j];
            visible[i][j] = (l, r, u_count + u_margin, d_count + d_margin);
        }
    }

    visible
        .iter()
        .map(|v| v.iter().map(|(l, r, u, d)| l * r * u * d).max().unwrap())
        .max()
        .unwrap()
}

// TODO: This isn't working, not sure why yet.
fn part2a(lines: &Vec<String>) -> usize {
    let n_rows = lines.len();
    let n_cols = lines[0].len();
    let trees = lines
        .iter()
        .map(|l| l.chars().collect::<Vec<_>>())
        .collect::<Vec<_>>();

    let lr = (0..n_rows)
        .cartesian_product(0..n_cols)
        .map(|(i, j)| {
            let t_i = &trees[i];
            let r_count = t_i
                .iter()
                .skip(j + 1)
                .take_while(|&&x| x < trees[i][j])
                .count();
            let r_margin = (j + r_count < (n_cols - 1)) as usize;
            let l_count = t_i
                .iter()
                .take(j)
                .rev()
                .take_while(|&&x| x < trees[i][j])
                .count();
            let l_margin = (j - l_count > 0) as usize;
            ((l_count + l_margin), (r_count + r_margin))
        })
        .collect::<Vec<_>>();

    let ud = (0..n_cols)
        .cartesian_product(0..n_rows)
        .map(|(j, i)| {
            let col = trees.iter().map(|t| t[j]).collect::<Vec<_>>();
            let d_count = col
                .iter()
                .skip(i + 1)
                .take_while(|&x| x < &trees[i][j])
                .count();
            let d_margin = (i + d_count < (n_rows - 1)) as usize;
            let u_count = col
                .iter()
                .take(i)
                .rev()
                .take_while(|&x| x < &trees[i][j])
                .count();
            let u_margin = (i - u_count > 0) as usize;
            ((u_count + u_margin), (d_count + d_margin))
        })
        .collect::<Vec<_>>();

    lr.iter()
        .zip(ud)
        .map(|((l, r), (u, d))| l * r * u * d)
        .max()
        .unwrap()
}

fn main() {
    let data = parse("./input/day8");
    println!("{:}", part1(&data));
    println!("{:}", part2(&data));
    println!("{:}", part2a(&data));
}

fn parse(filename: impl AsRef<Path>) -> Vec<String> {
    let file = File::open(filename).expect("no such file");
    let buf = BufReader::new(file);
    buf.lines()
        .map(|l| l.expect("Could not parse line"))
        .collect()
}
