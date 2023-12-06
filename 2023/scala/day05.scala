import scala.io.Source

object Day5 extends App {
  case class FarmRange(dest: Long, source: Long, step: Long) {
    def contains(seed: Long) = seed >= source && seed <= (source + step - 1)
    def apply(seed: Long) = (seed - source) + dest
  }
  case class FarmMap(ranges: List[FarmRange]) {
    def apply(seed: Long) = {
      this.ranges.filter(_.contains(seed)) match {
        case a :: Nil => a(seed)
        case Nil      => seed
      }
    }
  }

  def part1(input: (Iterator[Long], List[FarmMap])): Long = {
    val (seeds, maps) = input
    seeds.foldLeft(Long.MaxValue) {
      case (curMin, seed) => {
        curMin min maps.foldLeft(seed) { case (source, m) =>
          m(source)
        }
      }
    }
  }

  def part2(input: (Iterator[Long], List[FarmMap])): Long = {
    val (seeds, maps) = input
    seeds.toList
      .sliding(2, 2)
      .map { seedRange =>
        seedRange match {
          case start :: end :: Nil => {
            part1(((start to start + end).iterator, maps))
          }
        }
      }
      .min
  }

  def parseMaps(lines: List[String]): List[FarmMap] = lines match {
    case Nil => Nil
    case _ :: next => {
      val ranges = next.takeWhile(_.head.isDigit)
      FarmMap(ranges.map(_.split(" ").toList.map(_.toLong)).map {
        case dest :: source :: step :: Nil => {
          FarmRange(dest, source, step)
        }
      }) :: parseMaps(next.drop(ranges.length))
    }
  }

  def inputLines(filename: String) = {
    val lines = Source
      .fromFile(s"2023/input/day05/$filename")
      .getLines()
      .toList

    val seeds = lines.head
      .split(":")
      .last
      .trim()
      .split(" ")
      .filter(_.nonEmpty)
      .map(_.toLong)
      .toList

    (
      seeds.iterator,
      parseMaps(lines.tail.filter(_.nonEmpty))
    )
  }

  println(part1(inputLines("real")))
  println(part2(inputLines("real")))
}
