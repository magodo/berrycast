import 'package:flutter/material.dart';

import 'bloc/podcast.dart';
import 'model/podcast.dart';
import 'theme.dart';

class FancyFab extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;

  FancyFab({this.onPressed, this.tooltip, this.icon});

  @override
  _FancyFabState createState() => _FancyFabState();
}

class _FancyFabState extends State<FancyFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
//  Animation<double> _animateIcon;
  Animation<double> _textPosition;
  TextEditingController _ectrl;

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300))
          ..addListener(() {
            setState(() {});
          });
//    _animateIcon =
//        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      begin: accentColor,
      end: darkAccentColor,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _textPosition = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);

    _ectrl = TextEditingController();

    super.initState();
  }

  @override
  dispose() {
    _ectrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  Widget text(BuildContext context, double percent) {
    return Container(
      width: percent * 250,
      height: percent * 50,
      child: percent == 1.0
          ? TextField(
              controller: _ectrl,
              maxLines: 1,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.done_outline),
                  onPressed: () => _submitUrl(context, _ectrl.text),
                ),
                hintText: percent == 1.0 ? "Feed URL" : null,
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: darkAccentColor)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: accentColor)),
              ),
              onSubmitted: (String url) => _submitUrl(context, url),
            )
          : Container(
              decoration: BoxDecoration(
                border: Border.all(color: accentColor),
              ),
            ),
    );
  }

  void _submitUrl(BuildContext context, String url) async {
    if (url == "") return;
    Podcast podcast;
    FocusScope.of(context).requestFocus(FocusNode()) ;
    try {
      podcast = await Podcast.newPodcastByUrl(url);
    } catch (e) {
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text("Invalid rss feed!: ${e.toString()}")));
      _ectrl.clear();
      return;
    }
    podcastBloc.add(podcast);
    _ectrl.clear();
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            _textPosition.value * -20,
            0.0,
            0.0,
          ),
          child: _textPosition.value == 0
              ? null
              : text(context, _textPosition.value),
        ),
        toggle(),
      ],
    );
  }
}
