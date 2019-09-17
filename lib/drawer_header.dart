import 'package:flutter/material.dart';

class myDrawerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/logo.png'),
        ),
      ),
    );
  }
}
