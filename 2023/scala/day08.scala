import scala.io.Source
import scala.annotation.tailrec

object Day8 extends App {
  case class Node(name: String, L: String, R: String) {
    def apply(nodes: NodeList, direction: Char): Node = findNode(
      direction match {
        case 'L' => this.L
        case _   => this.R
      },
      nodes
    )
  }

  type NodeList = List[Node]
  def findNode(name: String, nodeList: NodeList): Node =
    nodeList.find(node => node.name == name) match {
      case Some(node) => node
      case _          => ???
    }

  def navigate(
      nodeList: NodeList,
      directions: LazyList[Char],
      node: Node,
      steps: Int,
      test: (Node => Boolean)
  ): Int =
    if (test(node)) steps
    else
      navigate(
        nodeList,
        directions.tail,
        node(nodeList, directions.head),
        steps + 1,
        test
      )

  def part1(input: (LazyList[Char], NodeList)): Int = {
    val (directions, nodes) = input
    navigate(
      nodes,
      directions,
      nodes.filter(node => node.name == "AAA").head,
      0,
      node => node.name == "ZZZ"
    )
  }

  def lcm(list: Seq[Long]): Long = list.foldLeft(1: Long) { (a, b) =>
    b * a /
      Stream
        .iterate((a, b)) { case (x, y) => (y, x % y) }
        .dropWhile(_._2 != 0)
        .head
        ._1
        .abs
  }

  def part2(input: (LazyList[Char], NodeList)): Long = {
    val (directions, nodes) = input
    val startNodes = nodes.filter(node => node.name.last == 'A')
    lcm(
      startNodes
        .map(node =>
          navigate(nodes, directions, node, 0, node => node.name.last == 'Z')
        )
        .map(_.toLong)
    )
  }

  def inputLines(filename: String): (LazyList[Char], NodeList) = {
    def parse(line: String): Node = {
      val s = line.split("=").map(_.trim).toList
      val name = s.head
      val children = s.last.drop(1).dropRight(1).split(",").map(_.trim).toList
      Node(name, children.head, children.last)
    }

    val lines = Source
      .fromFile(s"2023/input/day08/$filename")
      .getLines()
      .toList

    (LazyList.continually(lines.head).flatten, lines.drop(2).map(parse))
  }

  println(part1(inputLines("real")))
  println(part2(inputLines("real")))
}
