import '../game.dart';

abstract class Solver {
  final GameBoard board;
  final CardBlock hand;

  Solver({required this.board, required this.hand});

  Future<List<GameBoard>> getMovesAsync() async {
    return Future.value(getMoves());
  }

  List<GameBoard> getMoves();
}
