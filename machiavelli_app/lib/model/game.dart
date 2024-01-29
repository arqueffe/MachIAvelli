enum Suit { spades, hearts, diamonds, clubs }

class GameCard {
  final Suit suit;
  final int value;

  const GameCard({required this.suit, required this.value});
}
