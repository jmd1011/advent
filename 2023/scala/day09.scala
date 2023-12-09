import scala.io.Source

object Day9 extends App {
  def part1(histories: List[List[Int]]): Int = {
    def doWork(history: List[Int]): Int = {
      val differences = history
        .sliding(2)
        .map { case head :: next :: _ =>
          next - head
        }
        .toList

      if (differences.distinct.length == 1)
        history.last + differences.head
      else {
        history.last + doWork(differences)
      }

    }
    histories.map(doWork).sum
  }

  def part2(histories: List[List[Int]]): Int = {
    def doWork(history: List[Int]): Int = {
      val differences = history
        .sliding(2)
        .map { case head :: next :: _ =>
          next - head
        }
        .toList

      if (differences.distinct.length == 1)
        history.head - differences.head
      else {
        history.head - doWork(differences)
      }
    }
    histories.map(doWork).sum
  }

  def inputLines(filename: String): List[List[Int]] = {
    Source
      .fromFile(s"2023/input/day09/$filename")
      .getLines()
      .map(_.split(" ").filter(_.nonEmpty).map(_.toInt).toList)
      .toList
  }

  println(part1(inputLines("real")))
  println(part2(inputLines("real")))
}
