import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vibrate Demo',
      home: Scaffold(
        appBar: AppBar(title: const Text('Envision')),
        body: const MyPageView(),
      ),
    );
  }
}



enum HapticFeedbackType {
  lightImpact,
  mediumImpact,
  heavyImpact,
  selectionClick,
  vibrate,
}

class HapticFeedbackButton extends StatelessWidget {
  final String text;
  final HapticFeedbackType feedbackType;
  final VoidCallback onPressed;

  const HapticFeedbackButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.feedbackType = HapticFeedbackType.selectionClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text(text),
      onPressed: () async {
        switch (feedbackType) {
          case HapticFeedbackType.lightImpact:
            await HapticFeedback.lightImpact();
            break;
          case HapticFeedbackType.mediumImpact:
            await HapticFeedback.mediumImpact();
            break;
          case HapticFeedbackType.heavyImpact:
            await HapticFeedback.heavyImpact();
            break;
          case HapticFeedbackType.selectionClick:
            await HapticFeedback.selectionClick();
            break;
          case HapticFeedbackType.vibrate:
            await HapticFeedback.vibrate();
            break;
        }

        onPressed();
      },
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

  void _onPageViewScrolled() async {
  final newPageIndex = _controller.page?.round() ?? 0;
  if (newPageIndex != _currentPageIndex) {
    setState(() {
      _currentPageIndex = newPageIndex;
    });
    
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true && _currentPageIndex==1) {
      Vibration.vibrate(duration: 100);
    }else if(hasVibrator == true && _currentPageIndex==2){Vibration.vibrate(duration: 500);}else if(hasVibrator == true && _currentPageIndex==0){Vibration.vibrate(duration: 800);} else {
      print('Device does not have a vibrator');
    }
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
