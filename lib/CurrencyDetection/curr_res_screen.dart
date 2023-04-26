import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CurrResultScreen extends StatefulWidget {
  final String text;

  const CurrResultScreen({Key? key, required this.text}) : super(key: key);

  @override
  _CurrResultScreenState createState() => _CurrResultScreenState();
}

class _CurrResultScreenState extends State<CurrResultScreen> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    speak();
  }

  Future<void> speak() async {
    await flutterTts.speak(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),
        child: Text(widget.text),
      ),
    );
  }
}
