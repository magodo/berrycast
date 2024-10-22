import 'package:audioplayers/audioplayers.dart';
import 'package:berrycast/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio.dart';
import 'audioplayer_stream_wrapper.dart';
import 'model/bookmark.dart';
import 'model/episode.dart';
import 'resources/db.dart';
import 'utils.dart';

class ButtonControls extends StatelessWidget {
  const ButtonControls({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var songTitleText = Text(
      Provider.of<AudioSchedule>(context).song.songTitle,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14.0,
        fontWeight: FontWeight.bold,
        letterSpacing: 4.0,
        height: 1.5,
      ),
    );
    final songTitle = buildMarqueeText(context, songTitleText, 50);

    return Container(
      width: double.infinity,
      child: Material(
        color: accentColor,
        shadowColor: const Color(0x44000000),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 50.0),
          child: Column(
            children: <Widget>[
              // song/artist names
              songTitle,
              new SecondaryControl(),
              // audio control
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: new ButtomControls(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondaryControl extends StatelessWidget {
  const SecondaryControl({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final schedule = Provider.of<AudioSchedule>(context);
    final song = schedule.song;
    final seekPosition = Provider.of<SeekPosition>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        LoopModeButton(),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text:
                    "${prettyDuration(seekPosition)}/${prettyDuration(song.audioDuration)}",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 20.0,
                  letterSpacing: 1.0,
                  height: 1.5,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        EpisodeBookmarkButton(),
      ],
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
        PlayPauseButton(
          elevation: 10.0,
          highlightElevation: 5.0,
        ),
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

class EpisodeBookmarkButton extends StatelessWidget {
  TextEditingController _ectrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final song = Provider.of<AudioSchedule>(context).song;
    if (song is Episode) {
      return buildAudioButton(
        Icons.bookmark_border,
        (context) {
          return () {
            showDialog(
                context: context,
                builder: (_context) {
                  return AlertDialog(
                    title: Text('Add Bookmark'),
                    content: Form(
                      key: _formKey,
                      child: TextFormField(
                        controller: _ectrl,
                        decoration: InputDecoration(hintText: "description"),
                        validator: (val) {
                          if (val.length == 0) {
                            return "It's empty";
                          } else {
                            return null;
                          }
                        },
                        onFieldSubmitted: (String desc) =>
                            _submit(context, desc),
                      ),
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: new Text('Add'),
                        onPressed: () => _submit(context, _ectrl.text),
                      ),
                      FlatButton(
                        child: new Text('CANCEL'),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                });
          };
        },
      );
    }
    return Container();
  }

  _submit(BuildContext context, String desc) async {
    final song = Provider.of<AudioSchedule>(context).song;
    final audioPosition = Provider.of<AudioPosition>(context);
    if (!_formKey.currentState.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
    await DBProvider.db.addBookmark(
      Bookmark(
        episodeUrl: song.originUri,
        duration: audioPosition,
        description: _ectrl.text,
      ),
    );
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Bookmark Succeed!",
          style: TextStyle(color: accentColor),
        ),
      ),
    );
  }
}

class LoopModeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final schedule = Provider.of<AudioSchedule>(context);
    final loopMode = schedule.loopMode;
    IconData icon;
    switch (loopMode) {
      case LoopMode.repeat:
        icon = Icons.repeat;
        break;
      case LoopMode.repeatOne:
        icon = Icons.repeat_one;
        break;
      case LoopMode.shuffle:
        icon = Icons.shuffle;
        break;
    }
    final nextLoopMode =
        loopModes[(loopModes.indexOf(loopMode) + 1) % loopModes.length];
    return buildAudioButton(
        icon,
        (context) =>
            () => Provider.of<AudioSchedule>(context).loopMode = nextLoopMode);
  }
}

class PlayPauseButton extends StatelessWidget {
  final double _elevation;
  final double _highlightElevation;
  final double _size;

  const PlayPauseButton({
    Key key,
    elevation = 0.0,
    highlightElevation = 0.0,
    size = 35.0,
  })  : _elevation = elevation,
        _highlightElevation = highlightElevation,
        _size = size,
        super(key: key);

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
        onPressed = schedule.playOn;
        buttonColor = Colors.white;
        break;
    }
    return RawMaterialButton(
      shape: CircleBorder(),
      fillColor: buttonColor,
      splashColor: lightAccentColor,
      highlightColor: lightAccentColor.withOpacity(0.5),
      elevation: _elevation,
      highlightElevation: _highlightElevation,
      onPressed: () {},
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: IconButton(
          icon: Icon(
            icon,
            color: darkAccentColor,
            size: _size,
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
