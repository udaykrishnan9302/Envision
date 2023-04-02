import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


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
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onPageViewScrolled);
  }

  @override
  void dispose() {
    _controller.removeListener(_onPageViewScrolled);
    _controller.dispose();
    super.dispose();
  }

  void _onPageViewScrolled() {
    final newPageIndex = _controller.page?.round() ?? 0;
    if (newPageIndex != _currentPageIndex) {
      setState(() {
        _currentPageIndex = newPageIndex;
      });
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _controller,
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
}
