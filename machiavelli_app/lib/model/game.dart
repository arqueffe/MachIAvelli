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
