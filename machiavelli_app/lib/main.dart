import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
// Ensure that plugin services are initialized so that `availableCameras()`
// can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

// Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

// Get a specific camera from the list of available cameras.
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
  final List<List<Card>> board = [];
  final List<Card> hand = [];

  @override
  Widget build(BuildContext context) {
    // Test board and hand
    if (board.isEmpty) {
      board.add(const [
        Card(suit: CardSuit.clubs, value: 1),
        Card(suit: CardSuit.clubs, value: 2),
        Card(suit: CardSuit.clubs, value: 3),
        Card(suit: CardSuit.clubs, value: 4),
        Card(suit: CardSuit.clubs, value: 5),
      ]);
      board.add(const [
        Card(suit: CardSuit.diamonds, value: 7),
        Card(suit: CardSuit.diamonds, value: 8),
        Card(suit: CardSuit.diamonds, value: 9),
        Card(suit: CardSuit.diamonds, value: 10),
        Card(suit: CardSuit.diamonds, value: 11),
      ]);
      hand.add(const Card(suit: CardSuit.clubs, value: 1));
      hand.add(const Card(suit: CardSuit.clubs, value: 2));
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
                  // Navigate to take picture screen
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

enum CardSuit { spades, hearts, diamonds, clubs }

class Card {
  final CardSuit suit;
  final int value;

  const Card({required this.suit, required this.value});
}

class CardWidget extends StatelessWidget {
  final Card card;

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
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(() {
            if (card.value == 1) return "A";
            if (card.value > 10) {
              switch (card.value) {
                case 11:
                  return "J";
                case 12:
                  return "Q";
                case 13:
                  return "K";
              }
            }
            return card.value.toString();
          }(), style: TextStyle(color: () {
            switch (card.suit) {
              case CardSuit.spades:
                return Colors.black;
              case CardSuit.hearts:
                return Colors.red;
              case CardSuit.diamonds:
                return Colors.red;
              case CardSuit.clubs:
                return Colors.black;
            }
          }())),
          Text(() {
            switch (card.suit) {
              case CardSuit.spades:
                return "♠";
              case CardSuit.hearts:
                return "♥";
              case CardSuit.diamonds:
                return "♦";
              case CardSuit.clubs:
                return "♣";
            }
          }(), style: TextStyle(color: () {
            switch (card.suit) {
              case CardSuit.spades:
                return Colors.black;
              case CardSuit.hearts:
                return Colors.red;
              case CardSuit.diamonds:
                return Colors.red;
              case CardSuit.clubs:
                return Colors.black;
            }
          }())),
        ],
      ),
    );
  }
}

class BlockWidget extends StatelessWidget {
  final List<Card> block;

  const BlockWidget({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    // A block of card, align side by side overlapping each other
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

// A screen that allows users to take a picture using a given camera.
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
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Take a picture')),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            final image = await _controller.takePicture();

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
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
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}
