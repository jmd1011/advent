import scala.io.Source

object Day1 extends App {
    class Entry(val num: Int, val color: String)
    class Score(val red: Int, val green: Int, val blue: Int)
    val start = new Score(0, 0, 0)

    def turn(t: String): Score = {
        t.split(",").map(_.trim).map(x => x.split(" ")).map(x => new Entry(x.head.toInt, x.last)).foldLeft(start)((m, e) => {
            if (e.color == "red") new Score(math.max(m.red, e.num), m.green, m.blue)
            else if (e.color == "green") new Score(m.red, math.max(m.green, e.num), m.blue)
            else new Score(m.red, m.green, math.max(m.blue, e.num))
        })
    }

    def play(turns: String)(calcPoints: Score => Int): Int = {
        calcPoints(turns.split(";").map(turn).foldLeft(start)((m, e) => new Score(math.max(m.red, e.red), math.max(m.green, e.green), math.max(m.blue, e.blue))))
    }

    def doWork(lines: Iterator[String])(calcPoints: Int => (Score => Int)): Int = {
        lines.map(line => {
            val parts = line.split(":")
            val turns = parts.last.trim()
            val id = parts.head.split(" ").last.toInt
            play(turns)(calcPoints(id))
        }).sum
    }

    def part1(lines: Iterator[String]): Int = doWork(lines)(id => x => if (x.red <= 12 && x.green <= 13 && x.blue <= 14) id else 0)
    def part2(lines: Iterator[String]): Int = doWork(lines)(id => x => x.red * x.green * x.blue)

    println(part1(Source.fromFile("2023/input/day02/real").getLines()))
    println(part2(Source.fromFile("2023/input/day02/real").getLines()))
}
