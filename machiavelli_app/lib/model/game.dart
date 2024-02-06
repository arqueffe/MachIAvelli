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

  @override
  String toString() {
    return valueToString() + suitToString();
  }
}

class CardBlock {
  final List<GameCard> cards;

  const CardBlock({required this.cards});

  int get length => cards.length;

  GameCard get(int index) => cards[index];

  bool canInsert(GameCard card) => true;
  bool isValid() => true;
  void insert(GameCard card) {
    cards.add(card);
  }

  CardBlock clone() {
    return CardBlock(cards: cards.toList());
  }

  @override
  String toString() {
    // Display the cards with comma separation
    return "[${cards.map((c) => c.toString()).join(", ")}]";
  }

  int typeToInt() {
    return -1;
  }
}

class SeriesBlock extends CardBlock {
  const SeriesBlock({required super.cards});

  @override
  bool canInsert(GameCard card) {
    final lastCard = cards.last;
    if (lastCard.suit != card.suit) {
      return false;
    }
    return lastCard.value + 1 == card.value || lastCard.value - 1 == card.value;
  }

  @override
  bool isValid() {
    if (cards.length < 3) {
      return false;
    }
    final firstCardSuit = cards.first.suit;
    for (var card in cards) {
      if (card.suit != firstCardSuit) {
        return false;
      }
    }
    for (var i = 0; i < cards.length - 1; i++) {
      final card = cards[i];
      final nextCard = cards[i + 1];
      if (card.value + 1 != nextCard.value) {
        return false;
      }
    }
    return true;
  }

  void insert(GameCard card) {
    if (card.value < cards.first.value) {
      cards.insert(0, card);
    } else {
      cards.add(card);
    }
  }

  @override
  CardBlock clone() {
    return SeriesBlock(cards: cards.toList());
  }

  @override
  String toString() {
    return "Serie${super.toString()}";
  }

  @override
  int typeToInt() {
    return 1;
  }
}

class SquareBlock extends CardBlock {
  const SquareBlock({required super.cards});

  @override
  bool canInsert(GameCard card) {
    if (cards.length == 4) {
      return false;
    }
    if (cards.where((c) => c.suit == card.suit).isNotEmpty) {
      return false;
    }
    return cards.first.value == card.value;
  }

  @override
  bool isValid() {
    if (cards.length < 3 || cards.length > 4) {
      return false;
    }
    final firstCardValue = cards.first.value;
    for (var card in cards) {
      if (card.value != firstCardValue) {
        return false;
      }
    }

    return true;
  }

  @override
  CardBlock clone() {
    return SquareBlock(cards: cards.toList());
  }

  @override
  String toString() {
    return "Square${super.toString()}";
  }

  @override
  int typeToInt() {
    return 2;
  }
}

class GameBoard {
  final List<CardBlock> blocks = [];

  List<GameCard> get cards => blocks.expand((b) => b.cards).toList();

  void addBlock(CardBlock block) {
    blocks.add(block);
  }

  bool isValid() {
    for (var block in blocks) {
      if (!block.isValid()) {
        return false;
      }
    }
    return true;
  }

  @override
  get hashCode {
    int hash = blocks.length * 1000000;
    int i = 0;
    for (var block in blocks) {
      hash += block.cards.length * i * 100000 * block.typeToInt();
      for (var card in block.cards) {
        hash += card.suit.index * 100 + card.value;
      }
      i++;
    }
    return hash;
  }

  @override
  bool operator ==(Object other) {
    if (other is! GameBoard) {
      return false;
    }
    if (blocks.length != other.blocks.length) {
      return false;
    }
    List<int> used = [];
    for (var i = 0; i < blocks.length; i++) {
      bool found = false;
      for (var j = 0; j < other.blocks.length; j++) {
        if (used.contains(j)) {
          continue;
        }
        if (blocks[i].cards.length != other.blocks[j].cards.length) {
          continue;
        }
        if (blocks[i].typeToInt() != other.blocks[j].typeToInt()) {
          continue;
        }
        bool equal = true;
        for (var k = 0; k < blocks[i].cards.length; k++) {
          if (!other.blocks[j].cards.contains(blocks[i].cards[k])) {
            equal = false;
            break;
          }
        }
        if (equal) {
          found = true;
          used.add(j);
          break;
        }
      }
      if (!found) {
        return false;
      }
    }
    return true;
  }

  GameBoard clone() {
    GameBoard newBoard = GameBoard();
    for (var block in blocks) {
      newBoard.addBlock(block.clone());
    }
    return newBoard;
  }

  @override
  String toString() {
    // Display the block with comma separation
    return blocks.map((b) => b.toString()).join(", ");
  }
}
