use std::collections::HashMap;
use std::error::Error;
use std::io;
use std::io::Write;
use std::process;
use serde::Deserialize;
use std::fs::{OpenOptions, File};

trait Show {
    fn show(&self) -> String;
}

#[derive(Debug, Deserialize)]
struct Person {
    name: String,
    addr1: String,
    addr2: String,
    city: String,
    _state: String,
    zip: String
}

impl Show for Person {
    fn show(&self) -> String {
        let names: Vec<&str> = self.name.split(", ").collect();
        let t: &str = &self.addr2;
        let q: &str = "\n";
        let z = t.to_owned() + &q[..];
        format!("{}{}{} {}\n{}\n{}{}{}{}\n", "\n\n\n\n", if !self.addr2.is_empty() { "" } else { "\n" }, names[1], names[0], self.addr1, if self.addr2.is_empty() { "" } else {&z}, self.city, ", CA", self.zip)
    }
}

fn example() -> Result<(), Box<dyn Error>> {
    let mut rdr = csv::Reader::from_reader(io::stdin());
    // let people = rdr.records().iter().map(|r| )
    // let people: Vec<Person> = rdr.deserialize().map(|entry| entry.unwrap()).collect();
    // let addrs: Vec<String> = people.iter().map(|p| p.show()).collect();
    let mut addr_map = HashMap::new();
    // let mut file = File::open("./conflicts.txt").expect("Unable to open file");
    for result in rdr.records() {
        let person: Person = result?.deserialize(None)?;
        if !addr_map.contains_key(person.addr1.as_str()) {
            addr_map.insert(person.addr1.clone(), Vec::new());
        }

        addr_map.get_mut(person.addr1.as_str()).unwrap().push(person.name.clone());
        println!("{:}", person.show());
        // f?.write(person.show().as_bytes()).expect("Unable to write!");
    }

    for (k, v) in &addr_map {
        let f = OpenOptions::new().append(true).open("./conflicts.txt");
        // println!("{}", k);
        if v.len() > 1 {
            f?.write(format!("{} live at {}.\n", v.join(" and "), k).as_bytes()).expect("Failed to write!");
        }
    }
    // writeln!(f, "{}", addrs.join("\n"))?;
    // fs::write_all("./test.txt", addrs);

    Ok(())
}

fn main() {
    // let input = fs::read_to_string("./input/rs.csv").unwrap();
    // let data = input.split(",").map(|s| s.parse().unwrap()).collect::<Vec<usize>>(); // parse(&input);
    // println!("{:?}", data.clone())
    if let Err(err) = example() {
        println!("Error: {}", err);
        process::exit(1);
    }
}
