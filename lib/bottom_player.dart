import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'audioplayer_stream_wrapper.dart';
import 'play_page.dart';
import 'radial_seekbar.dart';
import 'theme.dart';

class BottomPlayer extends StatefulWidget {
  @override
  _BottomPlayerState createState() => _BottomPlayerState();
}

class _BottomPlayerState extends State<BottomPlayer> {
  double _currentDragPercent;

  double _endDragPercent;

  void _onDragStart(double percent) {}

  void _onDrag(double percent) {
    setState(() {
      _currentDragPercent = percent;
    });
  }

  void _onDragEnd(BuildContext context, double percent) {
    _currentDragPercent = null;
    _endDragPercent = percent;
    final schedule = Provider.of<AudioSchedule>(context);
    schedule.seek(percent);
  }

  @override
  Widget build(BuildContext context) {
    final schedule = Provider.of<AudioSchedule>(context);
    final position = Provider.of<AudioPosition>(context);
    double progress;
    Widget avatar;
    Widget title;
    ValueChanged<double> onChanged;

    if (schedule.playlist == null) {
      progress = 0;
      avatar = Container();
      title = Container();
      onChanged = null;
    } else {
      final song = schedule.song;
      if (_currentDragPercent != null) {
        progress = _currentDragPercent;
      } else {
        if (_endDragPercent != null) {
          progress = _endDragPercent;
          _endDragPercent = null;
        } else {
          progress = position.inSeconds / song.duration.inSeconds;
        }
      }
      avatar = InkWell(
        child: ClipOval(
          clipper: CircleClipper(),
          child: schedule.song.albumArt,
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PlayPage();
          }));
        },
      );

      title = Text(
        "${song.songTitle}",
        style: TextStyle(
          color: darkAccentColor,
        ),
        textAlign: TextAlign.center,
      );

      onChanged = _onDrag;
    }
    return Card(
      child: Container(
        height: 80,
        child: Row(
          children: <Widget>[
            Flexible(
              child: ClipOval(
                clipper: CircleClipper(),
                child: avatar,
              ),
            ),
            Flexible(
              flex: 6,
              child: Column(
                children: <Widget>[
                  Flexible(
                    child: title,
                  ),
                  Flexible(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        valueIndicatorColor: Colors.blue,
                        valueIndicatorTextStyle: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      child: Slider(
                        value: progress,
                        activeColor: accentColor,
                        inactiveColor: Colors.grey,
                        onChangeStart: _onDragStart,
                        onChanged: onChanged,
                        onChangeEnd: (percent) => _onDragEnd(context, percent),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
