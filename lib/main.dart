import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter_tts/flutter_tts.dart';


void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibrate Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Vibrate Demo')),
        body: const MyPageView(),
      ),
    );
  }
}

class MyPageView extends StatefulWidget {
  const MyPageView({Key? key}) : super(key: key);

  @override
  _MyPageViewState createState() => _MyPageViewState();
}

class _MyPageViewState extends State<MyPageView> {
  final PageController _controller = PageController();
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    flutterTts.setPitch(1.0);
    return PageView(
      controller: _controller,
      onPageChanged: _recognisePage,
      children: const <Widget>[
        Center(
          child: Text('First Page'),
        ),
        Center(
          child: Text('Second Page'),
        ),
        Center(
          child: Text('Third Page'),
        ),
      ],
    );
  }

  _recognisePage(int a) async {
    final hasVibrator = await Vibration.hasCustomVibrationsSupport();
    if (a == 0) {
      await flutterTts.speak("Object detection");
      if (hasVibrator != null && hasVibrator) {
        Vibration.vibrate(amplitude: 128, duration: 500);
      }
    } else if (a == 1) {
      if (hasVibrator != null && hasVibrator) {
        Vibration.vibrate(amplitude: 128, duration: 1400);
      }
      await flutterTts.speak("Text Extraction from images");
    } else if (a == 2) {
      if (hasVibrator != null && hasVibrator) {
        Vibration.vibrate(amplitude: 128, duration: 1800);
      }
      await flutterTts.speak("Currency Identifier");
    }
  }
}