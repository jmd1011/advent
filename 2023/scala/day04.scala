import scala.io.Source

object Day4 extends App {
  def part1(lines: List[(List[Int], List[Int])]): Int = {
    lines
      .map { case (winners, ours) =>
        ours.filter(o => winners.contains(o)).length - 1
      }
      .map(math.pow(2, _).toInt)
      .sum
  }

  def part2(cards: List[(List[Int], List[Int])]): Int = {
    cards.zipWithIndex
      .foldLeft((0, Map[Int, Int]().withDefaultValue(1))) {
        case ((count, copies), ((winners, ours), idx)) =>
          (
            count + copies(idx),
            copies ++ (0 to ours.filter(o => winners.contains(o)).length)
              .map(n => Map((idx + n) -> (copies(idx + n) + copies(idx))))
              .foldLeft(Map[Int, Int]()) {
                case (a, b) => {
                  a ++ b
                }
              }
          )
      }
      ._1
  }

  def inputLines(filename: String) = {
    Source
      .fromFile(s"2023/input/day04/$filename")
      .getLines()
      .toList
      .map(l => {
        val nums = l
          .split(':')
          .last
          .trim()
          .split('|')
          .map(_.trim)
          .map(side => side.split(' ').filter(_.nonEmpty).map(_.toInt).toList)
        (nums(0), nums(1))
      })
  }

  println(part1(inputLines("real")))
  println(part2(inputLines("real")))
}
