import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'model/game.dart';
import 'model/solver/solver.dart';
import 'model/solver/astar.dart';

void main() {
  runApp(const MachIAvelliApp());
}

class MachIAvelliApp extends StatelessWidget {
  const MachIAvelliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MachIAvelli',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GameBoard board = GameBoard();
  final CardBlock hand = const CardBlock(cards: [
    GameCard(suit: Suit.hearts, value: 4),
    GameCard(suit: Suit.hearts, value: 5),
  ]);
  List<GameBoard> moves = [];
  int _sliderValue = 0;

  @override
  void initState() {
    super.initState();
    board.addBlock(
      const SeriesBlock(
        cards: [
          GameCard(suit: Suit.hearts, value: 2),
          GameCard(suit: Suit.hearts, value: 3),
          GameCard(suit: Suit.hearts, value: 4),
        ],
      ),
    );
    board.addBlock(
      const SquareBlock(
        cards: [
          GameCard(suit: Suit.diamonds, value: 4),
          GameCard(suit: Suit.clubs, value: 4),
          GameCard(suit: Suit.spades, value: 4),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Test board and hand
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Board"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (int i = 0; i < board.blocks.length; i++)
                  BlockWidget(block: board.blocks[i]),
              ],
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TakePictureScreen(),
                    ),
                  );
                },
                child: const Text("Load Board")),
            const Text("Hand"),
            BlockWidget(block: hand),
            TextButton(onPressed: () {}, child: const Text("Load Hand")),
            if (moves.length == 1) const Text("Locally Optimal Move"),
            if (moves.length > 1) const Text("Moves"),
            if (moves.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (int i = 0; i < moves[_sliderValue].blocks.length; i++)
                    BlockWidget(block: moves[_sliderValue].blocks[i]),
                ],
              ),
            if (moves.length > 1) Text("Moves: ${moves.length}"),
            if (moves.length > 1)
              Slider(
                value: _sliderValue.toDouble(),
                min: 0,
                max: moves.length.toDouble() - 1.0,
                divisions: moves.length,
                label: _sliderValue.toString(),
                onChanged: (double value) {
                  setState(() {
                    _sliderValue = value.toInt();
                  });
                },
              ),
            TextButton(
                onPressed: () async {
                  Solver solver = AStar(board: board, hand: hand);
                  solver.getMovesAsync().then((resultMoves) => {
                        if (resultMoves.isNotEmpty)
                          {
                            setState(() {
                              moves = resultMoves;
                            })
                          }
                      });
                },
                child: const Text("Find Moves")),
          ],
        ),
      ),
    );
  }
}

class CardWidget extends StatelessWidget {
  final GameCard card;

  const CardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Stack(fit: StackFit.expand, children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(card.valueToString(), style: TextStyle(color: card.color)),
              Text(card.suitToString(), style: TextStyle(color: card.color)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(card.valueToString(),
                  style: TextStyle(color: card.color, fontSize: 30)),
              Text(card.suitToString(),
                  style: TextStyle(color: card.color, fontSize: 30)),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(card.valueToString(), style: TextStyle(color: card.color)),
              Text(card.suitToString(), style: TextStyle(color: card.color)),
            ],
          )
        ]));
  }
}

class BlockWidget extends StatelessWidget {
  final CardBlock block;
  final double spacing = 15;
  const BlockWidget({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100 + (block.length - 1) * spacing,
      height: 150,
      child: Stack(
        children: <Widget>[
          for (int i = 0; i < block.length; i++)
            Positioned(
              left: i.toDouble() * spacing,
              child: CardWidget(card: block.get(i)),
            ),
        ],
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
  });

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  CameraDescription? camera;
  bool? _hasCamera;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    availableCameras()
        .then((cameras) => {
              if (cameras.isEmpty)
                {
                  _hasCamera = false,
                }
              else
                {
                  _hasCamera = true,
                  camera = cameras.first,
                  _controller = CameraController(
                    camera!,
                    ResolutionPreset.medium,
                  ),
                  setState(() {
                    _initializeControllerFuture = _controller.initialize();
                  }),
                }
            })
        .onError((error, stackTrace) => {
              {
                setState(() {
                  _hasCamera = false;
                })
              }
            });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasCamera == false) {
      return Scaffold(
        appBar: AppBar(title: const Text('Take a picture')),
        body: const Center(
          child: Text("No camera found"),
        ),
      );
    } else if (camera == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Take a picture')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Take a picture')),
        body: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(_controller);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            try {
              await _initializeControllerFuture;
              final image = await _controller.takePicture();
              if (!mounted) return;
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(
                    // Pass the automatically generated path to
                    // the DisplayPictureScreen widget.
                    imagePath: image.path,
                  ),
                ),
              );
            } catch (e) {
              print(e);
            }
          },
          child: const Icon(Icons.camera_alt),
        ),
      );
    }
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}
