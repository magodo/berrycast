import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'button_controls.dart';
import 'play_page.dart';
import 'radial_seekbar.dart';
import 'theme.dart';
import 'utils.dart';

class BottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final schedule = Provider.of<AudioSchedule>(context);
    if (schedule.isEmpty) {
      return SizedBox.shrink();
    }
    return Card(
      child: Container(
        height: 80,
        child: Row(
          children: <Widget>[
            Flexible(
              child: ClipOval(
                clipper: CircleClipper(),
                child: InkWell(
                  child: schedule.song.albumArt,
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return PlayPage();
                    }));
                  },
                ),
              ),
            ),
            Flexible(
              flex: 4,
              fit: FlexFit.tight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: <Widget>[
                    buildMarqueeText(
                        context,
                        Text(
                          schedule.song.songTitle,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4.0,
                            height: 1.5,
                          ),
                        ),
                        30),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: schedule.song.artist,
                            style: TextStyle(
                              color: lightAccentColor,
                              fontSize: 12.0,
                              letterSpacing: 3.0,
                              height: 1.5,
                            ),
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 1,
              fit: FlexFit.tight,
              child: PlayPauseButton(),
            )
          ],
        ),
      ),
    );
  }
}
