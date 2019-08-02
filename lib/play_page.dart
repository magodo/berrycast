import 'package:flutter/material.dart';

import 'buttom_controls.dart';
import 'radial_seekbar.dart';


class PlayPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.grey,
          onPressed: () => Navigator.pop(context),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.menu),
            color: Colors.grey,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // seek bar
          Expanded(
            child: RadialSeekBar(),
          ),

          // visualizer
          Container(
            width: double.infinity,
            height: 125.0,
          ),

          // song title, artist name and controls
          ButtonControls(),
        ],
      ),
    );
  }
}
