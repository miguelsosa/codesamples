
/* 
   NOTE: scala_solver.scala and scala_gamedef.scala are parts of a
   sample solver for a simplified Bloxorz game:

   	  http://www.coolmath-games.com/0-bloxorz/. 

   This was done as part of a scala MOOC class I took at
   Coursera (Introduction to Functional programming with Scala).

   For the most part the professor provided the comment block
   describing what the function should do, and the function names, the
   rest was my responsibility so the scala code there is (mostly)
   mine.

   Note that this is an introductory scala course so my style and
   solutions may not be ideal, but it is a smaple code in scala.
*/

package streams

import common._

/**
 * This component implements the solver for the Bloxorz game
 */
trait Solver extends GameDef {

  /**
   * Returns `true` if the block `b` is at the final position
   */
  def done(b: Block): Boolean = (b.isStanding && b.b1 == goal)

  /**
   * This function takes two arguments: the current block `b` and
   * a list of moves `history` that was required to reach the
   * position of `b`.
   * 
   * The `head` element of the `history` list is the latest move
   * that was executed, i.e. the last move that was performed for
   * the block to end up at position `b`.
   * 
   * The function returns a stream of pairs: the first element of
   * the each pair is a neighboring block, and the second element
   * is the augmented history of moves required to reach this block.
   * 
   * It should only return valid neighbors, i.e. block positions
   * that are inside the terrain.
   */
  def neighborsWithHistory(b: Block, history: List[Move]): Stream[(Block, List[Move])] = {
    val legal_moves: List[(Block, Move)] = b.legalNeighbors
    if (legal_moves == Nil) Stream.empty else {
    (for {
    		(block, move) <- legal_moves
    	} yield (block, move::history)).toStream
    }
  }

  /**
   * This function returns the list of neighbors without the block
   * positions that have already been explored. We will use it to
   * make sure that we don't explore circular paths.
   */
  def newNeighborsOnly(neighbors: Stream[(Block, List[Move])],
                       explored: Set[Block]): Stream[(Block, List[Move])] = {
    val results = for {
      check_neighbor <- neighbors.toSet
      if (!(explored contains check_neighbor._1))
    } yield check_neighbor
    results.toStream
  }

  /**
   * The function `from` returns the stream of all possible paths
   * that can be followed, starting at the `head` of the `initial`
   * stream.
   * 
   * The blocks in the stream `initial` are sorted by ascending path
   * length: the block positions with the shortest paths (length of
   * move list) are at the head of the stream.
   * 
   * The parameter `explored` is a set of block positions that have
   * been visited before, on the path to any of the blocks in the
   * stream `initial`. When search reaches a block that has already
   * been explored before, that position should not be included a
   * second time to avoid cycles.
   * 
   * The resulting stream should be sorted by ascending path length,
   * i.e. the block positions that can be reached with the fewest
   * amount of moves should appear first in the stream.
   * 
   * Note: the solution should not look at or compare the lengths
   * of different paths - the implementation should naturally
   * construct the correctly sorted stream.
   */
  def from0(initial: Stream[(Block, List[Move])],
           explored: Set[Block]): Stream[(Block, List[Move])] = {
    // return stream of all paths that can be followed starting at the head of initial
    if (initial.isEmpty) initial
    else {
      // Generate all the new paths that can be followed staring from the head of initial
      // And from then on, evolve the rest (have initial as a prefix) 
    	val more = for { 
    	  path <- initial
          next <- newNeighborsOnly(neighborsWithHistory(path._1, path._2), explored)
          if !(explored contains next._1)
        } yield next
    	initial #::: from(more, explored ++ (more map(_._1)))
    }
  }

  def from(initial: Stream[(Block, List[Move])], explored: Set[Block]): Stream[(Block, List[Move])] = from0(initial, explored)

  /**
   * The stream of all paths that begin at the starting block.
   */
  lazy val pathsFromStart: Stream[(Block, List[Move])] =  {
    val s1 = Stream((startBlock, List()))
    from(s1, Set(startBlock))
  }

  /**
   * Returns a stream of all possible pairs of the goal block along
   * with the history how it was reached.
   */
  lazy val pathsToGoal: Stream[(Block, List[Move])] = {
    if (pathsFromStart.isEmpty) Stream.empty
    else {
    	for {
    		path <- pathsFromStart
    		b = path._1
    		if (b.b1 == goal && b.isStanding)
    	} yield path
    }
  }

  /**
   * The (or one of the) shortest sequence(s) of moves to reach the
   * goal. If the goal cannot be reached, the empty list is returned.
   *
   * Note: the `head` element of the returned list should represent
   * the first move that the player should perform from the starting
   * position.
   */
  lazy val solution: List[Move] = {
    if (pathsToGoal.isEmpty) List()
    else {
      pathsToGoal.head._2.reverse
    }
  }
}
