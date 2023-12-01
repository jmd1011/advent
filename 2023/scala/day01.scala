import scala.io.Source

object Day1 extends App {
    def part1(lines: Iterator[String]): Int = {
        lines.map{ x =>
            val digits = x.filter(_.isDigit)
            digits.head.asDigit * 10 + digits.last.asDigit
        }.sum
    }

    def part2(lines: Iterator[String]): Int = {
        def getNum(num: String): Int = {
            val nums = Map(
                "one" -> 1,
                "two" -> 2,
                "three" -> 3,
                "four" -> 4,
                "five" -> 5,
                "six" -> 6,
                "seven" -> 7,
                "eight" -> 8,
                "nine" -> 9)

            if (num(0).isDigit)
                num(0).asDigit
            else
                nums(num)
        }
        val regex = "(?=([1-9]|one|two|three|four|five|six|seven|eight|nine))".r
        lines.map{ x =>
            val digits = regex.findAllMatchIn(x).map(_.group(1)).map(getNum).toList
            digits.head * 10 + digits.last
        }.sum
    }

    println(part1(Source.fromFile("2023/scala/input/day01/real").getLines()))
    println(part2(Source.fromFile("2023/scala/input/day01/real").getLines()))
}
