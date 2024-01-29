import 'package:flutter/material.dart';

enum Suit { spades, hearts, diamonds, clubs }

class GameCard {
  final Suit suit;
  final int value;

  const GameCard({required this.suit, required this.value});

  String valueToString() {
    switch (value) {
      case 1:
        return 'A';
      case 11:
        return 'J';
      case 12:
        return 'Q';
      case 13:
        return 'K';
      default:
        return value.toString();
    }
  }

  String suitToString() {
    switch (suit) {
      case Suit.spades:
        return '♠';
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
    }
  }

  get color {
    switch (suit) {
      case Suit.spades:
      case Suit.clubs:
        return Colors.black;
      case Suit.hearts:
      case Suit.diamonds:
        return Colors.red;
    }
  }
}

class CardBlock {
  final List<GameCard> cards;

  const CardBlock({required this.cards});

  int get length => cards.length;

  GameCard get(int index) => cards[index];
}

class SeriesBlock extends CardBlock {
  const SeriesBlock({required super.cards});

  bool canInsert(GameCard card) {
    final lastCard = cards.last;
    if (lastCard.suit != card.suit) {
      return false;
    }
    return lastCard.value + 1 == card.value || lastCard.value - 1 == card.value;
  }
}

class SquareBlock extends CardBlock {
  const SquareBlock({required super.cards});

  bool canInsert(GameCard card) {
    if (cards.length == 4) {
      return false;
    }
    if (cards.where((c) => c.suit == card.suit).isNotEmpty) {
      return false;
    }
    return cards.first.value == card.value;
  }
}

class GameBoard {
  final List<CardBlock> blocks = [];

  List<GameCard> get cards => blocks.expand((b) => b.cards).toList();

  void addBlock(CardBlock block) {
    blocks.add(block);
  }
}
