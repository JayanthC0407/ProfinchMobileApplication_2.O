import 'package:flutter/material.dart';

class BackgroundWrapper extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;

  const BackgroundWrapper({super.key, required this.child, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/loginPhoneBg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: child,
      ),
    );
  }
}