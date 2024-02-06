import 'package:collection/collection.dart';

import 'solver.dart';
import '../game.dart';

class AStarNode {
  final GameBoard board;
  final List<GameCard> cards;
  GameCard? card;

  AStarNode({
    required this.board,
    required this.cards,
    this.card,
  });

  int get g => board.cards.length;
  int get f => board.cards.length + cards.length + (card == null ? 0 : 1);

  @override
  bool operator ==(Object other) {
    if (other is AStarNode) {
      return board == other.board && card == other.card;
    }
    return false;
  }

  @override
  int get hashCode {
    return board.hashCode + (card?.hashCode ?? 0);
  }
}

class AStar extends Solver {
  final HeapPriorityQueue<AStarNode> openQueue =
      HeapPriorityQueue((a, b) => a.f - b.f);
  final Set<AStarNode> closedSet = {};
  final List<GameBoard> bestMoves = [];
  int bestScore;

  AStar({required super.board, required super.hand})
      : bestScore = board.cards.length;

  List<AStarNode> getNeighbors(AStarNode node) {
    List<AStarNode> neighbors = [];
    if (node.card == null) {
      for (var card in node.cards) {
        List<GameCard> newCards = node.cards.toList();
        newCards.remove(card);
        neighbors.add(
          AStarNode(
            board: node.board.clone(),
            cards: newCards,
            card: card,
          ),
        );
      }
      return neighbors;
    }
    // for (var block in node.board.blocks)
    if (node.board.blocks.isNotEmpty) {
      CardBlock block = node.board.blocks.last;
      if (block.canInsert(node.card!)) {
        final newBoard = GameBoard();
        for (var b in node.board.blocks) {
          if (b != block) {
            newBoard.addBlock(b.clone());
          }
        }
        CardBlock newBlock = block.clone();
        newBlock.insert(node.card!);
        newBoard.addBlock(newBlock);
        neighbors.add(AStarNode(
          board: newBoard,
          cards: node.cards.toList(),
        ));
      }
    }
    // Try create new block
    if (node.board.blocks.isEmpty || node.board.blocks.last.isValid()) {
      GameBoard newBoard = node.board.clone();
      newBoard.addBlock(SeriesBlock(cards: [node.card!]));
      neighbors.add(AStarNode(
        board: newBoard,
        cards: node.cards.toList(),
      ));
      newBoard = node.board.clone();
      newBoard.addBlock(SquareBlock(cards: [node.card!]));
      neighbors.add(AStarNode(
        board: newBoard,
        cards: node.cards.toList(),
      ));
    }
    return neighbors;
  }

  @override
  List<GameBoard> getMoves() {
    AStarNode startNode = AStarNode(
      board: GameBoard(),
      cards: board.cards.toList()..addAll(hand.cards),
    );

    openQueue.add(startNode);

    while (openQueue.isNotEmpty) {
      AStarNode currentNode = openQueue.removeFirst();
      closedSet.add(currentNode);

      if (currentNode.card == null &&
          currentNode.board.cards.length > board.cards.length &&
          currentNode.board.isValid()) {
        if (currentNode.cards.isEmpty) {
          return [currentNode.board];
        }
        if (currentNode.board.cards.length > board.cards.length) {
          if (currentNode.board.cards.length == bestScore) {
            bestMoves.add(currentNode.board);
          } else if (currentNode.board.cards.length > bestScore) {
            bestMoves.clear();
            bestMoves.add(currentNode.board);
            bestScore = currentNode.board.cards.length;
          }
        }
      }

      for (var neighbor in getNeighbors(currentNode)) {
        if (closedSet.contains(neighbor)) {
          continue;
        }
        if (!openQueue.contains(neighbor)) {
          openQueue.add(neighbor);
        }
      }
    }

    return bestMoves;
  }
}
