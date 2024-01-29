import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'model/game.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MachIAvelliApp(
    camera: firstCamera,
  ));
}

class MachIAvelliApp extends StatelessWidget {
  final CameraDescription camera;
  const MachIAvelliApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MachIAvelli',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: HomePage(camera: camera),
    );
  }
}

class HomePage extends StatefulWidget {
  final CameraDescription camera;
  const HomePage({super.key, required this.camera});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<List<GameCard>> board = [];
  final List<GameCard> hand = [];

  @override
  Widget build(BuildContext context) {
    // Test board and hand
    if (board.isEmpty) {
      board.add(const [
        GameCard(suit: Suit.clubs, value: 1),
        GameCard(suit: Suit.clubs, value: 2),
        GameCard(suit: Suit.clubs, value: 3),
        GameCard(suit: Suit.clubs, value: 4),
        GameCard(suit: Suit.clubs, value: 5),
      ]);
      board.add(const [
        GameCard(suit: Suit.diamonds, value: 7),
        GameCard(suit: Suit.diamonds, value: 8),
        GameCard(suit: Suit.diamonds, value: 9),
        GameCard(suit: Suit.diamonds, value: 10),
        GameCard(suit: Suit.diamonds, value: 11),
      ]);
      hand.add(const GameCard(suit: Suit.clubs, value: 1));
      hand.add(const GameCard(suit: Suit.clubs, value: 2));
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Board"),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                for (int i = 0; i < board.length; i++)
                  BlockWidget(block: board[i]),
              ],
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TakePictureScreen(camera: widget.camera),
                    ),
                  );
                },
                child: const Text("Load Board")),
            const Text("Hand"),
            BlockWidget(block: hand),
            TextButton(onPressed: () {}, child: const Text("Load Hand")),
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
  final List<GameCard> block;

  const BlockWidget({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100 + (block.length - 1) * 10,
      height: 150,
      child: Stack(
        children: <Widget>[
          for (int i = 0; i < block.length; i++)
            Positioned(
              left: i.toDouble() * 10,
              child: CardWidget(card: block[i]),
            ),
        ],
      ),
    );
  }
}

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
