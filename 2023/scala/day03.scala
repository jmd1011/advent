import scala.io.Source

object Day3 extends App {
  case class Coord(val x: Int, val y: Int) {
    def unapply(): (Int, Int) = (this.x, this.y)
    lazy val neighbors: List[Coord] = List(
      Coord(this.x, this.y + 1),
      Coord(this.x, this.y - 1),
      Coord(this.x - 1, this.y),
      Coord(this.x + 1, this.y),
      Coord(this.x - 1, this.y - 1),
      Coord(this.x - 1, this.y + 1),
      Coord(this.x + 1, this.y - 1),
      Coord(this.x + 1, this.y + 1)
    )
  }

  class Schematic(schematic: List[List[Char]]) {
    def apply(coord: Coord): Option[Char] = {
      val Coord(x, y) = coord
      if (y < 0 || y >= schematic.length) {
        None
      } else {
        val line = this.schematic(y)
        if (x < 0 || x >= line.length)
          None
        else
          Some(this.schematic(y)(x))
      }
    }
  }

  def findEnd(schematic: Schematic, coord: Coord): Coord = {
    val Coord(x, y) = coord
    val right = Coord(x + 1, y)
    schematic(right) match {
      case Some(c) if c.isDigit => findEnd(schematic, right)
      case _                    => coord
    }
  }

  def calcNum(schematic: Schematic, coord: Coord): Int = {
    schematic(coord) match {
      case Some(c) if c.isDigit =>
        c.asDigit + 10 * calcNum(schematic, Coord(coord.x - 1, coord.y))
      case _ => 0
    }
  }

  def doWork(lines: List[List[Char]])(skip: Char => Boolean)(
      update: (Schematic, (Int, List[Coord]), List[Coord]) => (Int, List[Coord])
  ): Int = {
    val schematic = new Schematic(lines)
    val coords = lines.zipWithIndex.map { case (l, i) =>
      l.zipWithIndex.map { case (c, j) =>
        (c, Coord(j, i))
      }
    }.flatten
    coords
      .foldLeft((0, List[Coord]())) {
        case (cur, (c, _)) if skip(c) => cur
        case (cur, (_, coord)) => {
          update(
            schematic,
            cur,
            coord.neighbors.filter(n =>
              schematic(n) match {
                case Some(z) => z.isDigit
                case None    => false
              }
            )
          )
        }
      }
      ._1
  }

  def part1(lines: List[List[Char]]): Int = {
    doWork(lines)(c => c.isDigit || c == '.') {
      case (schematic, (s, seen), numNeighbors) => {
        numNeighbors.foldLeft((s, seen)) {
          case (cc @ (n_s, n_seen), neighbor) => {
            val end = findEnd(schematic, neighbor)
            if (n_seen.contains(end)) {
              cc
            } else {
              val num = calcNum(schematic, end)
              (n_s + num, n_seen :+ end)
            }
          }
        }
      }
    }
  }

  def part2(lines: List[List[Char]]): Int = {
    doWork(lines)(c => c != '*') {
      case (schematic, cur @ (s, seen), numNeighbors) => {
        numNeighbors.map(findEnd(schematic, _)).distinct match {
          case a :: b :: Nil => {
            val aNum = calcNum(schematic, findEnd(schematic, a))
            val bNum = calcNum(schematic, findEnd(schematic, b))
            (s + (aNum * bNum), seen)
          }
          case _ => cur
        }
      }
    }
  }

  def inputLines(filename: String) =
    Source.fromFile(s"2023/input/day03/$filename").getLines().toList

  println(part1(inputLines("real").map(_.toList)))
  println(part2(inputLines("real").map(_.toList)))
}
