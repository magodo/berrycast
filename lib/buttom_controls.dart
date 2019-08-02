import 'package:berrycast/theme.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';

class ButtonControls extends StatelessWidget {
  const ButtonControls({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Material(
        color: accentColor,
        shadowColor: const Color(0x44000000),
        child: Padding(
          padding: const EdgeInsets.only(top: 40.0, bottom: 50.0),
          child: Column(
            children: <Widget>[
              // song/artist names
              new SongInfos(),

              // audio control
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: new ButtomControls(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SongInfos extends StatelessWidget {
  const SongInfos({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final song = Provider.of<AudioSchedule>(context).song;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: song.songTitle + "\n",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 4.0,
              height: 1.5,
            ),
          ),
          TextSpan(
            text: song.artist,
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12.0,
              letterSpacing: 3.0,
              height: 1.5,
            ),
          )
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}

class ButtomControls extends StatelessWidget {
  const ButtomControls({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Container()),
        buildAudioButton(Icons.replay_10,
            (context) => Provider.of<AudioSchedule>(context).replay10),
        Expanded(child: Container()),
        buildAudioButton(Icons.skip_previous,
            (context) => Provider.of<AudioSchedule>(context).prevSong),
        Expanded(child: Container()),
        PlayPauseButton(),
        Expanded(child: Container()),
        buildAudioButton(Icons.skip_next,
            (context) => Provider.of<AudioSchedule>(context).nextSong),
        Expanded(child: Container()),
        buildAudioButton(Icons.forward_10,
            (context) => Provider.of<AudioSchedule>(context).forward10),
        Expanded(child: Container()),
      ],
    );
  }
}

class PlayPauseButton extends StatelessWidget {
  const PlayPauseButton({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final schedule = Provider.of<AudioSchedule>(context);
    final state = Provider.of<AudioPlayerState>(context);

    IconData icon;
    Function onPressed;
    Color buttonColor = lightAccentColor;
    switch (state) {
      case AudioPlayerState.PLAYING:
        icon = Icons.pause;
        onPressed = schedule.pause;
        buttonColor = Colors.white;
        break;
      case AudioPlayerState.PAUSED:
        icon = Icons.play_arrow;
        onPressed = schedule.resume;
        buttonColor = Colors.white;
        break;
      case AudioPlayerState.STOPPED:
      case AudioPlayerState.COMPLETED:
        icon = Icons.play_arrow;
        onPressed = schedule.play;
        buttonColor = Colors.white;
        break;
    }
    return RawMaterialButton(
      shape: CircleBorder(),
      fillColor: buttonColor,
      splashColor: lightAccentColor,
      highlightColor: lightAccentColor.withOpacity(0.5),
      elevation: 10.0,
      highlightElevation: 5.0,
      onPressed: () {},
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: IconButton(
          icon: Icon(
            icon,
            color: darkAccentColor,
            size: 35.0,
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class AudioButton extends StatelessWidget {
  final IconData icon;
  final Function(BuildContext) onPressed;

  const AudioButton({
    Key key,
    @required this.icon,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      splashColor: lightAccentColor,
      highlightColor: Colors.transparent,
      icon: Icon(
        icon,
        color: Colors.white,
        size: 35.0,
      ),
      onPressed: onPressed(context),
    );
  }
}

Widget buildAudioButton(IconData icon, Function(BuildContext) onPressed) {
  return AudioButton(icon: icon, onPressed: onPressed);
}
