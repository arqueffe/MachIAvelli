import 'solver.dart';
import '../game.dart';

@Deprecated('Use AStar instead')
class BruteForce extends Solver {
  final Set<GameBoard> seenStates = {};

  BruteForce({required super.board, required super.hand});

  @override
  List<GameBoard> getMoves() {
    List<GameCard> cards = [];
    for (var block in board.blocks) {
      cards.addAll(block.cards);
    }
    cards.addAll(hand.cards);
    return _getMoves(cards, GameBoard(), null).toList();
  }

  Set<GameBoard> _getMoves(List<GameCard> currentCards, GameBoard currentBoard,
      GameCard? currentCard) {
    if (currentCard == null) {
      // If no card to play, return board if valid
      if (currentCards.isEmpty) {
        if (currentBoard.isValid()) {
          return {currentBoard.clone()};
        } else {
          return {};
        }
      }
      final moves = <GameBoard>{};
      // If board is valid, add it to moves
      if (currentBoard.isValid() &&
          currentBoard.cards.length > board.cards.length) {
        List<GameCard> leftCards = board.cards;
        for (var card in currentBoard.cards) {
          leftCards.remove(card);
        }
        if (leftCards.isEmpty) {
          moves.add(currentBoard.clone());
        }
      }

      if (seenStates.contains(currentBoard)) {
        return moves;
      } else {
        seenStates.add(currentBoard);
      }
      // Pick card to play
      for (var card in currentCards) {
        List<GameCard> newCards = currentCards.toList();
        newCards.remove(card);
        moves.addAll(_getMoves(
          newCards,
          currentBoard.clone(),
          card,
        ));
      }
      return moves;
    }
    final moves = <GameBoard>{};
    // Try insert in existing blocks
    for (var block in currentBoard.blocks) {
      if (block.canInsert(currentCard)) {
        final newBoard = GameBoard();
        for (var b in currentBoard.blocks) {
          if (b != block) {
            newBoard.addBlock(b.clone());
          }
        }
        CardBlock newBlock = block.clone();
        newBlock.insert(currentCard);
        newBoard.addBlock(newBlock);
        moves.addAll(_getMoves(
          currentCards,
          newBoard,
          null,
        ));
      }
    }
    // Try create new block
    {
      GameBoard newBoard = currentBoard.clone();
      newBoard.addBlock(SeriesBlock(cards: [currentCard]));
      moves.addAll(_getMoves(
        currentCards,
        newBoard,
        null,
      ));
    }
    {
      GameBoard newBoard = currentBoard.clone();
      newBoard.addBlock(SquareBlock(cards: [currentCard]));
      moves.addAll(_getMoves(
        currentCards,
        newBoard,
        null,
      ));
    }
    return moves;
  }
}
