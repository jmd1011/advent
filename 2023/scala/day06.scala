import scala.io.Source

object Day6 extends App {
  case class Race(time: Long, distance: Long)
  def part1(races: List[Race]): Long = {
    races
      .map(race => {
        val wins = ((race.time / 2) to 1 by -1)
          .takeWhile(nTime => {
            (race.time - nTime) * nTime > race.distance
          })

        wins.tail.length * 2 + (race.time % 2) + 1
      })
      .product
  }

  def part2(race: Race): Long = {
    ((race.time / 2) to 1 by -1)
      .count(nTime => {
        (race.time - nTime) * nTime > race.distance
      }) * 2 + ((race.time % 2) ^ 1)
  }

  def inputLines(filename: String): List[Race] = {
    def parse(line: String): List[Long] = line
      .trim()
      .split(":")
      .last
      .trim()
      .split(" ")
      .filter(_.nonEmpty)
      .map(_.toLong)
      .toList
    val lines = Source
      .fromFile(s"2023/input/day06/$filename")
      .getLines()
      .toList

    val times = parse(lines.head)
    val records = parse(lines.last)
    times.zip(records).map { case (t, d) => Race(t, d) }.toList
  }

  println(part1(inputLines("real")))
  println(part2(Race(45977295, 305106211101695L)))
}
