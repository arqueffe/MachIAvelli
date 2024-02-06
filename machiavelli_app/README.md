# MachIAvelli

MachIAvelli is an application designed to assist players in optimizing their moves and strategies in the game of Machiavelli. By leveraging image recognition technology, MachIAvelli allows users to import the current state of the game board and their hand directly from a picture. The app then allows the user to pick a move strategy and provides recommendations for the optimal move, helping players make strategic decisions.

## Features

- **Image Recognition**: MachIAvelli utilizes a fine-tuned object recognition algorithm to interpret the game board and player hands from images.

- **Optimal Move Suggestions**: The application provides, from the imported game state, suggestions for the best moves, helping players make strategic decisions.

## How to Use MachIAvelli

1. **Capture Image**: Take a clear photo of the game board and your hand using your device's camera.

3. **Analysis**: MachIAvelli will analyze the imported game state, and provide optimal move suggestions.

4. **Review Suggestions**: Review the suggestions provided by the app and make informed decisions based on the analysis.

## Installation

To install MachIAvelli, follow these steps:

### From source

This application is made with flutter, please refer to https://docs.flutter.dev/get-started/install to prepare your environment for the following steps.

```
git clone git@github.com:arqueffe/MachIAvelli.git
cd MachIAvelli
```

If you want to just run in on your current machine.

```
flutter run # And choose a device
```

If you want to build it for a specific target, for example android (for more target see https://docs.flutter.dev/deployment)

```
flutter build apk --split-per-abi
```

### From releases

As soon as we will reach a milestone, our releases will be available to https://github.com/arqueffe/MachIAvelli/releases.

## About the YOLOv7 model

Please head over to https://github.com/xoxor/yolov7_cards for more information about it.

## Contributing

Contributions to MachIAvelli are welcome! If you have ideas for improvements or find any issues, feel free to open an issue or submit a pull request.

## License

MachIAvelli is licensed under the MIT License.

## Contact

For questions, feedback, or support, please contact the development team at either:
- napolitanobeatrice@gmail.com
- arthur.queffelec@gmail.com

Enjoy optimizing your Machiavelli gameplay with MachIAvelli!