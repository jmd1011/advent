use im::hashset::HashSet;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::path::Path;

#[cfg(test)]
mod test {
    use super::*;

    #[test]
    fn test_part1() {
        let test_str = "R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part1(&test_data), 13);
    }

    #[test]
    fn test_part2() {
        let test_str = "R 4
U 4
L 3
D 1
R 4
D 1
L 5
R 2";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part2(&test_data), 1);
    }

    #[test]
    fn test_part2_bigger() {
        let test_str = "R 5
U 8
L 8
D 3
R 17
D 10
L 25
U 20";
        let test_data = test_str.split("\n").map(|s| s.to_owned()).collect();
        assert_eq!(part2(&test_data), 36);
    }
}

type Coord = (i32, i32);

fn update((nhx, nhy): Coord, (tx, ty): Coord) -> Coord {
    if ((nhx - tx) as i32).abs() > 1 {
        let x_mod = if nhx > tx { tx + 1 } else { tx - 1 };
        if nhy == ty {
            (x_mod, ty)
        } else {
            (x_mod, if nhy > ty { ty + 1 } else { ty - 1 })
        }
    } else if ((nhy - ty) as i32).abs() > 1 {
        let y_mod = if nhy > ty { ty + 1 } else { ty - 1 };
        if nhx == tx {
            (tx, y_mod)
        } else {
            (if nhx > tx { tx + 1 } else { tx - 1 }, y_mod)
        }
    } else {
        (tx, ty)
    }
}

fn step(h: Coord, ts: Vec<Coord>) -> Vec<Coord> {
    if ts.is_empty() {
        ts
    } else {
        let t = ts.first().unwrap();
        let nh = update(h, *t);
        let nts = step(nh, ts[1..].to_vec());
        vec![nh]
            .into_iter()
            .chain(nts.into_iter())
            .collect::<Vec<_>>()
    }
}

fn update_h((hx, hy): Coord, (dir, i): (&str, i32)) -> Coord {
    match dir {
        "R" => (hx + i, hy),
        "U" => (hx, hy + i),
        _ => unreachable!("Where are you going?"),
    }
}

fn parse_step(l: &String) -> (String, Vec<i32>) {
    match l.split(" ").collect::<Vec<_>>()[..] {
        [a, d] => {
            let n = d.parse::<usize>().expect("Couldn't parse");
            match a {
                "L" => ("R".to_string(), vec![-1; n]),
                "D" => ("U".to_string(), vec![-1; n]),
                _ => (a.to_string(), vec![1; n]),
            }
        }
        _ => unreachable!("What is this: {:?}", l),
    }
}

fn _do_work(lines: &Vec<String>, n: usize) -> usize {
    lines
        .iter()
        .map(parse_step)
        .fold(
            (((0, 0), vec![(0, 0); n]), HashSet::<Coord>::new()),
            |(poss, s), (dir, steps)| {
                let (n_poss, ns) =
                    steps
                        .iter()
                        .fold((poss, HashSet::<Coord>::new()), |((h, ts), seen), i| {
                            let nh = update_h(h, (&dir, *i));
                            let nt = step(nh, ts);
                            let nseen = seen.insert(*nt.last().unwrap());
                            ((nh, nt), nseen)
                        });
                (n_poss, s.union(ns))
            },
        )
        .1
        .len()
}

fn part1(lines: &Vec<String>) -> usize {
    _do_work(lines, 1)
}

fn part2(lines: &Vec<String>) -> usize {
    _do_work(lines, 9)
}

fn main() {
    let data = parse("./input/day9");
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
