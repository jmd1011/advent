import scala.io.Source

object Day7 extends App {
  object Card extends Enumeration {
    type Card = Value
    val JOKER, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN, QUEEN, KING,
        ACE = Value
    def apply(card: Char): Card = card match {
      case '2' => TWO
      case '3' => THREE
      case '4' => FOUR
      case '5' => FIVE
      case '6' => SIX
      case '7' => SEVEN
      case '8' => EIGHT
      case '9' => NINE
      case 'T' => TEN
      case 'J' => JOKER
      case 'Q' => QUEEN
      case 'K' => KING
      case 'A' => ACE
    }
  }

  object HandType extends Enumeration {
    type HandType = Value
    val High, One, Two, Three, Full, Four, Five = Value
    def apply(cards: String) = {
      def getType(cardCounts: Map[Char, Int]) =
        cardCounts.maxBy(_._2)._2 match {
        case 5 => Five
        case 4 => Four
        case 3 =>
          if (cardCounts.filter { case (_, n) => n == 2 }.nonEmpty) Full
          else Three
        case 2 =>
          if (cardCounts.filter { case (_, n) => n == 2 }.toList.length == 2)
            Two
          else One
        case _ => High
      }

      val cardCounts = cards.groupBy(identity).view.mapValues(_.size).toMap
      val max = cardCounts.maxBy(_._2)
      if (max._2 == 5) Five
      else if (cards.contains('J')) {
        val ncardCounts = cards.filter(c => c != 'J').groupBy(identity).view.mapValues(_.size).toMap
        val nmax = ncardCounts.maxBy(_._2)
        getType(ncardCounts + (nmax._1 -> (nmax._2 + cardCounts('J'))))
      }
      else
        getType(cardCounts)
    }
  }

  import HandType._
  import Card._

  case class Hand(cards: List[Card], bid: Int, handType: HandType)
      extends Ordered[Hand] {
    def apply(rank: Int) = bid * rank
    def compare(that: Hand) = {
      if (this.cards == that.cards)
        0
      else if (this.handType.id > that.handType.id)
        1
      else if (this.handType.id < that.handType.id)
        -1
      else
        this.cards
          .zip(that.cards)
          .filter { case (us, them) => us != them }
          .head match {
          case (us, them) => us.id - them.id
        }
    }
  }

  def part1(hands: List[Hand]): Int = {
    hands.sorted.zipWithIndex.map { case (hand, idx) =>
      hand(idx + 1)
    }.sum
  }

  def part2(hands: List[Hand]): Int = {
    0
  }

  def inputLines(filename: String): List[Hand] = {
    def parse(line: String): Hand = line
      .splitAt(6) match {
      case (cards, bid) =>
        Hand(
          cards.trim().map(c => Card(c)).toList,
          bid.toInt,
          HandType(cards.trim())
        )
    }

    Source
      .fromFile(s"2023/input/day07/$filename")
      .getLines()
      .map(parse)
      .toList
  }

  // This actually only works for part2 now, oops
  println(part1(inputLines("real")))
  // println(part2(inputLines("sample")))
}
